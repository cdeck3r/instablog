#!/bin/bash

#
# Install supplemental software
# * slackr: bash script for Slack messaging
# * hugo: static webpage generator
# * java: detect and version check
# 

# this directory is the script directory
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
cd $SCRIPT_DIR

# important variables
SLACKR_URL='https://github.com/a-sync/slackr.git'

HUGO_DIR="$SCRIPT_DIR"/hugo
HUGO_URL='https://github.com/gohugoio/hugo/releases/download/v0.56.3/hugo_0.56.3_Linux-64bit.tar.gz'

PLANTUML_JAR=$SCRIPT_DIR/plantuml/plantuml.jar
PLANTUML_URL='https://datapacket.dl.sourceforge.net/project/plantuml/plantuml.jar'

JAVA_MIN_VERSION="1.5"

#####################################################
# Helper functions
#####################################################
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

#####################################################
# Main program
#####################################################

# Source: https://stackoverflow.com/a/677212
command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Abort."; exit 1; }

#
# slackr
# Simple shell command to send or pipe content to slack via webhooks.
#

if [[ -x "$SCRIPT_DIR/slackr/slackr" ]]; then
	log_echo "INFO" "Slackr found: $SCRIPT_DIR/slackr"
else
	log_echo "INFO" "Start installing: slackr"
	git clone "$SLACKR_URL"

	if [[ $? -ne 0 ]]
	then
		log_echo "ERROR" "Install FAILED: slackr"
		#exit 1
	fi
	cd slackr && chmod +x slackr
	# back
	cd ..
	log_echo "INFO" "Install done: slackr"
fi


#
# hugo
#
log_echo "INFO" "Start installing: hugo"

mkdir -p "$HUGO_DIR"
wget -qO- ${HUGO_URL} | tar -C "$HUGO_DIR" -xvz

if [[ $? -ne 0 ]]
then
	log_echo "ERROR" "Install FAILED: hugo"
	exit 1
else
	log_echo "INFO" "Install done: hugo"
fi

#
# plantuml
#
if [ -f "$PLANTUML_JAR" ]; then
	# log string
  	log_echo "INFO" "plantuml jar found: $PLANTUML_JAR"
else
    # we need to download the plantuml jar

    # log string
	log_echo "ERROR" "plantuml jar not found: $PLANTUML_JAR"
    # create directory and download using wget
    PLANTUML_DIR=$(dirname $PLANTUML_JAR)
    mkdir -p $PLANTUML_DIR
    log_echo "INFO" "Download plantuml jar into directory: $PLANTUML_DIR"
    wget -P $PLANTUML_DIR $PLANTUML_URL
    # error check
    if [[ $? -ne 0 ]]; then
        log_echo "ERROR" "Error downloading plantuml jar: "$PLANTUML_URL""
        exit 1
    fi
    log_echo "INFO" "Download of plantuml jar successful."
fi

#
# Check java version
# Source: https://stackoverflow.com/a/7335524
#
log_echo "INFO" "Check for java and java version"
if type -p java; then
    log_echo "INFO" "Found java executable in PATH"
    _JAVA=java
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    log_echo "INFO" "Found java executable in JAVA_HOME"
    _JAVA="$JAVA_HOME/bin/java"
else
    log_echo "WARN" "Java not found. Please install."
fi

if [[ "$_JAVA" ]]; then
    JAVA_VERSION=$("$_JAVA" -version 2>&1 | awk -F '"' '/version/ {print $2}')
    log_echo "INFO" "Java version found: $JAVA_VERSION"
    if [[ "$JAVA_VERSION" > "$JAVA_MIN_VERSION" ]]; then
        log_echo "INFO" "Java version $JAVA_VERSION is greater than $JAVA_MIN_VERSION."
    else         
        log_echo "WARN" "Java version $JAVA_VERSION is less or equal than $JAVA_MIN_VERSION."
    fi
fi

