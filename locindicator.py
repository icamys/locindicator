#!/usr/bin/python3
"""Tray indicator process for locindicator.

Polls get-location.sh every 15 seconds, updates the tray icon/label with the
current flag/country/IP, and logs IP changes to iphistory so they can be
browsed from the tray dropdown's "IP History" entry.
"""
import logging
import os
import subprocess
import sys

import gi  # pylint: disable=import-error

gi.require_version('Gtk', '3.0')
try:
    gi.require_version('AyatanaAppIndicator3', '0.1')
    # pylint: disable-next=import-error,no-name-in-module
    from gi.repository import AyatanaAppIndicator3 as appindicator
except ValueError:
    gi.require_version('AppIndicator3', '0.1')
    # pylint: disable-next=import-error,no-name-in-module
    from gi.repository import AppIndicator3 as appindicator
# pylint: disable-next=import-error,no-name-in-module,wrong-import-position
from gi.repository import GLib, Gtk

import iphistory  # pylint: disable=wrong-import-position

logging.basicConfig(level=logging.INFO)

UPDATE_INTERVAL_SECONDS = 15
DEFAULT_ICON = 'network-wired-symbolic'
STALE_MARKER = '⚠'


class LocIndicator:  # pylint: disable=too-few-public-methods
    """Owns the tray icon, its dropdown menu, and the IP-history window.

    Its behavior is driven entirely by the GLib tick and GTK signal callbacks
    below, so it has no public methods beyond construction.
    """

    def __init__(self, install_path):
        self.get_location_script = os.path.join(install_path, 'get-location.sh')
        self.last_ip = iphistory.last_known_ip()
        self._history_window = None
        self._history_store = None

        self.ind = appindicator.Indicator.new(
            'locindicator', DEFAULT_ICON, appindicator.IndicatorCategory.SYSTEM_SERVICES)
        self.ind.set_status(appindicator.IndicatorStatus.ACTIVE)
        self.ind.set_label('Init...', '')
        self.ind.set_menu(self._build_menu())

        GLib.timeout_add_seconds(UPDATE_INTERVAL_SECONDS, self._tick)
        self._tick()

    def _build_menu(self):
        """Build the static dropdown: IP History, separator, Quit."""
        menu = Gtk.Menu()

        history_item = Gtk.MenuItem(label='IP History')
        history_item.connect('activate', self._on_history_activated)
        menu.append(history_item)

        menu.append(Gtk.SeparatorMenuItem())

        quit_item = Gtk.MenuItem(label='Quit')
        quit_item.connect('activate', self._on_quit)
        menu.append(quit_item)

        menu.show_all()
        return menu

    def _run_get_location(self, arg):
        """Invoke get-location.sh with the given argument and return its stdout."""
        try:
            result = subprocess.run(
                [self.get_location_script, arg], stdout=subprocess.PIPE,
                text=True, check=False)
        except OSError as ex:
            logging.error('get-location.sh %s failed: %s', arg, ex)
            return ''
        return result.stdout.strip()

    def _tick(self):
        """Refresh the tray label/icon and record IP changes in the history log."""
        ip_raw = self._run_get_location('ip')
        country_code = self._run_get_location('country_code')
        flag_output = self._run_get_location('country_flag')

        ip_address = ip_raw.replace(STALE_MARKER, '').strip()
        if ip_address and ip_address not in ('N/A', self.last_ip):
            iphistory.append_if_changed(ip_address)
            self.last_ip = ip_address

        if flag_output.startswith('USE_ICON:'):
            icon_path = flag_output[len('USE_ICON:'):].strip()
            if icon_path:
                self.ind.set_icon_full(icon_path, '')

        label = f'{country_code}, IP:{ip_raw}' if country_code else ip_raw
        self.ind.set_label(label.strip(), '')

        return True

    def _on_history_activated(self, _widget):
        """Show the IP-history window, creating it on first use."""
        if self._history_window is not None:
            self._refresh_history_store()
            self._history_window.present()
            return

        window = Gtk.Window(title='IP History')
        window.set_default_size(320, 400)
        window.connect('delete-event', self._on_history_closed)

        store = Gtk.ListStore(str, str)
        tree_view = Gtk.TreeView(model=store)
        for index, title in enumerate(['Since', 'IP']):
            tree_view.append_column(
                Gtk.TreeViewColumn(title, Gtk.CellRendererText(), text=index))

        scrolled = Gtk.ScrolledWindow()
        scrolled.add(tree_view)
        window.add(scrolled)

        self._history_window = window
        self._history_store = store
        self._refresh_history_store()
        window.show_all()

    def _refresh_history_store(self):
        """Reload the history list store from the on-disk log."""
        self._history_store.clear()
        for timestamp, ip_address in iphistory.read_history():
            self._history_store.append([timestamp, ip_address])

    def _on_history_closed(self, window, _event):
        """Drop the history window singleton so it's rebuilt fresh next time."""
        window.destroy()
        self._history_window = None
        self._history_store = None
        return False

    def _on_quit(self, _widget):
        """Exit the indicator."""
        Gtk.main_quit()


def main():
    """Entry point: start the indicator with the install path from argv[1]."""
    try:
        install_path = sys.argv[1]
    except IndexError:
        print('Please provide the script installation path as first argument')
        sys.exit(1)

    LocIndicator(install_path)
    Gtk.main()


if __name__ == '__main__':
    main()
