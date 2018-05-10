#! /bin/bash
#
# Check if it's running RHEL Server and its version is newer than required one,
# version and release.
#
set -ex

# _CHECK_MIN_RHEL_VER, _CHECK_MIN_RHEL_REL, _CHECK_ARCH
source ${0%/*}/../config.sh 2>/dev/null || :

# Requires RHEL Server 7.4+ (x86_64)
rhel_min_ver=${_CHECK_MIN_RHEL_VER:-7}
rhel_min_rel=${_CHECK_MIN_RHEL_REL:-4}
arch=${_CHECK_ARCH:-x86_64}

test -f /etc/redhat-release

rhel_release=$(cat /etc/redhat-release)
[[ ${rhel_release} =~ 'Red Hat Enterprise Linux Server release '${rhel_min_ver:?}\.[${rhel_min_rel:?}-9] ]] || {
  echo ${rhel_release} >&2
  exit 1
}
[[ $(uname -p) = ${arch} ]] || {
  uname -a
  exit 1
}

# vim:sw=2:ts=2:et:
