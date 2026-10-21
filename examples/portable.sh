#!/bin/sh
# Greet the user by name. Written and tested on a bash machine,
# then promised to the world as portable sh.
name=$1
if [[ $name == admin* ]]; then
  echo "Welcome, boss"
else
  echo "Hello, $name"
fi
days=(mon tue wed thu fri)
echo "Today is ${days[0]}"
lucky=$((RANDOM % 10))
echo "Your lucky number is $lucky"
