#!/bin/bash
#A fenti sor feltétlenül kell, nem szabad megváltoztatni!
sudo apt update
sudo apt install -y composer mc php-curl php-bcmath curl php7.4-curl phpmyadmin mariadb-server net-tools sshfs openssh-server openssh-client openssl sshpass mariadb-backup wget snapd libmp3lame-dev lame php-xmlrpc php7.4-xmlrpc php7.4 php-gd php-mysql  php-xml php7.4-json apache2 apt-utils bzip2 links

sudo service apache2 start

#ügyfél helyi web root
UGYFEL_WEB_MAPPA_GYOKER=/var/www/html
#mappa létrehozása
sudo mkdir $UGYFEL_WEB_MAPPA_GYOKER/api
#composer.json létrehozása
sudo touch $UGYFEL_WEB_MAPPA_GYOKER/api/composer.json
#composer.json jogosultság beállítása
sudo chmod -R 777 $UGYFEL_WEB_MAPPA_GYOKER/api/
#composer.json tartalom feltöltése
cat <<EOFCOMP > $UGYFEL_WEB_MAPPA_GYOKER/api/composer.json
{
	"require": {
    	"google/apiclient": "*",
    	"google/auth": "*",
    	"google/cloud-core": "*",
    	"google/cloud-storage": "*",
    	"google/cloud-speech": "*",
    	"ext-bcmath": "*",
    	"google/cloud": "*",
    	"darkaonline/ripcord": "*"
	}
}
EOFCOMP
#a fenti cimkét nem szabad eltávolítani vagy átnevezni! Eddig szól a cat parancs

# composer telepítése
cd $UGYFEL_WEB_MAPPA_GYOKER/api/
composer update
composer install
composer fund



