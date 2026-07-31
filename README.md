# Location indicator

Shows your country flag, country ISO code, and IP address of your current location in the system tray. Clicking the tray icon also gives you an **IP History** entry showing every IP change ever noticed (timestamp + IP, newest first, last 100 kept), including ones noticed right after a restart.

For location detection requests to https://api.myip.com/ are sent each 15 seconds.

![example of indicator](./image.png)

## Requirements

* python3

Other requirements that will be installed automatically:
* [jq](https://jqlang.org/) - used to parse JSON responses from location API
* wget - used to fetch the location API and download country flag SVGs
* python3-gi, gir1.2-appindicator3-0.1 - GTK/AppIndicator bindings used to display the tray icon and its dropdown

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

   This script requires root privileges to install ([jq](https://github.com/stedolan/jq) and the GTK/AppIndicator bindings).

    ```shell
    sudo $HOME/Bin/locindicator/install.sh
    ```

4. Bootstrap the indicator. 

    **Attention! Execute this command on behalf of the user, that is running the graphical interface. 
    Otherwise, the indicator won't appear.** Usually, it means that you should run it without `sudo`.

    The script registers the indicator to run on system start and starts it.

    ```shell
    $HOME/Bin/locindicator/bootstrap.sh
    ```

## Uninstallation

The following script will stop and remove the currently running indicator, and remove its configuration file.
The restart is still possible with after executing `install.sh` and `bootstrap.sh` scripts

```
$HOME/Bin/locindicator/uninstall.sh
```

## Known issues

### IP / country code text missing from the tray (flag icon only)

On some systems only the flag icon shows in the tray, with the `IP:<address>` /
country code text label never appearing next to it, even though the indicator
is otherwise working correctly.

This is not a bug in `locindicator` — it's a rendering bug in the **Ubuntu
AppIndicators GNOME Shell extension**
([ubuntu/gnome-shell-extension-appindicator](https://github.com/ubuntu/gnome-shell-extension-appindicator),
see [Launchpad bug #2059818](https://bugs.launchpad.net/ubuntu/+source/gnome-shell-extension-appindicator/+bug/2059818)).
Investigation via D-Bus (`busctl get-property ... XAyatanaLabel`) confirmed
the indicator sets the label correctly on the StatusNotifierItem. The
extension, however, only refreshes its cached panel label when it receives a
custom `NewLabel`/`XAyatanaNewLabel` D-Bus signal — it does not read
`org.freedesktop.DBus.Properties.PropertiesChanged` and does not poll the
property. When the version of `libayatana-appindicator` backing
`set_label()` doesn't emit that signal (or emits it under a name this
extension version doesn't expect), the shell never learns the label changed.
The icon, which has its own `NewIcon`-style signal path, still updates fine —
so only the flag renders, never the text next to it.

There is no known fix or workaround within this repo; the label content is
already correct on the D-Bus side. If you hit this, either:
- Live with icon-only display (the flag still reflects your current country), or
- Check for an updated `gnome-shell-extension-appindicator` package (`apt changelog gnome-shell-extension-appindicator`) that addresses the signal mismatch.

## Compatibility

Tested on:
- Ubuntu 24.04
- Ubuntu 22.04
