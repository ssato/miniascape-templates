#! /bin/bash
#
# Setup proxy
#    Since Satellite 6.7, a http proxy for synchronizing repositories can be
#    set after running satellite-installer. The options for specifying a
#    http proxy is deleted from satellite-installer.
#
# Author: Masatake YAMATO <yamato@redhat.com>
# License: MIT
#
# References:
# - Satellite 6.7 Installing Satellite Server from a Connected Network,
#   3.4.1. Adding a Default HTTP Proxy to Satellite
#
set -ex
 
# PROXY_URL, PROXY_PORT
source ${0%/*}/config.sh
 
if [ -z "${PROXY_URL}" ]; then
    exit 0
fi
 
hammer --no-use-defaults http-proxy create --name=myproxy --url ${PROXY_URL}
hammer --no-use-defaults settings set --name=content_default_http_proxy --value=myproxy

if [ -z "${PROXY_PORT}" ]; then
    exit 0
fi
case "${PROXY_PORT}" in
    # predefined squid_port_t
    3128|3401|4827)
	exit 0
	;;
    # predefined http_cache_port_t
    8080|8118|8123|10010|1000[0-9])
	exit 0
	;;
esac
semanage port -a -t http_cache_port_t -p tcp ${PROXY_PORT}
