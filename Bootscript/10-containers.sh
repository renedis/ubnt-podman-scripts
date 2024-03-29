#!/bin/sh

## configuration variables:
VLAN=5
IPV4_IP_NETDATA="10.0.5.4"
IPV4_IP_UPTIMEKUMA="10.0.5.5"
IPV4_IP_PROXYMANAGER="10.0.5.6"
IPV4_IP_MOSQUITTO="10.0.5.7"
IPV4_IP_TVHEADEND="10.0.5.8"
IPV4_IP_OSCAM="10.0.5.9"

# This is the IP address of the container. You may want to set it to match
# your own network structure such as 192.168.5.3 or similar.
IPV4_GW="10.0.5.1/24"
# As above, this should match the gateway of the VLAN for the container
# network as above which is usually the .1/24 range of the IPV4_IP

# container name; e.g. nextdns, pihole, adguardhome, etc.
CONTAINER_NETDATA=netdata
CONTAINER_UPTIMEKUMA=uptimekuma
CONTAINER_PROXYMANAGER=proxymanager
CONTAINER_MOSQUITTO=mosquitto
CONTAINER_TVHEADEND=tvheadend
CONTAINER_OSCAM=oscam

## network configuration and startup:
CNI_PATH=/mnt/data/podman/cni
if [ ! -f "$CNI_PATH"/macvlan ]; then
    mkdir -p $CNI_PATH
    curl -L https://github.com/containernetworking/plugins/releases/download/v0.9.0/cni-plugins-linux-arm64-v0.9.0.tgz | tar -xz -C $CNI_PATH
fi

mkdir -p /opt/cni
rm -f /opt/cni/bin
ln -s $CNI_PATH /opt/cni/bin

for file in "$CNI_PATH"/*.conflist
do
    if [ -f "$file" ]; then
        ln -fs "$file" "/etc/cni/net.d/$(basename "$file")"
    fi
done

# set VLAN bridge promiscuous
ip link set br${VLAN} promisc on

# create macvlan bridge and add IPv4 IP
ip link add br${VLAN}.mac link br${VLAN} type macvlan mode bridge
ip addr add ${IPV4_GW} dev br${VLAN}.mac noprefixroute

# set macvlan bridge promiscuous and bring it up
ip link set br${VLAN}.mac promisc on
ip link set br${VLAN}.mac up

#######################################################################################
# add IPv4 route to DNS container
ip route add ${IPV4_IP_NETDATA}/32 dev br${VLAN}.mac
#######################################################################################
# add IPv4 route to DNS container
ip route add ${IPV4_IP_UPTIMEKUMA}/32 dev br${VLAN}.mac
#######################################################################################
# add IPv4 route to DNS container
ip route add ${IPV4_IP_PROXYMANAGER}/32 dev br${VLAN}.mac
#######################################################################################
# add IPv4 route to DNS container
ip route add ${IPV4_IP_MOSQUITTO}/32 dev br${VLAN}.mac
#######################################################################################
# add IPv4 route to DNS container
ip route add ${IPV4_IP_TVHEADEND}/32 dev br${VLAN}.mac
#######################################################################################
# add IPv4 route to DNS container
ip route add ${IPV4_IP_OSCAM}/32 dev br${VLAN}.mac
#######################################################################################


#######################################################################################
if podman container exists ${CONTAINER_NETDATA}; then
  podman start ${CONTAINER_NETDATA}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER_NETDATA not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi
#######################################################################################
if podman container exists ${CONTAINER_UPTIMEKUMA}; then
  podman start ${CONTAINER_UPTIMEKUMA}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER_UPTIMEKUMA not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi
#######################################################################################
if podman container exists ${CONTAINER_PROXYMANAGER}; then
  podman start ${CONTAINER_PROXYMANAGER}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER_PROXYMANAGER not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi
#######################################################################################
if podman container exists ${CONTAINER_MOSQUITTO}; then
  podman start ${CONTAINER_MOSQUITTO}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER_MOSQUITTO not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi
#######################################################################################
if podman container exists ${CONTAINER_TVHEADEND}; then
  podman start ${CONTAINER_TVHEADEND}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER_TVHEADEND not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi
#######################################################################################
if podman container exists ${CONTAINER_OSCAM}; then
  podman start ${CONTAINER_OSCAM}
else
  logger -s -t podman-dns -p ERROR Container $CONTAINER_OSCAM not found, make sure you set the proper name, you can ignore this error if it is your first time setting it up
fi

