#!/bin/sh
export HOME="/home/$USER"
cat /webapp/nginx.conf.template | envsubst '$JPY_BASE_USER_URL $URL_ID' > /webapp/nginx.conf
nginx -c /webapp/nginx.conf
