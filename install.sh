#!/bin/bash

DIRECTORY_TO_INSTALL="$HOME/.wallpaper_updater"
PROFILE="$HOME/.profile"
COMMAND_TO_RUN_UPDATER="bash $DIRECTORY_TO_INSTALL/run_updater.sh"

mkdir -p $DIRECTORY_TO_INSTALL

for file in `ls -p`
do
    cp $file $DIRECTORY_TO_INSTALL/$file
done

if grep -Fxq "$COMMAND_TO_RUN_UPDATER" $PROFILE
then
    echo "Already installed!!!"
else
    echo "" >> $PROFILE
    echo $COMMAND_TO_RUN_UPDATER >> $PROFILE
fi