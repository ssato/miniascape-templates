#! /bin/bash
#
# Register and setup Yum repos for RHEL host works as an Ansible Tower server.
#
# Author: Satoru SATOH <ssato@redhat.com>
# License: MIT
#
# Usage: ./$0 [Options]
#
# .. seealso:: https://docs.ansible.com/ansible-tower/latest/html/installandreference/tower_installer.html#bundled-install
set -ex

RHSM_USER=
RHSM_NAME=$(hostname -f)
RHSM_CONSUMER_ID=

YUM_REPOS="
rhel-7-server-rpms
rhel-7-server-extras-rpms
"

show_help () {
    cat << EOU
Usage: $0 [Options ...]
Options:
    -u      specify rhsm username
    -n      specify name of the system to register
    -I      specify the consumer ID of the system registered previously

    -h      show this help text
EOU
}

while getopts u:n:I:h OPT
do
    case "${OPT}" in
        u) RHSM_USER=${OPTARG}
           ;;
        n) RHSM_NAME=${OPTARG}
           ;;
        I) RHSM_CONSUMER_ID=${OPTARG}
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

# rhsm registraion:
subscription-manager identity || {
rhsm_opt="--auto-attach --username=${RHSM_USER:?}"
[[ -n ${RHSM_CONSUMER_ID} ]] && rhsm_opt="${rhsm_opt} --consumerid=${RHSM_CONSUMER_ID:?}" || :
subscription-manager register ${rhsm_opt}
}

(
enable_repos_opt="$(for repo in ${YUM_REPOS:?}; do echo '--enable ${repo:?} '; done)"
subscription-manager repos --disable '*' ${enable_repos_opt:?}
yum repolist
)

# vim:sw=4:ts=4:et:
