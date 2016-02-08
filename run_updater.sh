#!/bin/bash

QUEUE_TO_RUN_AT="W"

DIRECTORY_TO_WORK="$HOME/.wallpaper_updater"
LOGGER_FILE="RUNNER_LOG"

TURNED_OFF_FILE="SCRIPT_IS_TURNED_OFF"

export LINES_TO_SAVE_IN_LOGS=1000
export IMAGE_NAME="SAVED_IMAGE.JPG"
export WALLPAPER_LOGGER="WALLPAPER_LOGGER"
export FILE_TO_SAVE_WALLPAPER_NAME="IMAGE_NAME"

SCRIPT_NAME=$(basename $0)
FULL_NAME=$DIRECTORY_TO_WORK/$SCRIPT_NAME

cd $DIRECTORY_TO_WORK

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        --switch-on)
            rm -f $TURNED_OFF_FILE
        ;;
        --switch-off)
            touch $TURNED_OFF_FILE
        ;;
        *)
            # Unknown option
        ;;
    esac
    shift
done

echo "" >> $LOGGER_FILE
echo "====================" >> $LOGGER_FILE
pwd >> $LOGGER_FILE
date >> $LOGGER_FILE

if [ -f $TURNED_OFF_FILE ]; then
    echo "Script is turned off" >> $LOGGER_FILE
    exit 0
fi

python $DIRECTORY_TO_WORK/wallpaper_updater.py & >> $LOGGER_FILE

bash $DIRECTORY_TO_WORK/log_cleaner.sh $LOGGER_FILE $WALLPAPER_LOGGER

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
