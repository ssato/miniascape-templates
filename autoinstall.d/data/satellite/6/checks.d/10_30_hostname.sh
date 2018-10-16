#! /bin/bash
#
# - Satellite 6.3 Installation Guide, 2.1. System Requirements:
#   https://red.ht/2G1RfyB
#
set -ex

# _CHECK_FQDN
source ${0%/*}/../config.sh 2>/dev/null || :

hostname=${_CHECK_FQDN:-$(hostname -f)}
[[ ${hostname} =~ [a-z0-9.-]+ ]] || {
  echo "Error: Hostname should contain lower-case letters, numbers, dots (.) and hyphens (-) only" >&2
  exit 1
}

[[ ${hostname} =~ .+[.].+ ]] || {
  echo "Error: FQDN is not set (no domain componet is foun in 'hostname -f' output" >&2
}
# vim:sw=2:ts=2:et:
