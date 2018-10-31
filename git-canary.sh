#!/bin/sh
#
# git-canary.sh - Ensure that there's no changes to a deployed git checkout
#
# Copyright (C) 2018 Michael Davies <michael@the-davies.net>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#

SCRIPT=$(basename $0)

# User-editable bits
CHOSEN_DATE=10
# End user-editable bits

# We're only going to generate output if we find something out of place
# or if it's on the specified day of the month
# or we've been asked to be verbose
DISPLAY_OUTPUT=0

# Thanks https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -g|--git-dir)
        CANARY_GIT_DIR="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        HELP=1
        shift # past argument
        ;;
        -w|--work-dir)
        CANARY_WORK_DIR="$2"
        shift # past argument
        shift # past value
        ;;
        -v|--verbose)
        VERBOSE=1
        shift # past argument
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

#
# Display help
#
BLANK=" "
display_cmd_option ()
{
    printf "  %-2s  %-13s  %-8s  %-44s\n" "$1" "$2" "$3" "$4"
}
if [[ ! -z ${HELP} ]]
then
    printf "${SCRIPT}: See if there's any local modifications to a git checkout\n"
    printf "Usage: ${SCRIPT} [options]\n"
    display_cmd_option "-g" "--git-dir"  "<dir>"    "The git repository directory (optional).  Uses CANARY_GIT_DIR environment variable otherwise"
    display_cmd_option "-h" "--help"     "${BLANK}" "Display this help information"
    display_cmd_option "-v" "--verbose"  "${BLANK}" "Be verbose about what we're doing"
    display_cmd_option "-w" "--work-dir" "<dir>"    "The git checkout directory.  Uses CANARY_WORK_DIR environment variable otherwise"

    printf "\n"
    printf "If you want this to run automatically, add the following line to your crontab:\n"
    printf "\t0 3 * * * /directory/to/${SCRIPT}\n"
fi

#
# Ensure we know what the directory to check is, and what the git dir is
#
if [[ -z "${CANARY_WORK_DIR}" ]]
then
    printf "${SCRIPT}: You need to define the git checkout directory in CANARY_WORK_DIR or specify it via the -w <dir> parameter\n"
    exit 1
fi

if [[ -z "${CANARY_GIT_DIR}" ]]
then
    # Assume that the git repository directory is $CANARY_WORK_DIR/.git if it
    # isn't specified
    CANARY_GIT_DIR=${CANARY_WORK_DIR}/.git
fi

#
# Force output once per month
#
DATE=$(date +%d)
if [[ ${DATE} -eq ${CHOSEN_DATE} ]]
then
    printf "${SCRIPT}: Forcing output one day per month\n"
    VERBOSE=1
fi

#
# Be verbose
#
if [[ ! -z ${VERBOSE} ]]
then
    printf "Checkout directory: ${CANARY_WORK_DIR}\n"
    printf "Git Repository directory: ${CANARY_GIT_DIR}\n"
    DISPLAY_OUTPUT=1
fi

#
# Now do what we came here to do
#
EXTRA_OPTS="-s"
if [[ ${DISPLAY_OUTPUT} -eq 1 ]]
then
    EXTRA_OPTS=""
fi

git --work-tree=${CANARY_WORK_DIR} --git-dir=${CANARY_GIT_DIR} status ${EXTRA_OPTS}

