#! /bin/bash
#
# Check if RPMs such as java and puppet causing issues are installed.
#
# - Satellite 6.3 Installation Guide, 2.3. Supported Operating Systems
#   https://red.ht/2Ia1uqA
#
set -ex

# _CHECK_RPMS_MUST_NOT_INSTALL
source ${0%/*}/../config.sh 2>/dev/null || :

rpms_not_to_install="
${_CHECK_RPMS_MUST_NOT_INSTALL}
java*
puppet*
"

found=$(rpm -qa ${rpms_not_to_install} 2>/dev/null || : )
test -z "${found}" || {
  cat << EOM >&2
Error: You should uninstall the following RPMs causing issues:
${found}

See also: https://red.ht/2Ia1uqA
EOM
  exit 1
}

# vim:sw=2:ts=2:et:
