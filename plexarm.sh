#!/bin/bash
# Plex Media Server Installation Script
# By TRAGiDY https://github.com/Tragidy/
# Inspired by Mike @ http://www.htpcguides.com/
# 
# Released Under Apache 2.0 License 
# http://www.apache.org/licenses/LICENSE-2.0

# This script will work on Debian and Ubuntu maybe other debian based distros
# of the same families, although no support is offered for them. It has been 
# designed to be as unobtrusive and universal as possible. I use it to load plex
# on my debian nodes.

# Clear window, show banner/credits
echo "Plex Media Server for Debian Jessie ARMv7 and forks"
echo "This installation is only for ARM based systems."
echo "press CTRL+C to cancel this is the only warning"
sleep 5

#Update system
clear
echo "Welcome to Plex Media Server Install for ARM Systems"
echo "Making sure system is up to date"
apt-get update -y >/dev/null 2>&1 &
wait $!
apt-get install firmware-linux-nonfree -y >/dev/null 2>&1 &
wait $!

# Regenerate Locale
locale -a >/dev/null 2>&1
locale-gen >/dev/null 2>&1
#sed -i 's/^port .*/port=2223/g' /etc/webmin/miniserv.conf
apt-get install apt-transport-https -y --force-yes >/dev/null 2>&1 &
wait $!
wget -O - https://dev2day.de/pms/dev2day-pms.gpg.key | sudo apt-key add -
echo "deb https://dev2day.de/pms/ jessie main" | sudo tee /etc/apt/sources.list.d/pms.list
apt-get install libexpat1 plexmediaserver mkvtoolnix -y >/dev/null 2>&1 &
wait $!
echo "Hard Restart on Plex"
service plexmediaserver restart
echo "Installation Complete please visit http://localhost:32400/manage/index.html#!/setup"

EOF
