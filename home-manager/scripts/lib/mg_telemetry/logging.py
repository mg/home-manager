import logging
from logging.handlers import SysLogHandler


def get_logger(program):
    logger = logging.getLogger(f"system/mg/#{program}:")
    logger.setLevel(logging.ERROR)
    try:
        handler = SysLogHandler(address="/dev/log")  # Linux
    except FileNotFoundError:
        handler = SysLogHandler(address="/var/run/syslog")  # macOS
    formatter = logging.Formatter("%(name)s: %(levelname)s %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger
