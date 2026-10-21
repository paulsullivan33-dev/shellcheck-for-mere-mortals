#!/bin/bash
# Copy the documents folder to the backup drive, dated by day.
src=$HOME/documents
dst=/mnt/backupdrive
stamp=`date +%F`
mkdir -p $dst/$stamp
cp -r $src $dst/$stamp
cat "$dst/$stamp/documents/list.txt" | wc -l
echo Backup finished at `date +%T`
speed=fast
