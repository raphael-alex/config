#!/bin/bash

/home/rah/.cargo/bin/xremap --device 'Keychron K8' /home/rah/.config/xremap/config.yml

echo "$(date): xremap script executed via udev." >>/var/log/xremap_udev.log
