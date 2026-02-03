# Location indicator

Shows your country flag, country ISO code, and IP address of your current location in the system tray.

For location detection requests to https://api.myip.com/ are sent each 15 seconds.

![example of indicator](./image.png)

## Requirements

* python3

Other requirements that will be installed automatically:
* [jq](https://jqlang.org/) - used to parse JSON responses from location API
* [indicator-sysmonitor](https://github.com/fossfreedom/indicator-sysmonitor) - used to display the location information in the system tray
* [meson](https://mesonbuild.com/) - used during installation of indicator-sysmonitor
* git - used to clone the indicator-sysmonitor repository and checkout the tested version
* python3-psutil

## Installation

1. Create a directory to store locindicator scripts. It could be any writable directory accessible by your user.

    ```shell script
    mkdir -p $HOME/Bin
    ```

2. Clone the repo.

    ```shell
    git clone https://github.com/icamys/locindicator.git $HOME/Bin/locindicator
    ```

3. Install the dependencies.

   This script requires root privileges to install ([jq](https://github.com/stedolan/jq),
   [indicator-sysmonitor](https://github.com/fossfreedom/indicator-sysmonitor)).

    ```shell
    sudo $HOME/Bin/locindicator/install.sh
    ```

4. Bootstrap the indicator. 

    **Attention! Execute this command on behalf of the user, that is running the graphical interface. 
    Otherwise, the indicator won't appear.** Usually, it means that you should run it without `sudo`.

    The script adds sensors to indicator-sysmonitor, configures it to run on system start, and starts the indicator.

    ```shell
    $HOME/Bin/locindicator/bootstrap.sh
    ```

## Uninstallation

The following script will stop and remove the currently running indicator, and remove its configuration file.
The restart is still possible with after executing `install.sh` and `bootstrap.sh` scripts

```
$HOME/Bin/locindicator/uninstall.sh
```

## Compatibility

Tested on:
- Ubuntu 24.04
- Ubuntu 22.04
