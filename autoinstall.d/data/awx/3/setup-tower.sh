#! /bin/bash
#
# Setup Ansible Tower w/ using tower-cli, etc.
#
# Author: Satoru SATOH <ssato@redhat.com>
# License: MIT
#
# Usage: ./$0 [Options]
#
# .. seealso:: https://github.com/ansible/tower-cli/blob/master/docs/source/cli_ref/examples/fake_data_creator.sh
#
set -ex

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

# vim:sw=4:ts=4:et:
