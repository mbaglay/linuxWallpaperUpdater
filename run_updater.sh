#!/bin/bash

QUEUE_TO_RUN_AT="W"

DIRECTORY_TO_WORK="$HOME/.wallpaper_updater"
LOGGER_FILE="RUNNER_LOG"

SCRIPT_NAME=$(basename $0)
FULL_NAME=$DIRECTORY_TO_WORK/$SCRIPT_NAME

cd $DIRECTORY_TO_WORK

pwd > $LOGGER_FILE
date >> $LOGGER_FILE

python $DIRECTORY_TO_WORK/wallpaper_updater.py & >> $LOGGER_FILE

if [ -z "$(at -l -q $QUEUE_TO_RUN_AT)" ]
then
    echo "Queue is empty" >> $LOGGER_FILE

    echo "bash $FULL_NAME" | at now + 1 hour -q $QUEUE_TO_RUN_AT >>$LOGGER_FILE 2>&1
else
    echo "Queue is not empty" >> $LOGGER_FILE
fi
