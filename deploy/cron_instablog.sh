#!/bin/bash

#
# The instablog cronjob
# will run this script
#

# this directory is the script directory
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPT_DIR

#
# vars and params
#
# the script's name
SCRIPT_NAME=$0
#
INSTABLOG_DIR="$HOME"/instablog
# the instablog directory
cd "$INSTABLOG_DIR"

# activate virtualenv
source venv/bin/activate

# here are the scripts
cd scripts

# configure and fire up the pipeline
DATAROOT="$HOME"/dramalamas_posts
PROFILE_URL="https://www.instagram.com/dramalamas.tours2019/"
GITHUB_URL="https://github.com/dramalamas/dramalamas.github.io"

mkdir -p "$DATAROOT"
./instablog.sh -r "$DATAROOT" -p "$PROFILE_URL" -g "$GITHUB_URL" 2>&1 >> "$HOME"/instablog.log

# deactivate virtualenv
deactivate
