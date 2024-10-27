#!/usr/bin/env bash

#####
#
# Auto-tangle script for dotfiles
#

# Check for emacs
if ! command -v emacs &> /dev/null ; then
    echo "Emacs needed for this script to run"
    exit 0
fi

# Check for git
if ! command -v git &> /dev/null ; then
    echo "git needed for this script to run"
    exit 0
fi

# Check if in a Git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null ; then
    echo "Not in a git repository"
    echo "to continue run:"
    echo "git clone https://github.com/emfrom/dotfiles.git"
    exit 0
fi

# Find all org mode files
org_files=$(git ls-files '*.org')

# Check if any .org files were found
if [ -z "$org_files" ]; then
    echo "No .org files found in the repository."
    echo "to continue run:"
    echo "git clone https://github.com/emfrom/dotfiles.git"
    exit 0
fi

# Construct a lisp snippet for emacs to run
elisp_code="(progn (require 'org) "
for file in $org_files; do
    elisp_code="$elisp_code (org-babel-tangle-file \"$file\")"
done
elisp_code="$elisp_code)"

# Run the Emacs command with the constructed Elisp code
# Note: Doing this without user init files as that seems to screw up the process
if ! emacs --batch --eval "$elisp_code" 2>&1 | grep "Tangled" ; then
    echo -e "\nSomething went wrong"
    echo "In all probability org-mode is not installed in your copy of emacs"
else
    echo -e "\nAll done"
fi
