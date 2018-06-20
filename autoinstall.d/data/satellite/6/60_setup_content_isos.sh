#! /bin/bash
#
# Configure to import from local repo data mirror from content iso images.
#
# - Satellite 6.3 Content Management Guide, Appendix C. Importing Content ISOs
#   into a Connected Satellite: https://red.ht/2ywvYOK
#
# Author: Satoru SATOH <ssato/redhat.com>
# License: MIT
#
set -ex

# CONTENT_ISO_REPOS_TOPDIR, CONTENT_ISO_REPOS_CONF,
# CONTENT_ISO_REPOS_CONF_CONTENT, CONTENT_ISO_REPO_CHECK_FILES
source ${0%/*}/config.sh

f=${CONTENT_ISO_REPOS_CONF:?}

test -d ${f%/*} || mkdir -p ${f%/*}
test -f $f && cp $f $f.save || :
cat << EOF > $f
${CONTENT_ISO_REPOS_CONF_CONTENT}
EOF

d=${CONTENT_ISO_REPOS_TOPDIR:?}
test -d $d || (
mkdir -p $d
chcon -R --reference /var/lib/pulp $d
chown -R apache:apache $d
)

# vim:sw=2:ts=2:et:
