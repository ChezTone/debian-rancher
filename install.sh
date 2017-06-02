#!/usr/bin/env bash

if [ ! $1 == "-d" ] || [ ! $2 ];then
    echo "Usage: `basename $0` -d [domaine_name]";
    echo "       [domane_name] should not contains protocols or port. e.g. : cheztone.org";
    exit 1;
fi;

# Update packages
apt-get update

# Install Tools
apt-get install -y curl software-properties-common ca-certificates apt-transport-https

# Install certbot
echo "deb http://ftp.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
apt-get update
apt-get install -y certbot -t jessie-backports
certbot certonly --standalone -d $2 \
                              -d rancher.$2 \

# Install & config nginx
apt-get install -y nginx
sed "s|\$MY_DOMAIN|$2|g" config/nginx > config/user_config
cp ./config/user_config /etc/nginx/sites-available/default
rm config/user_config
nginx -s reload

# Install Docker
curl -s http://yum.dockerproject.org/gpg | apt-key add -
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-$(lsb_release -cs) \
       main"
apt-get update
apt-get -y install docker-engine

# Install docker compose
curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# run rancher stack
docker-compose up -d --build

