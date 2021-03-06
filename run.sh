#!/usr/bin/env bash

function Status() {
    if STATUS=$(vulcano-cli masternode status 2>&1); then
        TXHASH=$(jq -r .txhash <<< "$STATUS")
        TXN=$(jq -r .outputidx <<< "$STATUS")
        TX="$TXHASH:$TXN"
        ADDRESS=$(jq -r .addr <<< "$STATUS")
        MESSAGE=$(jq -r .message <<< "$STATUS")
        whiptail --title "Bulwark Masternode" --msgbox "TX: $TX\nAddress: $ADDRESS\nStatus: $MESSAGE" 10 78
    else
        whiptail --title "Bulwark Masternode" --msgbox "Failed retriving masternode status.\n$STATUS" 10 78
    fi
}

function Restart() {
    sudo service vulcanod restart
    until vulcano-cli getinfo >/dev/null; do
        sleep 1;
    done
}

function Refresh() {
    sudo service vulcanod stop
    rm -rf ~/.vulcanocore/blocks ~/.vulcanocore/database ~/.vulcanocore/chainstate ~/.vulcanocore/peers.dat
    sudo service vulcanod start
    until vulcano-cli getinfo >/dev/null; do
        sleep 1;
    done
}

function Update() {
    cd /opt/masternode
    sudo git pull
    exec /opt/masternode/run.sh
}

function Shell() {
    exit 0
}

function Menu() {
    SEL=$(whiptail --nocancel --title "Vulcano Masternode" --menu "Choose an option" 16 78 8 \
        "Status" "Display masternode status." \
        "Restart" "Restart masternode." \
        "Refresh" "Wipe and reinstall blockchain." \
        "Update" "Update running masternode." \
        "Shell" "Drop to bash shell." \
        3>&1 1>&2 2>&3)
    case $SEL in
        "Status") Status;;
        "Restart") Restart;;
        "Refresh") Refresh;;
        "Update") Update;;
        "Shell") Shell;;
    esac
}

if ! grep -q "masternodeprivkey=" ~/.vulcanocore/vulcano.conf; then
    cd /opt/masternode
    sudo git pull
    bash /opt/masternode/install.sh
fi

while true; do Menu; done
