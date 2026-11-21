"""Run the template's bats suite with a time limit per test, and name the slowest 10 tests.

Called by the Taskfile's `test:template` task and by the CI workflow, with the bats paths as
arguments. The slowest are printed in pytest's `--durations` form, so the closing hooks that
read pytest output read these too.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys

# The slowest test takes about 0.4 seconds on a developer's Mac; three times that, rounded up to
# the whole seconds bats takes.
TIME_LIMIT_SECONDS = 2
SLOWEST_COUNT = 10
# A TAP result line with --timing: `ok 3 name in 186ms` or `not ok 3 name in 2004ms # ...`.
RESULT_LINE = re.compile(r"^(?:not )?ok \d+ (?P<name>.+?) in (?P<milliseconds>\d+)ms\b")


def print_slowest(durations: list[tuple[float, str]]) -> None:
    """Print the slowest tests, slowest first."""
    slowest = sorted(durations, reverse=True)[:SLOWEST_COUNT]
    print(f"===== slowest {SLOWEST_COUNT} durations =====")
    for seconds, name in slowest:
        print(f"{seconds:.2f}s call {name}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("paths", nargs="+", help="bats files or folders to run")
    arguments = parser.parse_args()

    environment = {**os.environ, "BATS_TEST_TIMEOUT": str(TIME_LIMIT_SECONDS)}
    command = ["bats", "--timing", "--formatter", "tap", *arguments.paths]
    durations: list[tuple[float, str]] = []
    with subprocess.Popen(command, env=environment, stdout=subprocess.PIPE, text=True) as process:
        assert process.stdout is not None
        for line in process.stdout:
            print(line, end="", flush=True)
            result = RESULT_LINE.match(line)
            if result:
                durations.append((int(result["milliseconds"]) / 1000, result["name"]))
    print_slowest(durations)
    return process.returncode


if __name__ == "__main__":
    sys.exit(main())
