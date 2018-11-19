#! /bin/bash
#
# Prepare ansible-tower for 
#
# Author: Satoru SATOH <ssato@redhat.com>
# License: MIT
#
# Usage: ./$0 [Options]
#
set -ex

WORKDIR=/root/setup/
TOWER_ARCHIVE_URL=https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz

show_help () {
    cat << EOU
Usage: $0 [Options ...]
Options:
    -w      specify workdir to download and extract the tower installation archive
    -U      specify the URL to download the tower installation archive from
    -h      show this help text
EOU
}

while getopts w:U:h OPT
do
    case "${OPT}" in
        w) WORKDIR=${OPTARG}
           ;;
        U) TOWER_ARCHIVE_URL=${OPTARG}
           ;;
        h) show_help
           exit 0
           ;;
        \?) show_help
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

[[ -n ${WORKDIR} ]] && mkdir -p ${WORKDIR} || :
(
cd ${WORKDIR}
curl --connect-timeout 5 --max-time 300 -O ${TOWER_ARCHIVE_URL}
tar xf ${TOWER_ARCHIVE_URL##*/}
)

# vim:sw=4:ts=4:et:
