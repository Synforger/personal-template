import logging
from typing import Optional


def get_logger(name: Optional[str] = __name__) -> logging.Logger:
    """Initializes a python command line logger.

    Args:
        name (Optional[str], optional): Name for logging. Defaults to __name__.

    Returns:
        logging.Logger: logger instance.
    """
    return logging.getLogger(name)
