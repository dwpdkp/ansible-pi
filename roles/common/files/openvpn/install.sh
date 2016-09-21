#!/bin/bash
VERSION="0.2"

#SETTINGS
OPENVPN_BIN=/usr/sbin/openvpn
INSTALL_PATH=/etc/openvpn

PV_CONF=privatvpn.conf
PV_CERT=ca.crt
PV_LOGIN=privatvpn.login
PV_SCR=privatvpn

###############################################################################
#                         FETCHING USERINPUT DATA                             #
###############################################################################

printf "PrivateVPN Linux OpenVPN Installer v$VERSION\n"
printf " * Checking for OpenVPN - "
if [ -e $OPENVPN_BIN ]; then
 printf "OK\n"
else 
 printf "Not Found\n - Unable to find OpenVPN, enter PATH where OpenVPN bin is installed.\n"
 printf " [PATH]: "
 read -e OPENVPN_BIN
fi

if [ ! -e $OPENVPN_BIN ]; then
 printf " - ERROR! Unable to find OpenVPN, please install it before running this script.\n"
 exit
fi 

printf " * Enter login details for PrivateVPN\n - [username]: "
read -e USERNAME
printf " - [password]: "
read -e PASSWORD

printf " * Installing cert/conf to default location (/etc/openvpn), write c to edit installpath.\n"

while true; do
   printf " - Continue [yes/no/c] "
   read SELECT
   case $SELECT in
      'yes') break ;;
      'no') exit ;;
      'c') printf " - [PATH]:" ; read -e INSTALL_PATH ; break ;;
      '*') printf " - Unknown input\n" ;;
   esac 
done

###############################################################################
#                         GENERATING OPENVPN FILE                             #
###############################################################################

printf "client\n" > $PV_CONF
printf "remote vpn-nl1.privatevpn.com 21000\n" >> $PV_CONF
printf "remote vpn-nl1.privatevpn.com 21001\n" >> $PV_CONF
printf "remote vpn-nl1.privatevpn.com 21002\n" >> $PV_CONF
printf "remote vpn-nl1.privatevpn.com 21003\n" >> $PV_CONF
printf "dev tap\n" >> $PV_CONF
printf "proto udp\n" >> $PV_CONF
printf "resolv-retry infinite\n" >> $PV_CONF
printf "nobind\n" >> $PV_CONF
printf "persist-key\n" >> $PV_CONF
printf "persist-tun\n" >> $PV_CONF
printf "ca $INSTALL_PATH/$PV_CERT\n" >> $PV_CONF
printf "auth-user-pass $INSTALL_PATH/$PV_LOGIN\n" >> $PV_CONF
printf "ns-cert-type server\n" >> $PV_CONF
printf "comp-lzo\n" >> $PV_CONF
printf "verb 3\n" >> $PV_CONF
printf "log-append /var/log/openvpn.log\n" >> $PV_CONF

printf "$USERNAME\n" > $PV_LOGIN
printf "$PASSWORD\n" >> $PV_LOGIN

printf "#!/bin/bash\n" > $PV_SCR
printf "$OPENVPN_BIN $INSTALL_PATH/$PV_CONF" >> $PV_SCR

###############################################################################
#                    INSTALLING FILES AND CLEANING UP                         #
###############################################################################

/bin/cp $PV_CONF $INSTALL_PATH
/bin/cp $PV_CERT $INSTALL_PATH
/bin/cp $PV_LOGIN $INSTALL_PATH
/bin/cp $PV_SCR /usr/bin/
/bin/chmod +x /usr/bin/$PV_SCR
/bin/rm $PV_CONF
/bin/rm $PV_LOGIN
/bin/rm $PV_SCR

printf " * Installation Complete, run \"privatvpn\" to connect to PrivatVPN service\n"
