#!/bin/bash
# install dnsmasq for domain *.local.dev
BASEDIR="$( cd "$( dirname "$0" )" && pwd )"
DEFAULTDOMAIN=local.dev
printf "${green}Choose a domain(e.g. ${red}test ${green}for ${red}*.test${green}, default ${green}local.dev ${green}is used): "
read domain
[[ -z $domain ]] \
 && domain=$DEFAULTDOMAIN
echo "✓ $domain"
echo "Installing dnsmasq..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo "$BASEDIR/settings/dnsmaslinux.sh" ".$domain"
elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl -s https://raw.githubusercontent.com/beslovas/dnsmasq4dev/master/setup.sh -o /tmp/setupdnsmasq.sh
        chmod +x /tmp/setupdnsmasq.sh
        /tmp/setupdnsmasq.sh -d $domain
        rm -f /tmp/setupdnsmasq.sh
elif [[ "$OSTYPE" == "cygwin" ]]; then
        echo Coming soon
elif [[ "$OSTYPE" == "msys" ]]; then
        echo Coming soon
elif [[ "$OSTYPE" == "win32" ]]; then
        echo Coming soon
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        echo Coming soon
else
        echo "Unknow system"
fi
echo "✓ Dnsmasq has been installed"
chmod +x $BASEDIR/env/ssl/opensslgen.sh && $BASEDIR/env/ssl/opensslgen.sh "$domain"
