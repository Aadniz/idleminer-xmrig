# idleminer-xmrig
A simple bash script to detect when computer is idle, and start xmrig
The script is meant to run on a active used computer that is on 24/7

## Sceenshots
*Sound was last heard 30 seconds ago, last movement was 16 seconds ago*
![counting up](/screenshots/Screenshot_20200731_053636.png "counting up")

*Sound was last heard 885 seconds ago, last movement was 37 seconds ago*
![counting up](/screenshots/Screenshot_20200731_055052.png "counting up")

*Idle has begun, starting xmrig*
![Running and starting](/screenshots/Screenshot_20200731_041305.png "Running and starting")

## Dependencies
- xprintidle

## Possible dependencies
- [xmrig](https://github.com/xmrig/xmrig)
- [ethminer](https://github.com/ethereum-mining/ethminer)
- [BFGMiner](http://bfgminer.org/)

## Setting up
Download the idleminer.sh script, open it in the editor, and set the `executables` variable to the desired command(s) / location(s).
It might look something like this:

    executables=(
        "xmrig -c /home/chiya/.config/xmrig/monero.json"
        "ethminer -G -P stratum1+tcp://[YOUR ETHEREUM WALLET]@eu1.ethpool.org:3333"
    );

On the top of the script, there is also a few variables you can change:

    # Time between each check
    sleepValue=3;
    
    # Idle seconds before starting xmrig
    startAt=480;
    
    # Number of times signs of user movement before stopping xmrig
    # Setting this to 0 might cause the program to start and stop many times during idle
    # Setting this too high might cause it to not stop at all
    # Recommend between 3 and 10
    userBackRetries=3;
    
    # Path to executables (path(s) and/or command(s) works)
    executables=(
        "xmrig -c /home/chiya/.config/xmrig/monero.json"
        "ethminer -G -P stratum1+tcp://[YOUR ETHEREUM WALLET]@eu1.ethpool.org:3333"
    );
    
    
    # It wasn't so easy to detect if any sound is being played
    # Some programs will be detected as playing sound even tho it might not
    #
    # Please open all the programs you normally have open, make sure no sounds are being played, and run this command:
    #   pacmd list-sink-inputs | grep -c 'state: RUNNING'
    #
    # This will be your standpoint of what "no sound" is.
    # Normally, it will be 0, but some programs ( like kdenlive ) will increse this number to 1 even if no sound is played.
    noSoundValue=0

## Usage
Running the script as root is recommended to get the best hash value

    sudo su
    bash idleminer.sh


## Known bugs
`pacmd list-sink-inputs` returns `No PulseAudio daemon running, or not running as session daemon.` (This has been commented out)
