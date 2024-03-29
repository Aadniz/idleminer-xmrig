#!/bin/bash

##
#  // General Info
##

# For best mining performance, you should run this script as root (sudo su, bash idleminer.sh)
#

# Creator:
#   psudo name:     Aadniz (aka: Typewar / D3faIt)
#   GitHub:         https://github.com/Aadniz
#   Creation date:  30-07-2020


##
#  // User adjustments
##


# Path to executables (path(s) and/or command(s) works)
executables=(
    "xmrig -c /home/USERNAME/.config/xmrig/monero.json" # in my example, I set xmrig and gminer to run
    "miner --algo cuckatoo31 --server mwc.2miners.com:1111 --user WALLETADDRESS.MINERNAME"
);

# Time between each check
sleepValue=3;

# Idle seconds before starting xmrig
startAt=500;

# Number of times signs of user movement before stopping xmrig
# Setting this to 0 might cause the program to start and stop many times during idle
# Setting this too high might cause it to not stop at all
# Recommend between 3 and 10
userBackRetries=3;


# It wasn't so easy to detect if any sound is being played
# Some programs will be detected as playing sound even tho it might not
#
# Please open all the programs you normally have open, make sure no sounds are being played, and run this command:
#   pacmd list-sink-inputs | grep -c 'state: RUNNING'
#
# This will be your standpoint of what "no sound" is.
# Normally, it will be 0, but some programs ( like kdenlive ) will increse this number to 1 even if no sound is played.
noSoundValue=0


##
#  // Random code underneeth
##

# Declarations
idleSoundTimer=0;
xmrigRunning=0;
currentRetries=0;

PURPLE='\033[0;45m\033[01m'
GREEN='\033[0;92m\033[01m'
YELLOW='\033[0;93m\033[01m'
GRAY='\033[0;90m\033[01m'
RESETCOLOR='\033[0;0m'

statusBox="$PURPLE script  $RESETCOLOR"



# Aaaaand the rest...

check_if_running(){
    stringarray=($i2); firstword=${stringarray[0]};
    isItRunning=$(pgrep -f $firstword)
    get_syntaxBox;
    if [[ $? != 0 ]]; then
        echo -e "$syntaxBox Application is not running";
        isRunning="120109114105103"
    elif [[ $isItRunning ]]; then
        isRunning=$isItRunning
        re='^[0-9]+$'
        if ! [[ $isRunning =~ $re ]] ; then
            echo -e "$syntaxBox Multiple processes running by this name";
            isRunning="120109114105103"
        fi
    else
        echo -e "$syntaxBox Application is not running";
        isRunning="120109114105100"
    fi
}


stop_mining(){
    for i2 in "${executables[@]}"; do
        check_if_running;
        get_syntaxBox;
        if [ "$isRunning" -eq "120109114105103" ]; then # 120109114105103 to prevent accidental kill of process 0
            echo -e "$syntaxBox Skipping process termination";
            xmrigRunning=1;
        else
            if [ "$isRunning" -eq "120109114105100" ]; then # 120109114105103 to prevent accidental kill of process 0, not running
                echo -e "$syntaxBox Continuing";
                sleep 3
            else
                kill -2 $isRunning;
                echo -e "$syntaxBox Stopping: $i2";
                sleep 3
            fi
        fi
    done
    echo -e "$syntaxBox Mining Stopped!";
}

start_mining(){
    get_syntaxBox;
    echo ""
    echo -e "$syntaxBox Mining Started!";
    #$xmrigDir$xmrigName &
    for i in "${executables[@]}"; do
        $i &
    done
}

get_time(){
    msTime=$(date +"%N");
    thaTime=$(date +"%Y-%m-%d %T")$GRAY.${msTime:0:3}$RESETCOLOR;
}

get_syntaxBox(){
    get_time;
    syntaxBox="[$thaTime] $statusBox";
}

while :; do
    idleSound=$(sudo -u '#1000' XDG_RUNTIME_DIR=/run/user/1000 pactl list | grep -c 'State: RUNNING');
    #idleSound="0"

    # Idle screen in ms
    tempidleScreen=$(sudo -u '#1000' XDG_RUNTIME_DIR=/run/user/1000 DISPLAY=:0 xprintidle);
    # Idle screen in s
    idleScreen=$((tempidleScreen / 1000));

    # Detect when no audio is being played
    if [ "$idleSound" -eq "$noSoundValue" ]; then
        idleSoundTimer=$(($idleSoundTimer + $sleepValue));
    else
        idleSoundTimer=0;
    fi

    # Detect when sceen movement
    # this is only used to stopping xmrig
    if [ "$idleScreen" -lt "$sleepValue" ]; then
        currentRetries=$(($currentRetries + 1));
    else
        currentRetries=0;
    fi

    if [ "$idleSoundTimer" -gt "$startAt" ]; then
        if [ "$idleScreen" -gt "$startAt" ]; then
            if [ "$xmrigRunning" -eq "0" ]; then
                xmrigRunning=1;
                start_mining;
            fi
        fi
    fi


    if [ "$currentRetries" -eq "$userBackRetries" ]; then
        if [ "$xmrigRunning" -eq "1" ]; then
            xmrigRunning=0;
            stop_mining;
        fi
    fi

    if [ "$xmrigRunning" -eq "0" ]; then
        get_syntaxBox;
        if [[ "$idleSoundTimer" -gt "$startAt" && "$idleScreen" -gt "$startAt" ]]; then
            echo -ne "$syntaxBox SoundTimer ($GREEN $idleSoundTimer$RESETCOLOR of $GREEN$startAt$RESETCOLOR ) ScreenTimer ( $GREEN$idleScreen$RESETCOLOR of $GREEN$startAt$RESETCOLOR )                      "\\r;
        elif [[ "$idleSoundTimer" -gt "$startAt" && "$idleScreen" -lt "$startAt" ]]; then
            echo -ne "$syntaxBox SoundTimer ($GREEN $idleSoundTimer$RESETCOLOR of $GREEN$startAt$RESETCOLOR ) ScreenTimer ( $YELLOW$idleScreen$RESETCOLOR of $YELLOW$startAt$RESETCOLOR )                      "\\r;
        elif [[ "$idleSoundTimer" -lt "$startAt" && "$idleScreen" -gt "$startAt" ]]; then
            echo -ne "$syntaxBox SoundTimer ($YELLOW $idleSoundTimer$RESETCOLOR of $YELLOW$startAt$RESETCOLOR ) ScreenTimer ( $GREEN$idleScreen$RESETCOLOR of $GREEN$startAt$RESETCOLOR )                      "\\r;
        elif [[ "$idleSoundTimer" -lt "$startAt" && "$idleScreen" -lt "$startAt" ]]; then
            echo -ne "$syntaxBox SoundTimer ($YELLOW $idleSoundTimer$RESETCOLOR of $YELLOW$startAt$RESETCOLOR ) ScreenTimer ( $YELLOW$idleScreen$RESETCOLOR of $YELLOW$startAt$RESETCOLOR )                      "\\r;
        fi;
        
    fi;
    sleep $((sleepValue));

done
