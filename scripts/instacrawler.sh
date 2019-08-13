#!/bin/bash

#
# instacrawler
# collect URLs from a given Instagram’s profile
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
# this directory stores result of all runs, e.g. /tmp/iotdata
DATAROOT=$1
# the name of the dropbox directory where the url_list is found
DATAFILE="$DATAROOT"/shortcodes.csv
# Whether it is the initial run of data quality report
PROFILE_URL=$2

#
# tools
#

INSTACRAWLER="$SCRIPT_DIR"/../src/instacrawler.py

# include common funcs
source ./funcs.sh

##############
# Helper functions
##############

# ...

log_echo "INFO" "Instacrawler starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"
log_echo "INFO" "Create data file: "$DATAFILE""
touch "$DATAFILE"

##################################


python "$INSTACRAWLER" "$DATAFILE" "$PROFILE_URL"

log_echo "INFO" "Instacrawler done"
