#! /bin/bash
# 
# License: MIT
# Author: Satoru SATOH <satoru.satoh at gmail.com>
# 
# References:
# 
# * http://rwmj.wordpress.com/2010/10/26/tip-find-the-ip-address-of-a-virtual-machine/
# * http://serverfault.com/questions/101982/get-list-of-dhcp-clients-with-kvmlibvirt
# * http://avahi.org/wiki/AvahiAndUnicastDotLocal
# 

SUDO=$(test $UID = 0 && echo "" || echo "sudo")
ARPTBL=$(/sbin/arp -an)


list_vm_macs () {
    domain=$1
    ${SUDO} virsh dumpxml ${domain} | sed -nre 's,.*<mac address=.([a-f0-9:]+).*,\1,p'
}


## arp output example:
#
# ssato@gescom% /sbin/arp -an
#? (192.168.151.225) at 52:54:00:9d:a1:d8 [ether] on virbr1
#? (192.168.152.218) at 52:54:00:0c:3f:e6 [ether] on virbr2
#? (172.22.0.1) at 00:0d:02:37:e8:6e [ether] on eth0
#ssato@gescom%

resolv_ip () {
    mac=$1
    echo "$ARPTBL" | sed -nre "s,. \(([^\)]+)\) .+ $mac .*,\1,p"
}


# main:
domain=$1

if test -z "${domain}"; then
    echo "Usage: $0 DOMAIN"
    exit 1
fi

for mac in $(list_vm_macs $domain); do
    resolv_ip $mac
done
