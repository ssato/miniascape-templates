#! /bin/bash
#
# - Satellite 6.3 Installation Guide, 2.1. System Requirements:
#   https://red.ht/2G1RfyB
set -ex

# _CHECK_FQDN
source ${0%/*}/../config.sh 2>/dev/null || :

fqdn=${_CHECK_FQDN:-$(hostname -f)}

which host 2>/dev/null >/dev/null && host ${fqdn} || :
ping -c 1 -w 5 ${fqdn}

# vim:sw=2:ts=2:et:
