#!/bin/bash

DIRECTORY_TO_WORK="$HOME/.wallpaper_updater"
LOGGER_FILE="RUNNER_LOG"

SCRIPT_NAME=$(basename $0)
FULL_NAME=$DIRECTORY_TO_WORK/$SCRIPT_NAME

cd $DIRECTORY_TO_WORK

pwd > $LOGGER_FILE
date >> $LOGGER_FILE

python $DIRECTORY_TO_WORK/wallpaper_updater.py & >> $LOGGER_FILE

echo "bash $FULL_NAME" | at now + 1 hour >>$LOGGER_FILE 2>&1
