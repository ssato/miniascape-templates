#! /bin/bash
#
# Download and install Ansible Tower.
#
# Author: Satoru SATOH <ssato@redhat.com>
# License: MIT
#
# Usage: ./$0 [Options]
#
set -ex

WORKDIR=/root/setup/
TOWER_ARCHIVE_URL=https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz
PASSWORD=
LICENSE_TXT=

show_help () {
    cat << EOU
Usage: $0 [Options ...]
Options:
    -w      specify workdir to download and extract the tower installation archive
    -U      specify the URL to download the tower installation archive from
    -p      specify the password
    -L      specify the path of the license file
    -h      show this help text
EOU
}

while getopts w:U:p:L:h OPT
do
    case "${OPT}" in
        w) WORKDIR=${OPTARG}
           ;;
        U) TOWER_ARCHIVE_URL=${OPTARG}
           ;;
        p) PASSWORD=${OPTARG}
           ;;
        L) LICENSE_TXT=${OPTARG}
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

[[ -n ${PASSWORD} ]] || PASSWORD=$(read -p "Password: " -s -t 10)
[[ -n ${WORKDIR} ]] && mkdir -p ${WORKDIR} || :
(
cd ${WORKDIR}
curl --connect-timeout 5 --max-time 300 -O ${TOWER_ARCHIVE_URL}

TOWER_ARCHIVE_NAME=${TOWER_ARCHIVE_URL##*/}
tar xf ${TOWER_ARCHIVE_NAME}

TOWER_DIRNAME=$(ls -1t ${TOWER_ARCHIVE_NAME/-latest*/}* | head -n 1)
[[ -n ${TOWER_DIRNAME} ]] && (
cd ${TOWER_DIRNAME:?}
sed -i.save "s/password=''/password='${PASSWORD:?}'/g" inventory
time ./setup.sh
)

# .. seealso:: https://access.redhat.com/solutions/3065701
[[ -n ${LICENSE_TXT} ]] || LICENSE_TXT=$(ls -1t license*.txt | head -n 1)
LICENSE_JSON="$(python -m json.tool ${LICENSE_TXT:?} | sed 's/}/    , \"eula_accepted\" : \"true\"}/')"
curl -k -H "Content-Type: application/json" -X POST -u admin:${PASSWORD} -d "${LICENSE_JSON}" https://$(hostname -f)/api/v1/config/
)

# vim:sw=4:ts=4:et:
