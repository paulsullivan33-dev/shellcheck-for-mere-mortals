#!/bin/bash
# Copy the documents folder to the backup drive, dated by day.
src=$HOME/documents
dst=/mnt/backupdrive
stamp=$(date +%F)
mkdir -p "$dst/$stamp"
cp -r "$src" "$dst/$stamp"
wc -l < "$dst/$stamp/documents/list.txt"
echo "Backup finished at $(date +%T)"
