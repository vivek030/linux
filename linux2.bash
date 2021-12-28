#!/bin/bash
set -e
if [[ "$EUID" -ne 0 ]]; then
        echo "Sorry, this script must be ran as root"
        echo "Maybe try this:"
        echo "sudo curl https://raw.githubusercontent.com/vivek030/linux/main/linux.sh | sudo bash"
        exit
fi
wg-quick down wg0
systemctl disable wg-quick@wg0
nmcli connection import type wireguard file /etc/wireguard/wg0.conf
nmcli connection up wg0
nmcli connection modify wg0 ipv4.dns-search ~.
Nmcli connection modify wg0 ipv4.dns-priority -50
#Service Networkmanager restart
# create service unit file
echo "[Unit]
Description=Connect to wg0 automatically
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=nmcli conn up wg0
ExecStartPost=resolvectl flush-caches
ExecStop=nmcli conn down wg0
ExecStopPost=resolvectl flush-caches
RemainAfterExit=true
[Install]
WantedBy=default.target" > /etc/systemd/system/wg0-autostart.service
systemctl daemon-reload
systemctl enable wg0-autostart.service