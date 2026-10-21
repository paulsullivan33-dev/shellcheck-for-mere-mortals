#!/bin/bash
# Show the script's arguments three ways. Two of the three split
# names that contain spaces into pieces.
echo "As one string: $*"
for a in $*
do
  echo "split by star: [$a]"
done
for a in $@
do
  echo "split by at: [$a]"
done
