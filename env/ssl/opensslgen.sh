#!/bin/bash
# install dnsmasq for domain *.local.dev
BASEDIR="$( cd "$( dirname "$0" )" && pwd )"
CERTDIR=$BASEDIR/certs
DEFAUTDOMAIN=local.dev # Use your own domain name
DOMAIN=$1
if [[ -z $DOMAIN ]]; then
  echo "Select a localhost domain(eg. .test, .dev.local is default used):"
  read input_domain
  DOMAIN=${input_domain:=$DEFAUTDOMAIN}
fi
echo "Configuring SSL for the domain *.$DOMAIN"
echo "Check and create certs folder"
[[ ! -d $CERTDIR ]] \
    && mkdir -p $CERTDIR \
    || echo "✓ Certs folder exists"
cd $BASEDIR/certs
#####################
# Become a Certificate Authority
######################

# Generate private key
openssl genrsa -out localCA.key 2048
echo "✓ Generated CA key"
# Generate root certificate
openssl req -x509 -new -nodes -key localCA.key -sha256 -days 3650 -out localCA.pem
echo "✓ Generated CA public key"
######################
# Create CA-signed certs
######################

# Generate a private key
openssl genrsa -out $DOMAIN.key 2048
echo "✓ Generated $DOMAIN CA-signed private key"
# Create a certificate-signing request
openssl req -new -key $DOMAIN.key -out $DOMAIN.csr
echo "✓ Generated $DOMAIN signing request key"
# Create a config file for the extensions
>$DOMAIN.ext cat <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth,clientAuth
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN # Be sure to include the domain name here because Common Name is not so commonly honoured by itself
DNS.2 = *.$DOMAIN # Optionally, add additional domains (I've added a subdomain here)
EOF
# Create the signed certificate
openssl x509 -req -in $DOMAIN.csr -trustout -CA localCA.pem -CAkey localCA.key -CAcreateserial \
-out $DOMAIN.crt -days 3650 -sha256 -extfile $DOMAIN.ext
echo "✓ Generated *.$DOMAIN signed certificate key"
[[ ! $(grep "^127.0.0.1 \*.$DOMAIN" /etc/hosts) ]] \
  && echo '127.0.0.1 *.local.dev' | sudo tee -a /etc/hosts
echo "✓ Added *.$DOMAIN to /etc/hosts"
sed -i -e "s/\.\/env\/ssl\/certs\/[^:]*.key/\.\/env\/ssl\/certs\/$DOMAIN.key/g" $BASEDIR/../../docker-compose.yml
sed -i -e "s/\.\/env\/ssl\/certs\/[^:]*.crt/\.\/env\/ssl\/certs\/$DOMAIN.crt/g" $BASEDIR/../../docker-compose.yml
echo "✓ Updated docker-compose with newly generated file"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo mkdir /usr/local/share/ca-certificates/extra
    sudo cp localCA.pem /usr/local/share/ca-certificates/extra/root.cert.crt
    sudo update-ca-certificates
elif [[ "$OSTYPE" == "darwin"* ]]; then
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain localCA.pem
fi
echo "✓ Imported the trusted certificate to system"
echo "✓ Done!"

