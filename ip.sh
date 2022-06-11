#!/bin/bash

ID=`id -u`
if [ $ID -ne 0 ]; then
   echo "deve essere eseguito come utente privilegiato"
   exit 1
fi

#configurazione router
echo "clab-vxlan-router"
docker exec clab-vxlan-router ip addr add 192.168.1.1/24 dev eth1
docker exec clab-vxlan-router ip addr add 192.168.2.1/24 dev eth2
echo "."

#configurazione vtep1
echo "clab-vxlan-vtep1"
docker exec clab-vxlan-vtep1 ip addr add 192.168.1.2/24 dev eth1
docker exec clab-vxlan-vtep1 ip route add 192.168.2.0/24 via 192.168.1.1
echo "."

#configurazione vtep2
echo "clab-vxlan-vtep2"
docker exec clab-vxlan-vtep2 ip addr add 192.168.2.2/24 dev eth1
docker exec clab-vxlan-vtep2 ip route add 192.168.1.0/24 via 192.168.2.1
echo "."

#configurazione endpoint
echo "clab-vxlan-black1/blue1/black2/blue2"
docker exec clab-vxlan-black1 ip addr add 10.0.0.1/24 dev eth1
docker exec clab-vxlan-blue1 ip addr add 10.0.0.1/24 dev eth1
docker exec clab-vxlan-black2 ip addr add 10.0.0.2/24 dev eth1
docker exec clab-vxlan-blue2 ip addr add 10.0.0.2/24 dev eth1
echo "."