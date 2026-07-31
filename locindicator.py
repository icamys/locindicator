#!/usr/bin/python3
"""Tray indicator process for locindicator.

Polls get-location.sh every 15 seconds, updates the tray icon/label with the
current flag/country/IP, and logs IP changes to iphistory so the most recent
ones can be browsed inline in the tray dropdown, under the current IP.
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
HISTORY_MENU_LIMIT = 10


class LocIndicator:  # pylint: disable=too-few-public-methods
    """Owns the tray icon and its dropdown menu, including inline IP history.

    Its behavior is driven entirely by the GLib tick and GTK signal callbacks
    below, so it has no public methods beyond construction.
    """

    def __init__(self, install_path):
        self.get_location_script = os.path.join(install_path, 'get-location.sh')
        self.last_ip = iphistory.last_known_ip()
        self._status_item = None
        self._history_end_marker = None
        self._history_items = []
        self.menu = self._build_menu()
        self._refresh_history_menu()

        self.ind = appindicator.Indicator.new(
            'locindicator', DEFAULT_ICON, appindicator.IndicatorCategory.SYSTEM_SERVICES)
        self.ind.set_status(appindicator.IndicatorStatus.ACTIVE)
        self.ind.set_label('Init...', '')
        self.ind.set_menu(self.menu)

        GLib.timeout_add_seconds(UPDATE_INTERVAL_SECONDS, self._tick)
        self._tick()

    def _build_menu(self):
        """Build the static dropdown: status line, changelog header, Quit.

        The status line mirrors the tray label text as a disabled menu entry,
        so the current IP is still visible from the dropdown even on setups
        where the panel label fails to render next to the icon (see README's
        "Known issues" section). Recent IP-history entries are inserted
        in-place below the "IP changelog" header by _refresh_history_menu,
        right before _history_end_marker.
        """
        menu = Gtk.Menu()

        self._status_item = Gtk.MenuItem(label='Init...')
        self._status_item.set_sensitive(False)
        menu.append(self._status_item)

        menu.append(Gtk.SeparatorMenuItem())

        header_item = Gtk.MenuItem(label='IP changelog')
        header_item.set_sensitive(False)
        menu.append(header_item)

        self._history_end_marker = Gtk.SeparatorMenuItem()
        menu.append(self._history_end_marker)

        quit_item = Gtk.MenuItem(label='Quit')
        quit_item.connect('activate', self._on_quit)
        menu.append(quit_item)

        menu.show_all()
        return menu

    def _refresh_history_menu(self):
        """Rebuild the inline history rows below the "IP changelog" header."""
        for item in self._history_items:
            self.menu.remove(item)
        self._history_items = []

        entries = iphistory.read_history()[:HISTORY_MENU_LIMIT]
        rows = []
        for timestamp, ip_address, country_code in entries:
            ip_label = f'{country_code}, IP:{ip_address}' if country_code else f'IP:{ip_address}'
            rows.append(f'{ip_label}   {timestamp}')
        if not rows:
            rows = ['No IP changes recorded yet']

        position = self.menu.get_children().index(self._history_end_marker)
        for row in rows:
            item = Gtk.MenuItem(label=row)
            item.set_sensitive(False)
            item.show()
            self.menu.insert(item, position)
            position += 1
            self._history_items.append(item)

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
        country_clean = country_code.replace(STALE_MARKER, '').strip()
        if country_clean == 'N/A':
            country_clean = ''

        if ip_address and ip_address not in ('N/A', self.last_ip):
            iphistory.append_if_changed(ip_address, country_clean)
            self.last_ip = ip_address
            self._refresh_history_menu()

        if flag_output.startswith('USE_ICON:'):
            icon_path = flag_output[len('USE_ICON:'):].strip()
            if icon_path:
                self.ind.set_icon_full(icon_path, '')

        label = f'{country_code}, IP:{ip_raw}' if country_code else ip_raw
        label = label.strip()
        self.ind.set_label(label, '')
        self._status_item.set_label(label or 'No data yet')

        return True

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
