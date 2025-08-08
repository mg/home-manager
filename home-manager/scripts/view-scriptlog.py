#!/usr/bin/env uv run python

import subprocess
from pathlib import Path
from mg_telemetry import log_execution

log_execution(__file__)
log_file = Path.home() / ".local/share/logs/scripts.csv"
subprocess.run(["tw", str(log_file)], check=True)
