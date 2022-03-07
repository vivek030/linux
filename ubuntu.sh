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
echo "#!/bin/sh
sudo crontab -l > cron_bkp
sudo echo "*/10 * * * * sudo /etc/network/if-up.d/wg-restart.sh >/dev/null 2>&1" >> cron_bkp
sudo crontab cron_bkp
sudo rm cron_bkp" > /etc/network/if-up.d/wg-restartnew.sh
chmod +x /etc/network/if-up.d/wg-restartnew.sh
echo "#!/bin/bash
wg-quick down wg0
wg-quick up wg0
resolvectl flush-caches" > /etc/ppp/ip-up.d/0000wg-restart.sh
chmod +x /etc/ppp/ip-up.d/0000wg-restart.sh
systemctl enable wg-quick@wg0
service NetworkManager restart
echo "> Done! Please reboot your system once"
