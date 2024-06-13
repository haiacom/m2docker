#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

VHOST_FILE="/etc/nginx/conf.d/vhost-default.conf"
NGINX_FILE="/etc/nginx/nginx.conf"

[ ! -z "${UPSTREAM_HOST}" ] && sed -i "s/!UPSTREAM_HOST!/${UPSTREAM_HOST}/" $VHOST_FILE
[ ! -z "${UPSTREAM_PORT}" ] && sed -i "s/!UPSTREAM_PORT!/${UPSTREAM_PORT}/" $VHOST_FILE
[ ! -z "${SSL_KEY}" ] && sed -i "s/!SSL_KEY!/${SSL_KEY}/" $VHOST_FILE
[ ! -z "${SSL_CERT}" ] && sed -i "s/!SSL_CERT!/${SSL_CERT}/" $VHOST_FILE
[ "${WITH_XDEBUG}" == "1" ] && sed -i "s/#include_xdebug_upstream/include/" $NGINX_FILE
[ ! -z "${NGINX_WORKER_PROCESSES}" ] && sed -i "s/!NGINX_WORKER_PROCESSES!/${NGINX_WORKER_PROCESSES}/" $NGINX_FILE
[ ! -z "${NGINX_WORKER_CONNECTIONS}" ] && sed -i "s/!NGINX_WORKER_CONNECTIONS!/${NGINX_WORKER_CONNECTIONS}/" $NGINX_FILE

# Check if the nginx syntax is fine, then launch.
nginx -t

exec "$@"
