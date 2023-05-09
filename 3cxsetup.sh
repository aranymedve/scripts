#!/bin/bash

#mysql-ben:
#CREATE DATABASE 3cxplusz;
#CREATE USER '3cxuser'@'localhost' IDENTIFIED BY 'password';
#GRANT ALL PRIVILEGES ON '3cxplusz'.* TO '3cxuser'@'localhost';
#FLUSH PRIVILEGES;
if false; then
	echo "Kérem, adja meg az alábbi adatokat! Megszakítás: CTRL+C\nA folyamat bármikor újrakezdhető megszakítás után! A szögletes zárójelben az alapértelmezett értéket látja, ha el kívánja fogadni, nyomjon ENTER-t!"

	read -p "Kíván új 3cxplusz adatbázist  létrehozni (I/n)(új telepítés esetén adjon meg I-t!) (csak helyi adatbázis-szerver esetében használható!) [I]: " KELLUJDB
	KELLUJDB="${KELLUJDB:=I}"
	if [[ "$KELLUJDB" == "I" ]]; then
		echo "Új adatbázis létrehozása indul."
		read -p "Kérem, adja meg az adatbázis nevét [3cxplusz]: " USERDATABASE
		USERDATABASE="${USERDATABASE:=3cxplusz}"
	else
		echo "Adatbázist nem hozunk létre."
	fi

	read -p "Kíván új felhasználót létrehozni a 3cxplusz adatbázis kezeléséhez? (I/n)(új telepítés esetén adjon meg I-t!) [I]: " KELLUJDBUSER
	KELLUJDBUSER="${KELLUJDBUSER:=I}"

	if [[ "$KELLUJDBUSER" == "I" ]]; then
		echo "Új felhasználó létrehozása indul."
		read -p "Kérem, adja meg az adatbázis felhasználónevét [3cxuser]: " USERDBUSERNAME
		USERDBUSERNAME="${USERDBUSERNAME:=3cxuser}"
		read -p "Kérem, adja meg az adatbázis felhasználójának jelszavát: " USERDBPASSWORD
	else
		echo "Felhasználót nem hozunk létre."
	fi

	if [[ "$KELLUJDB" == "I" ]]; then
		if [[ -z "$USERDATABASE" ]]; then
			echo "Hiányzik néhány adat, létrehozás megszakítva"
		else
			sudo mysql -uroot -p<<QUERY1
			CREATE DATABASE IF NOT EXISTS $USERDATABASE;
QUERY1
		fi
	fi
		
	if [[ "$KELLUJDBUSER" == "I" ]]; then
		if [[ -z "$USERDBUSERNAME" && -z "$USERDBPASSWORD" ]]; then
			echo "Hiányzik néhány adat, létrehozás megszakítva"
		else
			sudo mysql -uroot -p<<QUERY2
			CREATE USER IF NOT EXISTS '$USERDBUSERNAME'@'localhost' IDENTIFIED BY '$USERDBPASSWORD';
			GRANT ALL PRIVILEGES ON $USERDATABASE.* TO '$USERDBUSERNAME'@'localhost';
			FLUSH PRIVILEGES;
QUERY2
		fi
	fi

	read -p "Kérem, adja meg a korábban emailben megkapott API-kulcsát: " APIKULCS
	APIKULCS="${APIKULCS:=1644e99f48ca9b6a93718de1d345472cd01cc3600ee01970422e3b02b6feb5f600f3beb89a8035}"

	read -p "Kérem, adja meg a korábban emailben megkapott VT usernevét: " VTUSERNAME
	VTUSERNAME="${VTUSERNAME:=tesztreg}"

	read -p "Kérem, adja meg a composer autoload.php fájl útvonalát [/var/www/html/api/vendor/autoload.php]: " REQUIREONCE
	REQUIREONCE="${REQUIREONCE:=/var/www/html/api/vendor/autoload.php}"

	read -p "Kérem, adja meg szervere http protokollját (http/https) [http]: " USERHTTPTYPE
	USERHTTPTYPE="${USERHTTPTYPE:=http}"

	read -p "Kérem, adja meg a webszervere URL útvonalát a végén / jellel [localhost/]: " USERAPIHOST
	USERAPIHOST="${USERAPIHOST:=localhost/}"

	read -p "Kérem, adja meg a webszervere gyökérmappájának útvonalát a végén / jellel [/var/www/html/]: " BASEAPIPATH
	BASEAPIPATH="${BASEAPIPATH:=/var/www/html/}"

	read -p "Kérem, adja meg az adatbázis-szervere hosztnevét vagy IP-címét [localhost]: " TMPUSERDBHOST
	TMPUSERDBHOST="${TMPUSERDBHOST:=localhost}"

	read -p "Kérem, adja meg a webszervere URL útvonalát a végén / jellel [localhost/]: " TMPUSERAPIHOST
	TMPUSERAPIHOST="${TMPUSERAPIHOST:=localhost/}"

	read -p "Kérem, adja meg a Google Speech API URl előtagját: [https://texttospeech.googleapis.com/v1beta1/text:synthesize?key=]" GOOGLEAPI
	GOOGLEAPI="${GOOGLEAPI:=https://texttospeech.googleapis.com/v1beta1/text:synthesize?key=}"

	read -p "Kérem, adja meg a Google Speech API kulcsát: " GOOGLETTSKEY
	GOOGLETTSKEY="${GOOGLETTSKEY:=APIKEY1}"

	read -p "Kérem, adja meg a Google Speech API kulcsfájl fájlrendszerbeli útvonalát: " GOOGLESTTKEYPATH
	GOOGLESTTKEYPATH="${GOOGLESTTKEYPATH:=/var/apipath}"

	read -p "Kérem, adja meg az adatbázis-szervere típusát (1=mysql, 2=mssql) [1]: " SQLTYPE
	SQLTYPE="${SQLTYPE:=1}"

	if [[ -z "$USERSERVER" ]]
	then
		read -p "Kérem, adja meg az adatbázis-szervere hosztnevét vagy IP-címét [localhost]: " USERSERVER
		USERSERVER="${USERSERVER:=localhost}"
	fi

	if [[ -z "$USERDATABASE" ]]
	then
		read -p "Kérem, adja meg az adatbázis nevét [3cxplusz]: " USERDATABASE
		USERDATABASE="${USERDATABASE:=3cxplusz}"
	fi
	if [[ -z "$USERDBUSERNAME" ]]
	then
		read -p "Kérem, adja meg az adatbázis felhasználónevét [3cxuser]: " USERDBUSERNAME
		USERDBUSERNAME="${USERDBUSERNAME:=3cxuser}"
	fi
	if [[ -z "$USERDBPASSWORD" ]]
	then
		read -p "Kérem, adja meg az adatbázis felhasználójának jelszavát: " USERDBPASSWORD
	fi
fi



APIKULCS="${APIKULCS:=1644e99f48ca9b6a93718de1d345472cd01cc3600ee01970422e3b02b6feb5f600f3beb89a8035}"
VTUSERNAME="${VTUSERNAME:=tesztreg}"
REQUIREONCE="${REQUIREONCE:=/var/www/html/api/vendor/autoload.php}"
USERHTTPTYPE="${USERHTTPTYPE:=http}"
USERAPIHOST="${USERAPIHOST:=localhost/}"
BASEAPIPATH="${BASEAPIPATH:=/var/www/html/}"
TMPUSERDBHOST="${TMPUSERDBHOST:=localhost}"
TMPUSERAPIHOST="${TMPUSERAPIHOST:=localhost/}"
GOOGLEAPI="${GOOGLEAPI:=https://texttospeech.googleapis.com/v1beta1/text:synthesize?key=}"
GOOGLETTSKEY="${GOOGLETTSKEY:=APIKEY1}"
GOOGLESTTKEYPATH="${GOOGLESTTKEYPATH:=/var/apipath}"
SQLTYPE="${SQLTYPE:=1}"
USERSERVER="${USERSERVER:=localhost}"
USERDATABASE="${USERDATABASE:=3cxplusz}"
USERDBUSERNAME="${USERDBUSERNAME:=3cxuser}"
USERDBPASSWORD="${USERDBPASSWORD:=123456Aa}"

rm ./3cx.zip

CMD="curl -X POST -d '{\"api\":{\"key\":\"$APIKULCS\"},\"method\":\"3cxpluszapizip\",\"data\":{\"vtusername\":\"$VTUSERNAME\",\"userapivars\":{\"requireonce\":\"$REQUIREONCE\",\"userhttptype\":\"$USERHTTPTYPE\",\"userapihost\":\"$USERAPIHOST\",\"baseapipath\":\"$BASEAPIPATH\",\"tmpuserdbhost\":\"$TMPUSERDBHOST\",\"tmpuserapihost\":\"$TMPUSERAPIHOST\",\"googleapi\":\"$GOOGLEAPI\",\"googlettskey\":\"$GOOGLETTSKEY\",\"googlesttkeypath\":\"$GOOGLESTTKEYPATH\"},\"userdbsettings\":{\"sqltype\":\"$SQLTYPE\",\"userserver\":\"$USERSERVER\",\"userdatabase\":\"$USERDATABASE\",\"userdbusername\":\"$USERDBUSERNAME\",\"userdbpassword\":\"$USERDBPASSWORD\"}}}' -H \"content-type:application/json\" --output 3cx.zip https://3cxplusz.smstar.hu/api/v2/_other/3cxpapizip.php"

echo $CMD

eval "$CMD"




sudo rm -r /var/www/html/api/
sudo rm -r /var/www/html/tmp/
sudo unzip 3cx.zip -d /var/www/html/
sudo chmod -R 777 /var/www/html/
cd /var/www/html/tmp
sudo php ./runapi.php
