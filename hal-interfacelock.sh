dbus-send --system --print-reply --dest=org.freedesktop.Hal \
            /org/freedesktop/Hal/devices/computer           \
            org.freedesktop.Hal.Device.AcquireInterfaceLock \
            string:"org.freedesktop.Hal.Device.SystemPowerManagement" \
            boolean:false

