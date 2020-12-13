#!/bin/bash

rm -rf misun_tmp

killall -9 firecracker 2> /dev/null
rm -rf misun.sock misun.log

sudo ./00_setup_host.sh
sudo ./run-system.sh -d misun_tmp

FC=../bin/firecracker
SOCK=$(pwd)/misun.sock
FC_PID=
KERNEL=../img/bench-ssh-vmlinux
ROOTFS=../img/bench-ssh-disk.img
# KERNEL=../img/boot-time-pci-vmlinux
# ROOTFS=../img/boot-time-disk.img
CORES=1
MEM=256
NETCFG=
DISKCFG=
DEBUG=
ID=0


$FC --api-sock "$SOCK" 2>  misun.log &
FC_PID=$!

while [ ! -e "$SOCK" ]; do
    sleep 0.001s
done

TAP_DEV=$(./util_ipam.sh -t $ID)
TAP_IP=$(./util_ipam.sh -h $ID)
VM_MAC=$(./util_ipam.sh -a $ID)
VM_IP=$(./util_ipam.sh -v $ID)
VM_MASK=$(./util_ipam.sh -m $ID)
NETCFG="-n ${TAP_DEV},${TAP_IP},${VM_MAC},${VM_IP},${VM_MASK}"
echo $NETCFG
echo

../bin/config-fc -s $SOCK -k ${KERNEL} -r ${ROOTFS} -c ${CORES} -m ${MEM} ${NETCFG} ${DISKCFG} ${DEBUG}
echo here?
wait $FC_PID || true