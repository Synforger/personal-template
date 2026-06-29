import os
import random

import numpy as np


def set_seed(seed: int) -> None:
    """Set seed for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)


TEST_ROOT = os.path.realpath(os.path.dirname(__file__))
PACKAGE_ROOT = os.path.dirname(TEST_ROOT)
DATASETS_PATH = os.path.join(PACKAGE_ROOT, "data", "datasets")
ROOT_SEED = 1234


def reset_seed():
    set_seed(ROOT_SEED)
