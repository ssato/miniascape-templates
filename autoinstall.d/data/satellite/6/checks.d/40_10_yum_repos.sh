#! /bin/bash
#
# Check yum repos to enable and disable.
#
# - Satellite 6.3 Installation Guide, 3.1.3. Configuring Repositories:
#   https://red.ht/2K7Xof6
#
set -ex

# _CHECK_YUM_REPOS_TO_ENABLE, _CHECK_YUM_REPOS_TO_DISABLE
source ${0%/*}/../config.sh 2>/dev/null || :

yum_repos_to_disable="${_CHECK_YUM_REPOS_TO_DISABLE:-*}"
yum_repos_to_enable="
${_CHECK_YUM_REPOS_TO_ENABLE:-
rhel-7-server-rpms
rhel-server-rhscl-7-rpms
rhel-7-server-satellite-6.3-rpms
}
"

subscription-manager identity && {
  repo_opts=""
  for repo in ${yum_repos_to_disable}; do
    repo_opts="${repo_opts} --disable '${repo}'"
  done
  subscription-manager repos ${repo_opts}

  for repo in ${yum_repos_to_enable}; do
    repo_opts="${repo_opts} --enable '${repo}'"
  done
  subscription-manager repos ${repo_opts}
} || {
  for repo in ${yum_repos_to_disable}; do
    repo_opts="${repo_opts} --disable '${repo}'"
  done
  yum-config-manager repos ${repo_opts}

  for repo in ${yum_repos_to_enable}; do
    repo_opts="${repo_opts} --enable '${repo}'"
  done
  yum-config-manager repos ${repo_opts}
}

# vim:sw=2:ts=2:et:
