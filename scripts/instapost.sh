#!/bin/bash

#
# instapost
# download a single Instagram post's data
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
# the name of the file storing posts' shortcodes
DATAFILE_SHORTCODES="$DATAROOT"/shortcodes.csv
# File path containing all relevant post information
DATAFILE_POSTINFO="$DATAROOT"/postinfo.csv

#
# tools
#

INSTAPOST="$SCRIPT_DIR"/../src/instapost.py

# include common funcs
source ./funcs.sh

##############
# Helper functions
##############

# ...

log_echo "INFO" "Instapost starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"

##################################


python "$INSTAPOST" "$DATAFILE_SHORTCODES" "$DATAFILE_POSTINFO"

log_echo "INFO" "Instapost done"
