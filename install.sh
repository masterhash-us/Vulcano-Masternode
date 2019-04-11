#!/usr/bin/env bash

while [ "$KEY" == "" ]
do
    KEY=$(whiptail --inputbox "Masternode Privkey" 8 78 --title "Vulcano Masternode Setup" --nocancel 3>&1 1>&2 2>&3)
done
echo "masternode=1" >> ~/.vulcanocore/vulcano.conf
echo "masternodeprivkey=$KEY" >> ~/.vulcanocore/vulcano.conf
sudo service vulcanod restart

until vulcano-cli getinfo >/dev/null; do
  sleep 1;
done
