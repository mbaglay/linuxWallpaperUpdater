#!/bin/bash

WALLPAPER_LOGGER="WALLPAPER_LOGGER"
LOGGER_FILE="RUNNER_LOG"
NOTIFIER_LOGGER="NOTIFIER_LOGGER"
LINES_TO_SAVE_IN_LOGS=1000
IMAGE_NAME="SAVED_IMAGE.JPG"
FILE_TO_SAVE_WALLPAPER_NAME="IMAGE_NAME"
SAVE_CURRENT_WALLPAPER_LOCALLY=true
DIRECTORY_TO_SAVE_WALLPAPER="$HOME/Pictures/Wallpapers"
COPYRIGHT_FILE="COPYRIGHT"
SCRIPT_HAS_TO_SHOW_NOTOFICATIONS=true
PERIOD_OF_NOTIFICATIONS=10
NOTIFICATION_SUMMARY="Wallpaper copyright"
QUEUE_TO_RUN_AT="W"
DIRECTORY_TO_WORK="$HOME/.wallpaper_updater"
SCRIPT_IS_TURNED_ON=true
RETRIES_COUNT_IF_INTERNET_PROBLEM=10

CONFIG_FILE="$DIRECTORY_TO_WORK/wallpaper_updater.cfg"

source $CONFIG_FILE

export CONFIG_FILE
export LINES_TO_SAVE_IN_LOGS
export IMAGE_NAME
export WALLPAPER_LOGGER
export FILE_TO_SAVE_WALLPAPER_NAME
export RETRIES_COUNT_IF_INTERNET_PROBLEM
export SAVE_CURRENT_WALLPAPER_LOCALLY
export DIRECTORY_TO_SAVE_WALLPAPER
export NOTIFIER_LOGGER

SCRIPT_NAME=$(basename $0)
FULL_NAME=$DIRECTORY_TO_WORK/$SCRIPT_NAME

cd $DIRECTORY_TO_WORK

echo "" >> $LOGGER_FILE
echo "====================" >> $LOGGER_FILE
pwd >> $LOGGER_FILE
date >> $LOGGER_FILE

if [ $SCRIPT_IS_TURNED_ON = false ]; then
    echo "Script is turned off" >> $LOGGER_FILE

    kill `ps aux | grep data_notifier.sh | grep -v grep | awk '{print $2}'`
    exit 0
fi

python $DIRECTORY_TO_WORK/wallpaper_updater.py & >> $LOGGER_FILE

bash $DIRECTORY_TO_WORK/log_cleaner.sh $LOGGER_FILE $WALLPAPER_LOGGER

if [ -z "$(ps aux | grep data_notifier.sh | grep -v grep | awk '{print $2}')" ]
then
    bash $DIRECTORY_TO_WORK/data_notifier.sh &
    echo "Started notifier with PID $!" >> $LOGGER_FILE
else
    echo "Notifier is already started with PID $(ps aux | grep data_notifier.sh | grep -v grep | awk '{print $2}')" >> $LOGGER_FILE
fi

if [ -z "$(which at)" ]
then
    echo "There will not be reruns as 'at' command is not installed" >> $LOGGER_FILE
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
