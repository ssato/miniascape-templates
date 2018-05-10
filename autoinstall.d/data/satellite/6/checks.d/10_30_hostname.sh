#! /bin/bash
#
set -ex

# _CHECK_FQDN
source ${0%/*}/../config.sh 2>/dev/null || :

# Satellite 6.3 Installation Guide, 2.1. System Requirements:
# https://red.ht/2G1RfyB
hostname=${_CHECK_FQDN:-$(hostname -f)}
[[ ${hostname} =~ [a-z0-9.-]+ ]] || {
  echo "Error: Hostname should contain lower-case letters, numbers, dots (.) and hyphens (-) only"
  exit 1
}

# vim:sw=2:ts=2:et:
