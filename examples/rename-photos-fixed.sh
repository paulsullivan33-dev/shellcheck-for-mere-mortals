#!/bin/bash
# Rename every .JPG photo in a folder to IMG-<date>-<number>.jpg
dir=${1:?usage: rename-photos-fixed.sh FOLDER}
cd "$dir" || exit 1
n=1
for f in ./*.JPG
do
  newname=IMG-$(date +%Y%m%d)-$n.jpg
  mv -- "$f" "$newname"
  n=$((n + 1))
done
echo "All done in $dir"
