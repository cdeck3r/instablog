#!/bin/bash

#
# blogpost
# creates blogpost for a given date
#
# Author: cdeck3r
#

# this directory is the script directory
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPT_DIR

#
# vars and params
#

# the script's name
SCRIPT_NAME=$0
# this directory stores intermediate files and data
DATAROOT=$1
# blog date, YYYY-MM-DD
BLOG_DATE=$2
# File path containing all relevant post information
DATAFILE_POSTINFO="$DATAROOT"/postinfo.csv
# the name of the file storing posts' shortcodes
BLOG_POSTFILE="$DATAROOT"/"$BLOG_DATE"-instablog.md

#
# tools
#

BLOGPOST="$SCRIPT_DIR"/../src/blogpost.py
BLOGPOST_GIT="$SCRIPT_DIR"/blogpost_github.sh

# include common funcs
source ./funcs.sh

##############
# Helper functions
##############

# ...

log_echo "INFO" "Blogpost starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"

##################################

# use -f if you do not want to filter for BLOG_DATE
python "$BLOGPOST" "$DATAFILE_POSTINFO" "$BLOG_POSTFILE" "$BLOG_DATE" -f
"$BLOGPOST_GIT" "$DATAROOT"

log_echo "INFO" "Blogpost done"
