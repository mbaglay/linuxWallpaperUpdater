#!/bin/bash

DIRECTORY_TO_INSTALL="$HOME/.wallpaper_updater"
BASH_RC="$HOME/.bashrc"
COMMAND_TO_RUN_UPDATER="python $DIRECTORY_TO_INSTALL/wallpaper_updater.py &"

mkdir -p $DIRECTORY_TO_INSTALL

cp -a . $DIRECTORY_TO_INSTALL/.

if grep -Fxq "$COMMAND_TO_RUN_UPDATER" $BASH_RC
then
    echo "Already installed!!!"
else
    echo "" >> $BASH_RC
    echo $COMMAND_TO_RUN_UPDATER >> $BASH_RC
fi