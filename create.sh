#!/bin/bash

ID=`id -u`
if [ $ID -ne 0 ]; then
   echo "deve essere eseguito come utente privilegiato"
   exit 1
fi

clab deploy --reconfigure --topo vxlan.yml
echo "inserimento delle entry nelle tabelle di routing"
./ip.sh
echo "configurazione open vswitch"
./ovs1.sh
./ovs2.sh
