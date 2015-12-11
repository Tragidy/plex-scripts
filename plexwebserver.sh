#!/bin/bash
# PLEX ARM transcoder limitation interceptor
# By TRAGiDY https://github.com/Tragidy/
# Released Under Apache 2.0 License 
# http://www.apache.org/licenses/LICENSE-2.0
# This script will work on Debian, Ubuntu, maybe other debian based distros

clear
echo "PLEX ARM Chromecast bypass"   
echo "script by TRAGiDY https://github.com/Tragidy/"  
date;
echo "This script should be ran with root"
echo "Running this script as "$USER""
sleep 3

# OpenDNS
echo "Using reliable DNS Servers"
cp /etc/resolv.conf /etc/resolv.conf.bakup
rm -rf /etc/resolv.conf
touch /etc/resolv.conf
echo "nameserver 208.67.222.222" >> /etc/resolv.conf
echo "nameserver 208.67.220.220" >> /etc/resolv.conf
chattr +i /etc/resolv.conf
echo "DNS set to use OpenDNS, resolver file locked"

# Setup plex server ip
echo "Type the plex server ip that you want to set in hosts file, followed by [ENTER]:"

read plexip
#echo "$plexip  app.plex.tv chromecast.plex.tv" >> /etc/hosts -- issue reported.
echo "$plexip app.plex.tv" >> /etc/hosts
echo "$plexip chromecast.plex.tv" >> /etc/hosts
echo "Setting plex services ip to $plexip"
sleep 2
echo "That's all we need proceeding with installation."

echo "Making sure system is up to date..."
echo "Running UPDATE Please Wait..."
apt-get update -y >/dev/null 2>&1 &
wait $!
echo "Updating packages completed"
clear

echo "Installing NGINX, DNSMASQ and OpenSSL"
apt-get install openssl dnsmasq nginx -y &
wait $!
echo "Installed Applications, creating folder structure"

# Create folders, download plex.js and change permissions
mkdir -p /var/www/chromecast/production/js
mkdir -p /var/www/webjs/web/js
cd /var/www/chromecast/production/js
echo "Folders created.. fetching latest chromecast plex.js"
wget http://chromecast.plex.tv/production/js/plex.js >/dev/null 2>&1 &
# Re-write Contribution by Mike @ HTPCGuides
wait $!
sed -i s'/canPlay:function(e,t){/canPlay:function(e,t){return false;/' plex.js
echo ".... fetching latest web client plex.js"
cd /var/www/webjs/web/js
wget http://app.plex.tv/web/js/plex.js >/dev/null 2>&1 &
wait $!
sed -i s'/validateTranscoder:function(e,t){/validateTranscoder:function(e,t){return false;/' plex.js
cd /
chown -R www-data:www-data /var/www
echo "Fetching javascript files complete"
sleep 1

# Create NGINX folders, and generating SSL
echo "HTTPD and SSL "
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt &
wait $!
touch /etc/nginx/sites-enabled/webjs
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

echo "server {" >> /etc/nginx/sites-enabled/webjs
echo "server_name app.plex.tv;" >> /etc/nginx/sites-enabled/webjs
echo "listen 80;" >> /etc/nginx/sites-enabled/webjs
echo "listen 443 ssl;" >> /etc/nginx/sites-enabled/webjs
echo "" >> /etc/nginx/sites-enabled/webjs
echo "ssl_certificate /etc/nginx/ssl/nginx.crt;" >> /etc/nginx/sites-enabled/webjs
echo "ssl_certificate_key /etc/nginx/ssl/nginx.key;" >> /etc/nginx/sites-enabled/webjs
echo "access_log   /var/log/nginx/app.plex.tv.access.log;" >> /etc/nginx/sites-enabled/webjs
echo "error_log    /var/log/nginx/app.plex.tv.error.log;" >> /etc/nginx/sites-enabled/webjs
echo "" >> /etc/nginx/sites-enabled/webjs
echo "root /var/www/webjs;" >> /etc/nginx/sites-enabled/webjs
echo "autoindex on;" >> /etc/nginx/sites-enabled/webjs
echo "}" >> /etc/nginx/sites-enabled/webjs

# Complete
service nginx restart
clear
echo "Process complete, rock and roll!"
