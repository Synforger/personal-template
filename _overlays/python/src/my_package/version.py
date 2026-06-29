# Template version - the version of rd-prj-template this project was created from.
# This value is preserved when personalize.py is run.
TEMPLATE_VERSION = "0.1.0"

# Project version - reset to 0.0.0 when personalize.py is run.
_MAJOR = "0"
_MINOR = "1"
# On main and in a nightly release the patch should be one ahead of the last
# released build.
_PATCH = "13"
# This is mainly for nightly builds which have the suffix ".dev$DATE". See
# https://semver.org/#is-v123-a-semantic-version for the semantics.
_SUFFIX = ""

VERSION_SHORT = "{0}.{1}".format(_MAJOR, _MINOR)
VERSION = "{0}.{1}.{2}{3}".format(_MAJOR, _MINOR, _PATCH, _SUFFIX)
