#!/bin/bash
# Backward-compatible wrapper; canonical launcher: bin/OS/darwin/scripts/run.sh
exec /bin/bash "$(cd "$(dirname "$0")" && pwd)/OS/darwin/scripts/run.sh" "$@"
