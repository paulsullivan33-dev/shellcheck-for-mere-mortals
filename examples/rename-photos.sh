#!/bin/bash
# Rename every .JPG photo in a folder to IMG-<date>-<number>.jpg
# Written in a hurry. It works — on filenames without spaces.
dir=$1
cd $dir
n=1
for f in `ls *.JPG`
do
  newname=IMG-`date +%Y%m%d`-$n.jpg
  mv $f $newname
  n=`expr $n + 1`
done
echo All done: $@
