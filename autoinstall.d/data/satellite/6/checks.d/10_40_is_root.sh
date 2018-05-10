#! /bin/bash
#
# - Satellite 6.3 Installation Guide, 2.1. System Requirements:
#   https://red.ht/2G1RfyB
#
set -ex

[[ $(id -u) = 0 ]] || {
  echo 'Error: You must be root to install and setup Satellite!' >&2
  exit 1
}

# vim:sw=2:ts=2:et:
