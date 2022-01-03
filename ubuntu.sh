#!/bin/bash
set -e
if [[ "$EUID" -ne 0 ]]; then
        echo "Sorry, this script must be ran as root"
        echo "Maybe try this as root:"
        exit
fi
echo "[Unit]
rc-manager=resolvconf" > /etc/NetworkManager/conf.d/rc-manager.conf
echo "#!/bin/bash
wg-quick down wg0
wg-quick up wg0
resolvectl flush-caches" > /etc/network/if-up.d/wg-restart.sh
chmod +x /etc/network/if-up.d/wg-restart.sh
systemctl enable wg-quick@wg0
service NetworkManager restart
echo "> Done! Please reboot your system once"