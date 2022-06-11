#!/bin/bash

ID=`id -u`
if [ $ID -ne 0 ]; then
   echo "deve essere eseguito come utente privilegiato"
   exit 1
fi

clab graph --topo vxlan.yml
