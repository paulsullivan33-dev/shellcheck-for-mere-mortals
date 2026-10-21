#!/bin/bash
# Ask which filesystem to check, then warn if it is at or over the limit.
limit=90
read -p "Filesystem to check [/]: " fs
if [ -z $fs ]; then
  fs=/
fi
use=`df $fs | tail -1 | awk '{print $5}' | tr -d %`
if [ $use == $limit ]; then
  echo "Exactly at the limit"
fi
if [ $use > $limit ]; then
  echo "Over the limit: $use percent used on $fs"
fi
