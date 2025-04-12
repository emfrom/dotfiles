#!/bin/bash

# Directory to work in
DIR="~/opt/org-mode"

# Navigate to the directory
cd "$DIR" || exit

# Add all changes
git add .

# Commit with the current date as the message
git commit -m "Autoupdate: $(date +'%Y-%m-%d')"

# Push to the main branch
git push origin main

