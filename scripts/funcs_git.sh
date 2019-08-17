#!/bin/bash

#
# contains common funcs for bck_* scripts
#

# include common funcs
source ./funcs.sh

if [ -z "${GIT+x}" ]; then
    # if GIT is unset, set it default
    GIT='git'
fi

# test if git is installed
command -v "$GIT" >/dev/null 2>&1 \
    || { echo >&2 "I require "$GIT" but it's not installed.  Aborting."; exit 1; }

# Test if Github access token is defined
if [ -z "${GITHUB_ACCESS_TOKEN+x}" ]; then
    log_echo "WARN" "Github access token not set. No push possible."
fi

#
# clone GIT_DIR directory from git repo
#
# Param #1: GIT_URL - GIT repo URL
# Param #2: GIT_BRANCH - Branch
# Param #3: GIT_DIR - the local git repo directory
git_clone_dataroot() {
    local GIT_URL=$1
    local GIT_BRANCH=$2
    local GIT_DIR=$3

    mkdir -p "$GIT_DIR"
    cd "$GIT_DIR"
    $GIT status
    if [[ $? -eq 128 ]]; then
        log_echo "WARN" "Data directory is not in git: "$GIT_DIR""
        log_echo "INFO" "Clone branch <"$GIT_BRANCH"> in "$GIT_DIR""
        # one dir up, e.g. /tmp
        cd "$(dirname "$GIT_DIR")"
        # ... and clone branch iodata into ./iotdata
        $GIT clone "$GIT_URL" \
        --branch "$GIT_BRANCH" \
        --single-branch \
        $(basename "$GIT_DIR")
        if [[ $? -ne 0 ]]; then
            log_echo "ERROR" "GIT does not work. Abort."
            GIT_ERROR=1
            exit $GIT_ERROR
        fi
    fi
}

#
# update and configure GIT_DIR directory
#
# Param #1: GIT_DIR - the local git repo directory
# Param #2: user.name
# Param #3: user.email
# Param #4: GIT_URL - GIT repo URL including OATH toke, e.g. https://${GITHUB_OAUTH_ACCESS_TOKEN}@github.com/user/repo.git
git_update_config_dataroot() {
    local GIT_DIR=$1
    local USER_NAME=$2
    local USER_EMAIL=$3
    local GIT_URL=$4

    # Update DATAROOT directory
    cd "$GIT_DIR"
    log_echo "INFO" "Switch directory to branch <"$GIT_BRANCH"> and pull into: "$GIT_DIR""
    $GIT branch --set-upstream-to origin/"$GIT_BRANCH" "$GIT_BRANCH"
    $GIT reset --hard # throw away all uncommited changes
    $GIT checkout "$GIT_BRANCH"
    $GIT pull origin "$GIT_BRANCH"

    GIT_STATUS="$(git status --branch --short)"
    log_echo "INFO" "Git status for "$GIT_DIR" is: "$GIT_STATUS""

    # set remote url containing token var
    # each time git is used, the var should be replaced by its current value
    $GIT remote set-url --push origin "$GIT_URL"
    $GIT config user.name "$USER_NAME"
    $GIT config user.email "$USER_EMAIL"
}


#
# commit and push files in GIT_URL directory
#
# Param #1: GIT_URL - GIT repo URL
# Param #2: GIT_DIR - the local git repo directory
# Param #3: COMMIT_MSG - commit message
git_commit_push_dataroot() {
    local GIT_URL=$1
    local GIT_DIR=$2
    local COMMIT_MSG=$3
    # go into DATAROOT
    cd "$GIT_DIR"

    GIT_FILES=
    GIT_FILES="$(git status --short)"
    if [[ -z $GIT_FILES ]]; then
        log_echo "INFO" "No new files to be added for git."
        GIT_ERROR=20
    else
        # add everything into repo
        # push using github token
        $GIT add *
        $GIT commit -m "$COMMIT_MSG"
    fi
    $GIT push
    # Final error / info logging
    if [[ $? -ne 0 ]]; then
        log_echo "ERROR" "Error pushing files into branch on Github."
        GIT_ERROR=1
    else
        log_echo "INFO" "Successfully pushed data into branch on Github."
    fi

    # revert to original URL in order to avoid token to be stored
    $GIT remote set-url --push origin "$GIT_URL"
}

#
# removes untracked files from GIT_DIR directory
#
# Param #1: GIT_DIR - the local git repo directory
git_clean_repo_dir() {
    local GIT_DIR=$1
    # go into DATAROOT
    cd "$GIT_DIR"
    $GIT clean -f
    if [[ $? -ne 0 ]]; then
        log_echo "ERROR" "GIT could not clean directory: "$GIT_DIR""
    fi
}
