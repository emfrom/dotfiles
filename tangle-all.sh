#!/usr/bin/env bash

#####
#
# Auto-tangle script for org files
#
# Use for convenience or as a git hook
#
# Questions or comments: <vertlaforet@protonmail.com>
#

# Check for emacs
if ! command -v emacs &> /dev/null ; then
    echo "Emacs needed for this script to run"
    exit 1
fi


# Check that org is installed
if [[ "nil" == $(emacs --batch --eval "(if (require 'org nil 'noerror) (princ t) (princ nil))" 2> /dev/null) ]] ; then
    echo -e "Org mode is not installed\n"
    echo "Try:"
    echo " emacs README.org"
    echo " Hit ALT-x"
    echo " Type: org-babel-tangle-file"
    echo -e " Hit Enter\n"
    echo " If that doesnt work, click on the link for the video series in the README" 
    exit 1
fi


# Check that org is high enough version
#
# Note: There is no specific reason for 9.6.15, it just happened to be the oldest I had laying around
version_target="9.6.15"
version=$(emacs --batch --eval "(progn (require 'org) (print (org-version)))" 2> /dev/null)
version=$(echo $version | awk -F'"' '{gsub(/"/, "", $2); print $2}')

if [[ ! "$(echo -e "${version}\n${version_target}" | sort -V | awk 'NF {print; exit}')" == "$version_target" ]]; then
    echo "Version ${version_target} or higher of org mode is known to work (but we try anyway)"
fi


# Check for git
if ! command -v git &> /dev/null ; then
    echo "git needed for this script to run"
    exit 1
fi


# Check if in a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null ; then
    echo "Not in a git repository"
    exit 1
fi


# Find all org files in the repo
org_files=$(git ls-files '*.org')


# Check if any org files were found
if [ -z "$org_files" ]; then
    echo "No org files found in the repo"
    exit 1
fi


# Construct a lisp snippet for emacs to run
elisp_code="(progn (require 'org) "
for file in $org_files; do
    elisp_code="$elisp_code (org-babel-tangle-file \"$file\")"
done
elisp_code="$elisp_code)"


# Run the code snippet in emacs
# Note: Doing this without user init files as doing so ends badly more often than not
if ! emacs --batch --eval "$elisp_code" 2>&1 | grep "Tangled"; then
    echo -e "\nSomething went wrong"
    echo "In all probability org-mode is not installed properly or too old a version"
    exit 1
fi


echo -e "\nAll done"
