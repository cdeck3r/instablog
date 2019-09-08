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
DATAROOT="/tmp" # default value
# Instagram profile URL
PROFILE_URL="https://www.instagram.com/koloot.design/" # default value
#PROFILE_URL="https://www.instagram.com/dramalamas.tours2019/"
# Github blog URL
GITHUB_URL=  # no default value
#GITHUB_URL="https://github.com/dramalamas/dramalamas.github.io"
# Blog post date
POST_DATE=$(date '+%Y-%m-%d') # today's date, format: yyyy-mm-dd

#
# tools
#
INSTACRAWLER="$SCRIPT_DIR"/instacrawler.sh
INSTAPOST="$SCRIPT_DIR"/instapost.sh
BLOGPOST="$SCRIPT_DIR"/blogpost.sh
FEED_HISTORY="$SCRIPT_DIR"/feed_history.sh

# include common funcs
source ./funcs.sh

##############
# Helper functions
##############
OPT_CNT=0
usage()
{
    echo -e "Usage: "$SCRIPT_NAME" <options>"
    echo
    echo -e "Options:"
    echo
    echo -e "-h | --help\t\t This message"
    echo -e "[-r | --dataroot]\t directory to exchange data betw. components"
    echo -e "[-p | --profile]\t Instagram profile URL"
    echo -e "[-g | --github]\t\t Github blog URL"
    echo -e "[-d | --postdate]\t blog post date, format: yyyy-mm-dd"
    echo ""
	echo -e "Default DATAROOT: ${DATAROOT}"
	echo -e "Default PROFILE_URL: ${PROFILE_URL}"
    #echo -e "Default GITHUB_URL: ${GITHUB_URL}"
    echo -e "Default POST_DATE: ${POST_DATE}"
    echo -e ""
}

####################################################
# parse params
####################################################
while :; do
	case $1 in
        -h|-\?|--help)   # Call a "usage" function to display a synopsis, then exit.
            usage
            exit 1
            ;;
        -r|--dataroot)
            DATAROOT="$2"
            OPT_CNT=$((OPT_CNT + 1))
            shift
            ;;
        -p|--profile)
            PROFILE_URL="$2"
            OPT_CNT=$((OPT_CNT + 1))
            shift
            ;;
        -g|--github)
            GITHUB_URL="$2"
            OPT_CNT=$((OPT_CNT + 1))
            shift
            ;;
        -d|--postdate)
            POST_DATE="$2"
            OPT_CNT=$((OPT_CNT + 1))
            shift
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            shift
            ;;
        *)  # Default case: no more options; test required param and break out
			if [ "$OPT_CNT" -ge 0 ]
			then
                break
			else
				echo -e "ERROR: Too few options provided."
                echo -e "Please specify at least an option."
                echo -e ""
				usage
				exit 1
			fi
			;;
    esac
    shift
done

# print the params config
log_echo "INFO" "DATAROOT: ${DATAROOT}"
log_echo "INFO" "PROFILE_URL: ${PROFILE_URL}"
log_echo "INFO" "GITHUB_URL: ${GITHUB_URL}"
log_echo "INFO" "POST_DATE: ${POST_DATE}"

# Note about the remote update

if [ -z "${GITHUB_URL}" ]; then
    log_echo "WARN" "No GITHUB_URL specified. Will not update remote blog."
fi

# let's start
log_echo "INFO" "instablog starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"

##################################

# clean up
#rm -rf "$DATAROOT"/shortcodes.csv
"$INSTACRAWLER" "$DATAROOT" "$PROFILE_URL"
"$FEED_HISTORY" "$DATAROOT" "$POST_DATE"
"$INSTAPOST" "$DATAROOT"
"$BLOGPOST" "$DATAROOT" "$POST_DATE" "$GITHUB_URL"

log_echo "INFO" "Instablog done"
