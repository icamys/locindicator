# Location indicator

Shows your country flag, country ISO code, and IP address of your current location.

For location detection requests to https://api.myip.com/ are made.

## Installation

1. Prepare the directory where the locindicator scripts will be stored 
(it could be any writable directory):

    ```shell script
    mkdir $HOME/Bin
    ```

1. Clone the repo

    ```shell script
    git clone http://github.com/icamys/locindicator $HOME/Bin/locindicator
    ```

1. Bootstrap the indicator.
    This command installs dependencies(jq, indicator-sysmonitor), adds sensors to indicator-sysmonitor, 
    makes it to run on system start, and starts the indicator.

    ```shell script
    $HOME/Bin/locindicator/bootstrap.sh
    ```
