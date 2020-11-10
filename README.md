# Location indicator

Shows your country flag, country ISO code, and IP address of your current location in the system tray.

For location detection requests to https://api.myip.com/ are made.

## Installation

1. Create the directory where the locindicator scripts will be stored 
(it could be any writable directory):

    ```shell script
    mkdir -p $HOME/Bin
    ```

1. Clone the repo

    ```shell script
    git clone http://github.com/icamys/locindicator $HOME/Bin/locindicator
    ```

1. Bootstrap the indicator.

    This command installs dependencies([jq](https://github.com/stedolan/jq), [indicator-sysmonitor](https://github.com/fossfreedom/indicator-sysmonitor)),
    adds sensors to indicator-sysmonitor, configures it to run on system start, and starts the indicator.

    ```shell script
    $HOME/Bin/locindicator/bootstrap.sh
    ```
