#!/bin/bash

DIRECTORY_TO_INSTALL="$HOME/.wallpaper_updater"
PROFILE="$HOME/.profile"
COMMAND_TO_RUN_UPDATER="bash $DIRECTORY_TO_INSTALL/run_updater.sh"
RUN_AFTER_INSTALL=true

while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        -h|--help)
            echo ""
            echo "Tool to daily update wallpaper from Bing Homepage Gallery"
            echo "  Run this file to install the tool to $DIRECTORY_TO_INSTALL"
            echo "  Use --do-not-run parameter if you do not want the tool to run just after installation"
            exit 0
        ;;
        --do-not-run)
            RUN_AFTER_INSTALL=false
        ;;
        *)
            # Unknown option
        ;;
    esac
    shift
done

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

if [ $RUN_AFTER_INSTALL = true ]; then
    cd $DIRECTORY_TO_INSTALL
    $COMMAND_TO_RUN_UPDATER

    echo "Script started to work."
fi
