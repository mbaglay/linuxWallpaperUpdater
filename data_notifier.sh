#!/bin/bash

source $CONFIG_FILE

if [ -z "$(which xdotool)" ]
then
    echo "There will not be notification as 'xdotool' command is not installed" >> $DIRECTORY_TO_WORK/$LOGGER_FILE
    echo "Please, install it if you want this tool to show copyright info" >> $DIRECTORY_TO_WORK/$LOGGER_FILE

    exit 0
fi

while true
do
    source $CONFIG_FILE

    if [ $SCRIPT_HAS_TO_SHOW_NOTOFICATIONS = false ]
    then
        echo "Turn off showing notifictions" >> $DIRECTORY_TO_WORK/$LOGGER_FILE

        exit 0
    fi

    WORKING_WINDOW=`xdotool getwindowfocus getwindowname`

    for ((i = 0; i < ${#DESKTOP_DIRECTORIES[@]}; i++))
    do
        desktop_name="${DESKTOP_DIRECTORIES[$i]}"

        if [ "$WORKING_WINDOW" == "$desktop_name" ]
        then
            notify-send "$NOTIFICATION_SUMMARY" "`cat $DIRECTORY_TO_WORK/$COPYRIGHT_FILE`" -t $PERIOD_OF_NOTIFICATIONS -i $DIRECTORY_TO_WORK/$IMAGE_NAME
        fi
    done

    sleep $((PERIOD_OF_NOTIFICATIONS + 1))
done
