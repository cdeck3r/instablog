#!/bin/bash

#
# updates the instablog installation by
# resetting the current branch
# and pull the current master branch
#
# Finally, it sets the executable bit for all shell scripts
# and re-creates the venv
#

INSTABLOG_DIR="$HOME"/instablog

echo "Update code from repo..."

cd "$INSTABLOG_DIR" && \
    git reset --hard HEAD && \
    git pull && \
    find . -type f -name '*.sh' | xargs chmod +x

echo "Re-create python virtual environment..."
cd "$INSTABLOG_DIR" && \
    make venv

echo "Update done."
