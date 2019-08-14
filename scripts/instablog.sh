#!/bin/bash

#
# instablog
# Main script for automatically creating daily blog posts from Instagram posts.
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
# Instagram profile URL
PROFILE_URL=$2

# include common funcs
source ./funcs.sh

## var test; set default values
if [ -z "$DATAROOT" ]; then
    log_echo "WARN" "DATAROOT directory not set"
	# set default value
	DATAROOT="/tmp"
    log_echo "INFO" "Default DATAROOT directory set: "$DATAROOT""
fi

if [ -z "$PROFILE_URL" ]; then
    log_echo "WARN" "No Instagram profile URL defined"
    # set default value
	PROFILE_URL="https://www.instagram.com/koloot.design/"
    log_echo "INFO" "Default Instagram profile URL set: "$PROFILE_URL""
fi

#
# tools
#
INSTACRAWLER="$SCRIPT_DIR"/instacrawler.sh
INSTAPOST="$SCRIPT_DIR"/instapost.sh
#BLOGPOST="$SCRIPT_DIR"/blogpost.sh


##############
# Helper functions
##############

# ...

log_echo "INFO" "instablog starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"

##################################

"$INSTACRAWLER" "$DATAROOT" "$PROFILE_URL"
"$INSTAPOST" "$DATAROOT"

log_echo "INFO" "Instablog done"
