#! /bin/bash
#
# A script to collect help texts of tower-cli's sub commands recursively.
#
# Author: Satoru SATOH <ssato@redhat.com>
# License: MIT
#
# Usage: ./$0
#
# Example:
#
#
set -e

OUTPUTS_DIR=
OUT_HELP=0

show_help () {
    cat << EOU
Usage: $0 [Options ...]
Options:
    -o      specify outputs dir to save help texts for each sub commands
    -h      show this help text
EOU
}

list_subcmds_or_resources_from_out () {
    test "x$@" = "x" || echo "$@" | sed -nr '/^(Commands|Resources):/,${s/[[:space:]]+([[:lower:]_]+).*/\1/p}'
}

while getopts o:h OPT
do
    case "${OPT}" in
        o) OUTPUTS_DIR=${OPTARG}
           OUT_HELP=1
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

[[ -n ${OUTPUTS_DIR} ]] && mkdir -p ${OUTPUTS_DIR} || :

show_help_texts_recur () {
    local sc=$@
    local help=$($sc --help 2>/dev/null || echo '')
    [[ -n ${help} ]] && {

        local scs=$(list_subcmds_or_resources_from_out "$help")
        local cmd_s="${sc} --help"

        [[ ${OUT_HELP} -eq 1 ]] && {
            local output="${OUTPUTS_DIR}/${sc// /_}_help.txt"
            echo "[Info] Saving the output of '${cmd_s}' to ${output} ..."
            {
                echo "# ${cmd_s}"; echo "${help}"
            } > ${output}
        } || {
            echo "# ${cmd_s}"; echo "${help}"
        }
        for ssc in $scs; do show_help_texts_recur $sc $ssc; done
    } || :
}

show_help_texts_recur ${@:-tower-cli}

# vim:sw=4:ts=4:et:
