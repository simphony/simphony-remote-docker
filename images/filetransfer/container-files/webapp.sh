#!/bin/sh
export HOME="/home/$USER"
service php5-fpm start
cat /webapp/nginx.conf.template | envsubst '$JPY_BASE_USER_URL $URL_ID' > /webapp/nginx.conf
nginx -c /webapp/nginx.conf
