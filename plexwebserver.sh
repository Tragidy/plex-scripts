#!/bin/bash
# PLEX ARM Chromecast bypass installer for Debian and Ubuntu
# By TRAGiDY https://github.com/Tragidy/
# 
# Released Under Apache 2.0 License 
# http://www.apache.org/licenses/LICENSE-2.0

# This script will work on Debian, Ubuntu, maybe other debian based distros
# of the same families, although no support is offered for them. It isn't
# bulletproof but it will probably work if you simply want issue one command
# on your Debian/Ubuntu box. It has been designed to be as unobtrusive and
# universal as possible.

clear
echo "PLEX ARM Chromecast bypass"   
echo "script by TRAGiDY https://github.com/Tragidy/"  
date;
echo "This script should be ran with root"
echo "Running this script as "$USER""
sleep 3

echo "Making sure system is up to date..."
sleep 1
echo "Running APT-GET UPDATE Please Wait..."
apt-get update -y >/dev/null 2>&1 &
wait $!
clear

echo "Updating packages completed"
echo "Installing NGINX, DNSMASQ and OpenSSL"
apt-get install openssl dnsmasq nginx -y &
wait $!
echo "Installed Applications, creating folder structure"

# Create folders, download plex.js and change permissions
mkdir -p /var/www/chromecast/production/js
cd /var/www/chromecast/production/js
echo "Folders created.. fetching latest plex.js"
wget https://raw.githubusercontent.com/Tragidy/plex-scripts/master/js/chromecast/plex.js >/dev/null 2>&1 &
wait $!
chown -R www-data:www-data /var/www
echo "Folders created.. fetching javascript complete"
sleep 1
echo ""

# Setup plex server ip
echo "Type the plex server ip that you want to set, followed by [ENTER]:"

read plexip
echo "$plexip  app.plex.tv chromecast.plex.tv" >> /etc/hosts
echo "Setting plex services ip to $plexip"


# Change DNS Servers, keeping Google DNS away however you are welcome to use them
echo "Using reliable DNS Servers"
rm -rf /etc/resolv.conf
touch /etc/resolv.conf
echo "nameserver 208.67.222.222" >> /etc/resolv.conf
echo "nameserver 208.67.220.220" >> /etc/resolv.conf
chattr +i /etc/resolv.conf
echo "DNS set to use OpenDNS, resolver file locked"

# Create NGINX folders, and generating SSL
echo "Creating Webserver and SSL Configuration"
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt &
wait $!
touch /etc/nginx/sites-enabled/chromecast

echo "server {" >> /etc/nginx/sites-enabled/chromecast
echo "server_name chromecast.plex.tv;" >> /etc/nginx/sites-enabled/chromecast
echo "listen 80;" >> /etc/nginx/sites-enabled/chromecast
echo "listen 443 ssl;" >> /etc/nginx/sites-enabled/chromecast 
echo "" >> /etc/nginx/sites-enabled/chromecast
echo "ssl_certificate /etc/nginx/ssl/nginx.crt;" >> /etc/nginx/sites-enabled/chromecast
echo "ssl_certificate_key /etc/nginx/ssl/nginx.key;" >> /etc/nginx/sites-enabled/chromecast
echo "access_log   /var/log/nginx/chromecast.plex.tv.access.log;" >> /etc/nginx/sites-enabled/chromecast
echo "error_log    /var/log/nginx/chromecast.plex.tv.error.log;" >> /etc/nginx/sites-enabled/chromecast 
echo "" >> /etc/nginx/sites-enabled/chromecast
echo "root /var/www/chromecast;" >> /etc/nginx/sites-enabled/chromecast
echo "autoindex on;" >> /etc/nginx/sites-enabled/chromecast
echo "}" >> /etc/nginx/sites-enabled/chromecast

# Complete
clear
echo "Process complete"
service nginx restart

EOF
