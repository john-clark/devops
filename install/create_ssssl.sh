#!/bin/bash
#
# create self signed ssl
#

#check if root else run as root
if [[ "$EUID" -ne 0 ]]; then
        echo 'run with sudo'
        exit 1
fi
#check for command line options
if [[ -z "${1}" ]]; then
 echo "Need atleast the domain name"
 echo "Exmaple Useage \"sudo ./create_ssssl.sh ubuntu.lan drupal web\""
 exit 1
fi

#set vars to command line options
ROOTDOMAIN="${1}"
if [ ! -z "${2}" ]; then
  SUBDOMAIN="${2}."
fi
if [ ! -z "${3}" ]; then
  SUBDIR="/${3}"
fi
#fix if needed
DOMAIN="$SUBDOMAIN$ROOTDOMAIN"

#create if doesnt exist
SSL_DIR="/etc/ssl/$ROOTDOMAIN"
echo ">>> Installing $DOMAIN self-signed SSL"
if [ ! -f $SSL_DIR ]; then
  mkdir $SSL_DIR
fi

PASSPHRASE="none"
SUBJ="
C=US
ST=IA
L=Ames
O=Development
OU=Local
CN=$DOMAIN
emailAddress=skyman@iastate.edu
"
#by default clobber
openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
    -keyout "$SSL_DIR/$DOMAIN.key" -out "$SSL_DIR/$DOMAIN.crt" -extensions san -config \
    <(echo "[req]";
      echo distinguished_name=req;
      echo "[san]";
      echo subjectAltName = DNS:$DOMAIN
     ) \
    -subj "$(echo -n "$SUBJ" | tr "\n" "/")"

#copy crt to shared folder for import into windows later
cp "$SSL_DIR/$DOMAIN.crt" "/vagrant/$DOMAIN.crt"
echo ">>> SSL Cert /vagrant/$DOMAIN.crt ready for local-certs.ps1 on windows"

#make webroot
echo ">>> Creating folders Document"
if [ ! -d "/var/www/$DOMAIN" ]; then
  mkdir "/var/www/$DOMAIN"
else
  echo "webroot already exists"
fi
#make log folder
if [ ! -d "/var/log/apache2/$DOMAIN" ]; then
  mkdir "/var/log/apache2/$DOMAIN"
else
  echo "log dir already exists"
fi

SITES_DIR="/etc/apache2/sites-available"
#copy configs
cp "$SITES_DIR/000-default.conf" "$SITES_DIR/$DOMAIN.conf"
cp "$SITES_DIR/000-default-ssl.conf" "$SITES_DIR/$DOMAIN-ssl.conf"
#fix logs
sed -i "s/access\.log/${DOMAIN}\/access\.log/g" "$SITES_DIR/$DOMAIN.conf"
sed -i "s/error\.log/${DOMAIN}\/error\.log/g" "$SITES_DIR/$DOMAIN.conf"
sed -i "s/ssl-access\.log/${DOMAIN}\/ssl-access\.log/g" "$SITES_DIR/$DOMAIN-ssl.conf"
sed -i "s/ssl-error\.log/${DOMAIN}\/ssl-error\.log/g" "$SITES_DIR/$DOMAIN-ssl.conf"
#fix web folder
echo ">>> Setting DocumentRoot to /var/www/$DOMAIN$SUBDIR"
sed -i "s/DocumentRoot\ \/var\/www\/html/DocumentRoot\ \/var\/www\/${DOMAIN}${SUBDIR}/g" "$SITES_DIR/$DOMAIN.conf"
sed -i "s/DocumentRoot\ \/var\/www\/html/DocumentRoot\ \/var\/www\/${DOMAIN}${SUBDIR}/g" "$SITES_DIR/$DOMAIN-ssl.conf"
#fix server name
sed -i "s/DocumentRoot.*/&\n\tServerName   ${DOMAIN}/g" "$SITES_DIR/$DOMAIN.conf"
sed -i "s/DocumentRoot.*/&\n\t\tServerName  ${DOMAIN}/g" "$SITES_DIR/$DOMAIN-ssl.conf"
#fix certs
sed -i "s|/etc/ssl/ubuntu.lan/ubuntu.lan|${SSL_DIR}/${DOMAIN}|g" "$SITES_DIR/$DOMAIN-ssl.conf"
#enable sites
echo ">>> Enabling sites"
a2ensite $DOMAIN $DOMAIN-ssl

echo ">>> Restarting Webserver"
systemctl restart apache2 php8.1-fpm

echo ">>> Setting directory security"
chown -R www-data:www-data "/var/www/$DOMAIN"
chmod -R g+rwxs "/var/www/$DOMAIN"
