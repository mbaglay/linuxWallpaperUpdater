#!/bin/bash

QUEUE_TO_RUN_AT="W"

DIRECTORY_TO_WORK="$HOME/.wallpaper_updater"
LOGGER_FILE="RUNNER_LOG"

export LINES_TO_SAVE_IN_LOGS=10
export IMAGE_NAME="SAVED_IMAGE.JPG"
export WALLPAPER_LOGGER="WALLPAPER_LOGGER"

SCRIPT_NAME=$(basename $0)
FULL_NAME=$DIRECTORY_TO_WORK/$SCRIPT_NAME

cd $DIRECTORY_TO_WORK

echo "" >> $LOGGER_FILE
echo "====================" >> $LOGGER_FILE
pwd >> $LOGGER_FILE
date >> $LOGGER_FILE

python $DIRECTORY_TO_WORK/wallpaper_updater.py & >> $LOGGER_FILE

bash $DIRECTORY_TO_WORK/log_cleaner.sh $LOGGER_FILE $WALLPAPPER_LOGGER

if [ -z "$(which at)" ]
then
    echo "There will not be rerunnings as 'at' command is not installed" >> $LOGGER_FILE
    echo "Please, install it if you want this tool to periodically run" >> $LOGGER_FILE

    exit 0
fi

if [ -z "$(at -l -q $QUEUE_TO_RUN_AT)" ]
then
    echo "Queue is empty" >> $LOGGER_FILE

    echo "bash $FULL_NAME" | at now + 1 hour -q $QUEUE_TO_RUN_AT >>$LOGGER_FILE 2>&1
else
    echo "Queue is not empty" >> $LOGGER_FILE
fi
