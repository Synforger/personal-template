from pathlib import Path

import pytest

from tests import DATASETS_PATH


@pytest.fixture(scope="session")
def datadir():
    return Path(DATASETS_PATH)


@pytest.fixture(scope="session")
def env_python_version():
    """Return the project's required Python version range."""
    return ">=3.10"
