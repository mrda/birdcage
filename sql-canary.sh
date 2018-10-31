#!/bin/sh
#
# sql-canary.sh - Ensure there's no SQL dumps, compressed or not, in
#                 web server docroot
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
CANARY_DOCROOT="${CANARY_DOCROOT:-/var/www/html}"
SUPPORTED_SUFFIXES=("" ".gz" ".Z" ".bz" ".bz2" ".tgz" ".cpio" ".pax" ".zip" ".rar" ".rsrc")
BASE_SUFFIX=".sql"
CHOSEN_DATE=10
# End user-editable bits


# We're only going to generate output if we find something out of place
# or if it's the 1st of the month,
# or if the command line switch asking for output is provided
DISPLAY_OUTPUT=0

# Build up a list of all file suffixes we should check for
SUFFIXES=()
for i in "${SUPPORTED_SUFFIXES[@]}"
do
    SUFFIXES+=(${i})
done
for i in "${SUPPORTED_SUFFIXES[@]}"
do
    SUFFIXES+=(${BASE_SUFFIX}${i})
done

# Thanks https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -a|--add-suffix)
        SUFFIXES+=(${2})
        shift # past argument
        shift # past value
        ;;
        -d|--docroot)
        CANARY_DOCROOT="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        HELP=1
        shift # past argument
        ;;
        -o|--output)
        DISPLAY_OUTPUT=1
        shift # past argument
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
    printf "${SCRIPT}: Look for SQL dumps that shouldn't be there.\n"
    printf "Usage: ${SCRIPT} [options]\n"
    display_cmd_option "-a" "--add-suffix" "<suffix>" "Add <suffix> to list to search for"
    display_cmd_option "-d" "--docroot"    "<dir>"    "Search in directory <dir>, otherwise use the environment variable CANARY_DOCROOT"
    display_cmd_option "-h" "--help"       "${BLANK}" "Display this help information"
    display_cmd_option "-o" "--output"     "${BLANK}" "Always print the output of the search"
    display_cmd_option "-v" "--verbose"    "${BLANK}" "Be verbose about what we're doing"

    printf "\n"
    printf "If you want this to run automatically, add the following line to your crontab:\n"
    printf "\t0 3 * * * /directory/to/${SCRIPT}\n"

fi

#
# Be verbose
#
if [[ ! -z ${VERBOSE} ]]
then
    echo -n "Searching for files with the following suffixes: "
    for i in "${SUFFIXES[@]}"
    do
        echo -n "$i "
    done
    echo
    echo "Searching in directory: ${CANARY_DOCROOT}"
    echo "Print output of the search? ${DISPLAY_OUTPUT}"
fi

#
# Force output once per month
#
DATE=$(date +%d)
if [[ ${DATE} -eq ${CHOSEN_DATE} ]]
then
    printf "${SCRIPT}: Forcing output one day per month\n"
    DISPLAY_OUTPUT=1
fi

#
# Now do what we came here to do
#
TMPFILE=$(mktemp /tmp/${SCRIPT}.XXXXX)

for i in "${SUFFIXES[@]}"
do
    THIS="*${i}"
    find ${CANARY_DOCROOT} -name "${THIS}" -print >> ${TMPFILE} 2>/dev/null
done

OUTPUT=$(sort ${TMPFILE} | uniq)

if [[ ${DISPLAY_OUTPUT} -eq 1 ]] || [[ ! -z ${OUTPUT} ]]
then
    echo "Files that might be dubious:"
fi

if [[ ! -z ${OUTPUT} ]]
then
    echo ${OUTPUT}
    exit 1
else
    if [[ ${DISPLAY_OUTPUT} -eq 1 ]]
    then
        echo "<<< No files found \o/ >>>"
    fi
fi

# Cleanup
rm ${TMPFILE}
