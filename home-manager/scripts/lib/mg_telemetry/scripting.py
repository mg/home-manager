from datetime import datetime
from pathlib import Path

# usage
# from mg_telemetry import log_execution
# log_execution(__file__)


def log_execution(script_path):
    """Log script execution to ~/.local/share/logs/scripts.csv"""
    log_dir = Path.home() / ".local" / "share" / "logs"
    log_file = log_dir / "scripts.csv"
    utc_time = datetime.utcnow().isoformat() + "Z"

    script_name = Path(script_path).stem

    # Create log directory if it doesn't exist
    log_dir.mkdir(parents=True, exist_ok=True)

    # Write header if file doesn't exist
    if not log_file.exists():
        with open(log_file, "w") as f:
            f.write("timestamp,script\n")

    # Append log entry
    with open(log_file, "a") as f:
        f.write(f"{utc_time},{script_name}\n")
