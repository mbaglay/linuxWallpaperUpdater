#!/bin/bash

if [ -n $LINES_TO_SAVE_IN_LOGS ] ; then
    LINES_TO_SAVE_IN_LOGS=1000
fi

for log_file in $@
do
    new_log=$log_file.temp.file

    tail -n $LINES_TO_SAVE_IN_LOGS $log_file >> $new_log
    cp $new_log $log_file
    rm $new_log
done