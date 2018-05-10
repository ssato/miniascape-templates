#! /bin/bash
#
# - Satellite 6.3 Installation Guide, 2.1. System Requirements:
#   https://red.ht/2G1RfyB
#
set -ex

umask_exp="0022"

[[ $(umask) = "${umask_exp}" ]] || {
  echo "Error: umask must be ${umask_exp} but was $(umask)"
  exit 1
}

# vim:sw=2:ts=2:et:
