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

EPEL_RELEASE_RPM_URL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

show_help () {
    cat << EOU
Usage: $0 [Options ...]
Options:
    -w      specify workdir to download and extract the tower installation archive
    -U      specify the URL to download the tower installation archive from
    -p      specify the password
    -h      show this help text
EOU
}

while getopts w:U:p:h OPT
do
    case "${OPT}" in
        w) WORKDIR=${OPTARG}
           ;;
        U) TOWER_ARCHIVE_URL=${OPTARG}
           ;;
        p) PASSWORD=${OPTARG}
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

TOWER_DIRNAME=$(ls -1t ${TOWER_ARCHIVE_NAME/-latest*/}*)
(
cd ${TOWER_DIRNAME:?}
sed -i.save "s/password=''/password='${PASSWORD:?}'/g" inventory
time ./setup.sh
)
)

# tower-cli:
yum install -y ${EPEL_RELEASE_RPM_URL:?}
sed -i.save 's/enabled=.*/enabled=0/g' /etc/yum.repos.d/epel.repo
yum install -y --enablerepo=epel ansible-tower-cli

TOWER_CLI_CFG=$HOME/.tower_cli.cfg
test -f ${TOWER_CLI_CFG:?} || {
touch ${TOWER_CLI_CFG}
chmod 600 ${TOWER_CLI_CFG}
cat << EOF > ${TOWER_CLI_CFG}
[general]
host = https://localhost:443
username = admin
password = ${PASSWORD}
verify_ssl = false
EOF
}

# ssh key and localhost management:
test -f /root/.ssh/id_rsa || ssh-keygen -f /root/.ssh/id_rsa -N ''
ssh-copy-id root@localhost
tower-cli credential create --name Tower_Host_root_Cred_0 --organization Default --kind ssh --ssh-key-data /root/.ssh/id_rsa

# vim:sw=4:ts=4:et:
