"""Integration tests: host Python test runner + Neovim/fish/devc + python-dev.

Run: python3 tests/test_devc_lsp.py
Uses a temporary project/container, never an existing project's LSP.
"""

import json
import os
from pathlib import Path
import select
import signal
import subprocess
import tempfile
import time
import unittest

LAUNCHER = ["nvim", "-l", str(Path(__file__).resolve().parents[1] / "scripts/devc-lsp.lua")]
SERVER = r'''
import json, os, signal, subprocess, sys, time
child = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(300)'], start_new_session=True)
print(json.dumps({'token': os.environ['DEVC_LSP_SESSION'], 'pid': os.getpid(), 'child': child.pid, 'args': sys.argv[2:]}), flush=True)
if sys.argv[1] == 'echo':
    data = sys.stdin.buffer.read(262144)
    sys.stdout.buffer.write(data)
    sys.stdout.buffer.flush()
if sys.argv[1] == 'stubborn':
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
if sys.argv[1] == 'normal':
    sys.stdin.readline()
    sys.exit(0)
while True:
    time.sleep(1)
'''
SCAN = r'''
import json, pathlib, sys
found = []
for entry in pathlib.Path('/proc').glob('[0-9]*/environ'):
    try:
        if ('DEVC_LSP_SESSION=' + sys.argv[1]).encode() in entry.read_bytes().split(b'\0'):
            found.append(int(entry.parent.name))
    except OSError:
        pass
print(json.dumps(found))
'''


class LifecycleTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory(prefix="devc-lsp-test-")
        cls.root = str(Path(cls.tmp.name).resolve())
        cls.env = dict(os.environ, DEVC_LANG="python")
        subprocess.run(["fish", "-c", "devc start python"], cwd=cls.root, env=cls.env, check=True)
        cls.name = subprocess.check_output(
            ["fish", "-c", "devc name python"], cwd=cls.root, env=cls.env, text=True
        ).strip()

    @classmethod
    def tearDownClass(cls):
        subprocess.run(["container", "stop", cls.name], check=True)
        cls.tmp.cleanup()

    def start(self, mode="idle", *args):
        proc = subprocess.Popen(
            [*LAUNCHER, "python", "-u", "-c", SERVER, mode, *args],
            cwd=self.root, env=self.env, stdin=subprocess.PIPE,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.addCleanup(self.dispose, proc)
        self.assertTrue(select.select([proc.stdout], [], [], 30)[0], "startup timed out")
        line = proc.stdout.readline()
        if not line:
            self.fail(proc.stderr.read().decode())
        return proc, json.loads(line)

    @staticmethod
    def dispose(proc):
        if proc.poll() is None:
            proc.terminate()
            proc.wait(timeout=25)
        for pipe in (proc.stdin, proc.stdout, proc.stderr):
            pipe.close()

    def pids(self, session):
        return json.loads(subprocess.check_output(
            ["container", "exec", self.name, "python", "-c", SCAN, session["token"]], text=True
        ))

    def assert_clean(self, proc, session):
        proc.wait(timeout=25)
        self.assertEqual(proc.returncode, 0, proc.stderr.read().decode())
        self.assertEqual(self.pids(session), [], "guest process leaked")

    def test_terminate_scoped_to_session_and_cleans_detached_child(self):
        survivor, survivor_session = self.start()
        for _ in range(3):
            proc, session = self.start()
            proc.terminate()
            self.assert_clean(proc, session)
            self.assertIn(survivor_session["pid"], self.pids(survivor_session))
        survivor.terminate()
        self.assert_clean(survivor, survivor_session)

    def test_eof_stops_server_that_ignores_stdin(self):
        proc, session = self.start()
        proc.stdin.close()
        self.assert_clean(proc, session)

    def test_normal_exit_cleans_detached_child(self):
        proc, session = self.start("normal")
        proc.stdin.write(b"exit\n")
        proc.stdin.flush()
        self.assert_clean(proc, session)

    def test_stubborn_server_is_killed(self):
        proc, session = self.start("stubborn")
        proc.terminate()
        self.assert_clean(proc, session)

    def test_host_sigkill_still_closes_guest_stdin(self):
        proc, session = self.start()
        proc.kill()
        proc.wait(timeout=5)
        deadline = time.monotonic() + 20
        while self.pids(session) and time.monotonic() < deadline:
            time.sleep(0.2)
        self.assertEqual(self.pids(session), [])

    def test_sigint_and_sighup(self):
        for sig in (signal.SIGINT, signal.SIGHUP):
            proc, session = self.start()
            proc.send_signal(sig)
            self.assert_clean(proc, session)

    def test_binary_stdio_and_argument_quoting(self):
        args = ["", "spaces and 'quotes'", "back\\\\slashes\\\\", "$HOME; `date`\nnew line"]
        proc, session = self.start("echo", *args)
        self.assertEqual(session["args"], args)
        payload = bytes(range(256)) * 1024
        proc.stdin.write(payload)
        proc.stdin.flush()
        self.assertTrue(select.select([proc.stdout], [], [], 10)[0], "echo timed out")
        self.assertEqual(proc.stdout.read(len(payload)), payload)
        proc.terminate()
        self.assert_clean(proc, session)

    def test_server_failure_exit_code(self):
        proc = subprocess.Popen(
            [*LAUNCHER, "sh", "-c", "exit 23"], cwd=self.root, env=self.env,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.addCleanup(self.dispose, proc)
        proc.wait(timeout=25)
        self.assertEqual(proc.returncode, 23, proc.stderr.read().decode())
        self.assertEqual(proc.stdout.read(), b"")

    def test_early_terminate(self):
        # Stop before the guest starts; cleanup must not race a late launch.
        proc = subprocess.Popen(
            [*LAUNCHER, "sleep", "300"], cwd=self.root, env=self.env,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        )
        self.addCleanup(self.dispose, proc)
        time.sleep(0.15)
        proc.terminate()
        proc.wait(timeout=25)
        self.assertEqual(proc.returncode, 0, proc.stderr.read().decode())
        state = subprocess.check_output(
            ["container", "exec", self.name, "ps", "-eo", "args"], text=True
        )
        self.assertNotIn("sleep 300", state)


if __name__ == "__main__":
    unittest.main(verbosity=2)
