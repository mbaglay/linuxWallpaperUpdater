#!/bin/bash

DIRECTORY_TO_INSTALL="$HOME/.wallpaper_updater"
PROFILE="$HOME/.profile"
COMMAND_TO_RUN_UPDATER="bash $DIRECTORY_TO_INSTALL/run_updater.sh"

mkdir -p $DIRECTORY_TO_INSTALL

cp -a . $DIRECTORY_TO_INSTALL/.

if grep -Fxq "$COMMAND_TO_RUN_UPDATER" $PROFILE
then
    echo "Already installed!!!"
else
    echo "" >> $PROFILE
    echo $COMMAND_TO_RUN_UPDATER >> $PROFILE
fi