#!/bin/bash
#
# Load enivronment defaults
#

for file in *.env ; do
    [[ -f $file ]] || continue
    while IFS= read -r line ; do
	# Ignore empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        if [[ "$line" =~ ^[a-zA-Z_][a-zA-Z0-9_]*=(.*)$ ]]; then
            eval "export $line"
        else
            echo "Ignored malformatted line: $line"
        fi
    done < "$file"
done
