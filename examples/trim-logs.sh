#!/bin/sh
# Keep only the last 500 lines of each log in the app's log folder.
logdir=/var/log/myapp
keep=500
scratch=/var/tmp
cd $logdir
for log in *.log
do
  tail -n $keep $log > $log.tmp
  mv $log.tmp $log
done
echo Trimmed on `date +%F`
