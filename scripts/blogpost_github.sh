#!/bin/bash

#
# blogpost_github
# This is the github interface for blogpost
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
# Blog files
BLOG_FILES=""$DATAROOT"/*-instablog.md"
# the directory containing the website
GIT_DIR="$DATAROOT"/website
# Github repo containing the website
GIT_URL="https://github.com/dramalamas/dramalamas.github.io.git"

# repo specific param values
## website is in master branch
GIT_BRANCH="master"
## User credentials
GIT_USER_NAME="Christian Decker"
GIT_USER_EMAIL="christian.decker@reutlingen-university.de"


#
# tools
#

# include common funcs
source ./funcs.sh
source ./funcs_git.sh

##############
# Helper functions
##############

# ...

log_echo "INFO" "Blogpost GITHUB starts"

##################################

# prepare DATAROOT directory
log_echo "INFO" "Create data directory: "$DATAROOT""
mkdir -p "$DATAROOT"

##################################

# 1. clone
# 2. update
# 3. clean
# 4. copy blog files
# 5. push

# clone repo's master branch
#
# Param #1: GIT_URL - GIT repo URL
# Param #2: GIT_BRANCH - Branch
# Param #3: GIT_DIR - the local git repo directory
git_clone_dataroot "$GIT_URL" "$GIT_BRANCH" "$GIT_DIR"

# config repo for commit / push
#
# Param #1: GIT_DIR - the local git repo directory
# Param #2: user.name
# Param #3: user.email
# Param #4: GIT_URL - GIT repo URL including access token,
#           e.g. https://${GITHUB_ACCESS_TOKEN}@github.com/user/repo.git
PREFIX="https://"
GIT_URL_SHORT=${GIT_URL#"$PREFIX"}
GIT_TOKEN_URL="${PREFIX}${GITHUB_ACCESS_TOKEN}@${GIT_URL_SHORT}"
#
git_update_config_dataroot "$GIT_DIR" "$GIT_USER_NAME" "$GIT_USER_EMAIL" "$GIT_TOKEN_URL"
git_clean_repo_dir "$GIT_DIR"
#
log_echo "INFO" "All preps done for branch <"$GIT_BRANCH"> in directory: "$GIT_DIR""
# back to where you come from
cd "$SCRIPT_DIR"

# copy blog files into GIT_DIR
cp -t "$GIT_DIR/_posts" $BLOG_FILES

# add / commit / pus blog files
#
# Param #1: GIT_URL - GIT repo URL
# Param #2: GIT_DIR - the local git repo directory
# Param #3: COMMIT_MSG - commit message
git_commit_push_dataroot "$GIT_URL" "$GIT_DIR" "Instablog post update"

# return to where you come from
cd "$SCRIPT_DIR"

log_echo "INFO" "Blogpost GITHUB done."
