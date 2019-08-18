#!/bin/bash

#
# feed history
# records the crawler's history
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
# Blog post date
POST_DATE=$2
# the name of the file storing posts' shortcodes
DATAFILE="$DATAROOT"/shortcodes.csv

#
# tools
#


# include common funcs
source ./funcs.sh

##############
# Helper functions
##############

# ...

log_echo "INFO" "Feed history starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"
log_echo "INFO" "Create data file: "$DATAFILE""
touch "$DATAFILE"

##################################

# record the current file for the records
# Format: YYYY-MM-DD-HHMMSS-shortcodes.csv
TS=$(date '+%H%M%S')
FILE=$(basename "$DATAFILE")
cp "$DATAFILE" "$DATAROOT"/"$POST_DATE-$TS-$FILE"

# merge the recorded files into the shortcodes.csv
RECORD_SHORTCODES="$DATAROOT"/"$POST_DATE-*-$FILE"
echo "shortcode" > "$DATAFILE"
cat $RECORD_SHORTCODES | egrep -v shortcode | sort | uniq >> "$DATAFILE"

log_echo "INFO" "Feed history done"
