#!/bin/bash
# PLEX MITM installer for Debian and Ubuntu

# This script will work on Debian, Ubuntu, maybe other debian based distros
# of the same families, although no support is offered for them. It isn't
# bulletproof but it will probably work if you simply want issue one command
# on your Debian/Ubuntu box. It has been designed to be as unobtrusive and
# universal as possible.

clear
echo "Plex JS Intercept Script"   
echo "by TRAGiDY tragidy@dorkfiles.com"  
date;
echo "Running this script as "$USER""
sleep 3

echo "Making sure system is up to date..."
sleep 2
echo "Running APT-GET UPDATE Please Wait..."
apt-get update -y >/dev/null 2>&1 &
wait $!
clear

echo "Updating packages completed"
sleep 1
echo "Creating Folders"

mkdir -p /var/www/chromecast/production/js
#cd /var/www/chromecast/production/js
echo "Folders created.. fetching latest plex.js"
echo "Remember to make edits for playback"
sleep 1
wget http://chromecast.plex.tv/production/js/plex.js >/dev/null 2>&1 &
wait $!
sudo chown -R www-data:www-data /var/www
echo "Folders created.. fetching javascript complete"
sleep 1
clear

echo "Type the plex server ip that you want to set, followed by [ENTER]:"

read plexip
echo "$plexip  app.plex.tv chromecast.plex.tv" >> /etc/hosts
echo "Settings app.plex.tv and chromecas.plex.tv to resolve to $plexip"
fi
sleep 1
echo "Complete"
