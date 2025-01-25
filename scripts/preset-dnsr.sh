#!/bin/bash

mkdir -p files/usr/bin

DNSR_BIN=$(curl -sL https://api.github.com/repos/Jipok/dnsr/releases/latest | grep /dnsr-"${1}" | awk -F '"' '{print $4}')

wget -qO files/usr/bin/dnsr "$DNSR_BIN"

chmod +x files/usr/bin/dnsr
