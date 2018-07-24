#! /bin/bash
#
# An experimental and temporary workaround for rhbz#1593218.
#
# Author: Satoru SATOH <ssato@redhat.com>
# License: MIT
#
set -e

REPOS_TOPDIR=/var/lib/rhui/remote_share/published/yum/master/yum_distributor/
KEEP=1  # How much number of recent updateinfo.xml.gz are kept.
DRYRUN=${_DRYRUN:-no}

function show_help () {
    cat << EOH
Usage: $0 [Options...]
Options:
    -d            Dry run mode, that is, old updateinfo.xml.gz files are
                  printed and will not be removed.
    -k KEEP_NUM   Number of recent updateinfo.xml.gz files to keep.
                  KEEP_NUM must be greater than 1. [${KEEP}]
    -h            Show this help.
EOH
}

while getopts dk:h OPT
do
    case "${OPT}" in
        d) DRYRUN=yes
           ;;
        k) KEEP=${OPTARG}
           ;;
        h) show_help; exit 0
           ;;
        \?) echo "Invalid option!" > /dev/stderr; exit 1
           ;;
    esac
done
shift $((OPTIND - 1))

for repodata_dir in ${REPOS_TOPDIR:?}/*/*/repodata/; do
    removes=$(ls -1t ${repodata_dir}/*-updateinfo.xml.gz | sed "${KEEP:?}d")
    [[ ${DRYRUN:?} = "yes" ]] && echo "${removes}" || rm -f ${removes}
done

# vim:sw=4:ts=4:et:
