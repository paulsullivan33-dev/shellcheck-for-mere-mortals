#!/bin/bash
# Print a one-line summary of a folder: how many files, how much space.
set -u
folder=${1:-.}
count=$(find "$folder" -type f | wc -l)
size=$(du -sh -- "$folder" | cut -f1)
printf '%s: %s files, %s total\n' "$folder" "$count" "$size"
