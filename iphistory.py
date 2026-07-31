#!/usr/bin/python3
"""Persistent log of noticed public-IP changes, capped by entry count."""
import os
from datetime import datetime

HISTORY_DIR = os.path.join(os.environ['HOME'], '.local', 'share', 'locindicator')
HISTORY_FILE = os.path.join(HISTORY_DIR, 'ip-history.log')
MAX_ENTRIES = 100


def _read_lines():
    if not os.path.isfile(HISTORY_FILE):
        return []
    with open(HISTORY_FILE, encoding='utf-8') as history_file:
        return [line.rstrip('\n') for line in history_file if line.strip()]


def _split(line):
    """Split a log line into (timestamp, ip, country_code), tolerating older
    two-column entries logged before country_code was recorded."""
    parts = line.split('\t')
    timestamp = parts[0]
    ip_address = parts[1] if len(parts) > 1 else ''
    country_code = parts[2] if len(parts) > 2 else ''
    return timestamp, ip_address, country_code


def last_known_ip():
    """Return the most recently logged IP, or None if there is no history yet."""
    lines = _read_lines()
    if not lines:
        return None
    return _split(lines[-1])[1]


def append_if_changed(ip_address, country_code):
    """Append a timestamped entry if ip_address differs from the last logged one."""
    lines = _read_lines()
    if lines and _split(lines[-1])[1] == ip_address:
        return

    timestamp = datetime.now().isoformat(timespec='seconds')
    lines.append(f'{timestamp}\t{ip_address}\t{country_code}')
    lines = lines[-MAX_ENTRIES:]

    os.makedirs(HISTORY_DIR, exist_ok=True)
    with open(HISTORY_FILE, 'w', encoding='utf-8') as history_file:
        history_file.write('\n'.join(lines) + '\n')


def read_history():
    """Return (timestamp, ip, country_code) tuples, newest first."""
    entries = [_split(line) for line in _read_lines()]
    entries.reverse()
    return entries
