#!/bin/bash

#
# Common funcs for scripts
# to be sourced in various scripts
#
# Author: cdeck3r
#

# reads and exports all env vars, mostly tokens
export $(egrep -v '^#' $HOME/.env | xargs)

#
# logging on stdout
# Param #1: log level, e.g. INFO, WARN, ERROR
# Param #2: log message
log_echo () {
    LOG_LEVEL=$1
    LOG_MSG=$2
    TS=$(date '+%Y-%m-%d %H:%M:%S,%s')
    echo "$TS - $SCRIPT_NAME - $LOG_LEVEL - $LOG_MSG"
}
