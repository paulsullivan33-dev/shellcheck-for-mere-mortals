#!/bin/bash
# A pocketful of test idioms. Some are sound; two are traps.
name=$1
count=$2
if [ -n $name ]; then
  echo "Name given"
fi
if [ $count == 3 ]; then
  echo "Three"
fi
if [[ $count > 2 ]]; then
  echo "More than two"
fi
