#! /bin/bash
#
# Check if the RAM (memory) and swap is enough for Satellite.
#
# - Satellite 6.3 Installation Guide, 2.1. System Requirements:
#   https://red.ht/2G1RfyB
#
set -ex

# _CHECK_MIN_RAM, _CHECK_MIN_SWAP
source ${0%/*}/../config.sh 2>/dev/null || :

min_ram=${_CHECK_MIN_RAM:-20}   # [GiB]
min_swap=${_CHECK_MIN_SWAP:-4}  # Do.

ram_size=$(free 2>/dev/null | awk '/Mem:/ { print $2 }')  # [KiB]
swap_size=$(free 2>/dev/null | awk '/Swap:/ { print $2 }')  # Do.
test -n "${ram_size}"
test -n "${swap_size}"

(( ${ram_size} >= ${min_ram} * 1024 * 1024 )) || {
  echo 'Error: RAM is not enough: ${ram_size} [KiB] < ${min_ram} [GiB]) !' >&2 
  exit 1
}

(( ${swap_size} >= ${min_swap} * 1024 * 1024 )) || {
  echo 'Error: Swap is not enough: ${swap_size} [KiB] < ${min_swap} [GiB]) !' >&2
  exit 1
}

# vim:sw=2:ts=2:et:
