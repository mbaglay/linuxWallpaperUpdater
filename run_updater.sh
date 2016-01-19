#!/bin/bash

DIRECTORY_TO_WORK="$HOME/.wallpaper_updater"
LOGGER_FILE="RUNNER_LOG"

cd $DIRECTORY_TO_WORK

pwd > $LOGGER_FILE
date >> $LOGGER_FILE

python $DIRECTORY_TO_WORK/wallpaper_updater.py & >> $LOGGER_FILE