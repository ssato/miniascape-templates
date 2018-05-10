#! /bin/bash
#
# Check if the number of processors is much than required.
#
set -ex

# Satellite 6.3 Installation Guide, 2.1. System Requirements:
# https://red.ht/2G1RfyB
[[ $(id -u) = 0 ]] || {
  echo 'Error: You must be root to install and setup Satellite!'
  exit 1
}

# vim:sw=2:ts=2:et:
