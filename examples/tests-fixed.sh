#!/bin/bash
# A pocketful of test idioms, written soundly.
name=${1:-}
count=${2:-0}
if [ -n "$name" ]; then
  echo "Name given"
fi
if [ "$count" -eq 3 ]; then
  echo "Three"
fi
if [[ $count -gt 2 ]]; then
  echo "More than two"
fi
