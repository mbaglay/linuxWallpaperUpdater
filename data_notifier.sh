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
    echo "----- Startig every $PERIOD_OF_NOTIFICATIONS seconds -----" >> $DIRECTORY_TO_WORK/$NOTIFIER_LOGGER

    source $CONFIG_FILE

    bash $DIRECTORY_TO_WORK/log_cleaner.sh $DIRECTORY_TO_WORK/$NOTIFIER_LOGGER

    if [ $SCRIPT_HAS_TO_SHOW_NOTOFICATIONS = false ]
    then
        echo "Turn off showing notifictions" >> $DIRECTORY_TO_WORK/$LOGGER_FILE

        exit 0
    fi

    WORKING_WINDOW=`xdotool getwindowfocus getwindowname`

    for ((i = 0; i < ${#DESKTOP_DIRECTORIES[@]}; i++))
    do
        desktop_name="${DESKTOP_DIRECTORIES[$i]}"

        echo "Check if current window ($WORKING_WINDOW) is equal to desktop name ($desktop_name)" >> $DIRECTORY_TO_WORK/$NOTIFIER_LOGGER

        if [ "$WORKING_WINDOW" == "$desktop_name" ]
        then
            echo "Found $desktop_name is equal to current window $WORKING_WINDOW" >> $DIRECTORY_TO_WORK/$NOTIFIER_LOGGER
            notify-send "$NOTIFICATION_SUMMARY" "`cat $DIRECTORY_TO_WORK/$COPYRIGHT_FILE`" -t $PERIOD_OF_NOTIFICATIONS -i $DIRECTORY_TO_WORK/$IMAGE_NAME
        fi
    done

    sleep $((PERIOD_OF_NOTIFICATIONS + 1))
done
