#!/bin/bash

mkdir -p files/usr/bin

SPOOF_BIN=$(curl -sL https://api.github.com/repos/xvzc/SpoofDPI/releases/latest | grep /spoofdpi-linux-${1} | awk -F '"' '{print $4}')

wget -qO- "$SPOOF_BIN" | tar xOvz >files/usr/bin/spoofdpi

chmod +x files/usr/bin/spoofdpi
