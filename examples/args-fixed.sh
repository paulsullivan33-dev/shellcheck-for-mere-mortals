#!/bin/bash
# Show the script's arguments two ways: each one intact, then all
# joined into a single string on purpose.
for a in "$@"
do
  echo "intact: [$a]"
done
echo "As one string: $*"
