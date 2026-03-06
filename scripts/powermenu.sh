#!/usr/bin/env bash

# Define the menu options
options="Lock\nLogout\nReboot\nShutdown\nSuspend"

# Use rofi to select an option
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu:" -theme-str 'window {width: 20%;}')

case "$chosen" in
    Lock)
        loginctl lock-session
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    Suspend)
        systemctl suspend
        ;;
    *)
        exit 0
        ;;
esac
