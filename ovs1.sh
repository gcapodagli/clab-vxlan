#!/bin/bash

ID=`id -u`
if [ $ID -ne 0 ]; then
   echo "deve essere eseguito come utente privilegiato"
   exit 1
fi

#avvio di open vswitch
echo "avvio di ovs"
docker exec clab-vxlan-vtep1 /usr/share/openvswitch/scripts/ovs-ctl start --system-id=random
docker exec clab-vxlan-vtep1 ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
                     --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                     --private-key=db:Open_vSwitch,SSL,private_key \
                     --certificate=db:Open_vSwitch,SSL,certificate \
                     --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
                     --pidfile --detach
docker exec clab-vxlan-vtep1 ovs-vsctl --no-wait init
docker exec clab-vxlan-vtep1 ovs-vswitchd --pidfile --detach
for br in `docker exec clab-vxlan-vtep1 ovs-vsctl list-br`; do docker exec clab-vxlan-vtep1 ovs-vsctl del-br ${br}; done
docker exec clab-vxlan-vtep1 ovs-vsctl add-br ovs0
#inserimento delle regole per le vxlan
echo "inserimento vxlan1"
docker exec clab-vxlan-vtep1 ovs-vsctl add-port ovs0 eth2 tag=10
docker exec clab-vxlan-vtep1 ovs-vsctl add-port ovs0 vxlan1 tag=10 -- set interface vxlan1 type=vxlan \
        options:key=10 options:remote_ip=192.168.2.2
echo "inserimento vxlan2"
docker exec clab-vxlan-vtep1 ovs-vsctl add-port ovs0 eth3 tag=20
docker exec clab-vxlan-vtep1 ovs-vsctl add-port ovs0 vxlan2 tag=20 -- set interface vxlan2 type=vxlan \
        options:key=20 options:remote_ip=192.168.2.2
echo "."