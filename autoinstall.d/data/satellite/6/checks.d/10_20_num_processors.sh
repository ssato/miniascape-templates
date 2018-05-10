#! /bin/bash
#
# Check if the number of processors is much than required.
#
set -ex

# _CHECK_MIN_NPROC
source ${0%/*}/../config.sh 2>/dev/null || :

# Satellite 6.3 Installation Guide, 2.1. System Requirements:
# https://red.ht/2G1RfyB
min_nproc=${_CHECK_MIN_NPROC:-4}

nproc=$(awk -F ': ' '/^processor/{ nproc = $2 }; END { print ++nproc }' < /proc/cpuinfo)
(( ${nproc} >= ${min_nproc} )) || {
  echo 'Error: number of processors detected is fewer than required!'
  exit 1
}

# vim:sw=2:ts=2:et:
