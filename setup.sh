#!/bin/bash
wrkDIR="/srv/Raspi-WaterTemp"
cd "$(dirname $0)"

if [[ $EUID != 0 ]] ; then
  echo -e "\e[91mYou must be root!\e[39m"
  echo "Exiting..."
  exit 1
fi

# Install Dependancies
#apt-get -y update && apt-get -y upgrade
#apt-get install -y apache2 php5 mysql-client mysql-server rrdtool

# Create Environment
# Copy/Edit files and make SymLinks
echo "Copying Files..."
cp -r ./root/* /

# Work from tmpFS as to not burn out SDCard.
searchSTR="tmpfs on ${wrkDIR}/www/graphs type tmpfs (rw,relatime,size=2048k)"
echo "Searching for tmpfs mount at ${wrkDIR}/www/graphs ..."
while read -r line
do
  case $line in
    ${searchSTR})
      echo -e "\e[92mFound!!\e[39m"
      echo -e "\e[91mYou only need to run this once!\e[39m"
      result=1
      break
      ;;
    *)
      echo -n "."
      result=0;;
  esac
done < <(mount)
if [ "$result" -eq "0" ]; then \
  echo "Mounting 2m tmpfs in ${wrkDIR}/www/graphs...";
  mount -t tmpfs -o size=2m tmpfs ${wrkDIR}/www/graphs/;
fi

# Fill tmpFS
cp -r ./tmpfs/* ${wrkDIR}/www/graphs/
chown -R www-data:www-data ${wrkDIR}/www/

# Gen Empty files
bash ${wrkDIR}/daemon/create_database.sh
bash ${wrkDIR}/daemon/create_graphs.sh

#Setup Apps.
a2enconf Raspi-WaterTemp
service apache2 reload

#edit rc.local

#useradd -r watertemp

#Test for 1-Wire Support & Temp Probe.

#Reboot
