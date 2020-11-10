from sys import argv

install_path = None

try:
    install_path = argv[1]
except IndexError:
    print('Please provide the script installation path as first argument')
    exit(1)
finally:
    if install_path is None:
        print('Please provide the script installation path as first argument')
        exit(1)

exec(open('/usr/lib/indicator-sysmonitor/sensors.py').read())

mgr = SensorManager()
mgr.update_regex()
mgr.add('location', 'Display current location IP address and country flag', install_path + "/get-my-location.sh")
mgr.add('countryflag', 'Display current location country flag', install_path + "/get-my-country-flag.sh")
mgr.set_custom_text('{countryflag} {location}')
mgr.set_interval(15)
mgr.settings['on_startup'] = True
mgr.save_settings()
