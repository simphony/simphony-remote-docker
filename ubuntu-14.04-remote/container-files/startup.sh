#!/bin/bash

if [[ $USER = "" ]]; then
    echo "Cannot obtain USER variable"
    exit 1
fi

if [[ $JPY_USER = "" ]]; then
    echo "Cannot obtain JPY_USER variable"
    exit 1
fi

if [[ $JPY_BASE_USER_URL = "" ]]; then
    echo "Cannot obtain JPY_BASE_USER_URL variable"
    exit 1
fi

if [[ "${JPY_BASE_USER_URL: -1}" = "/" ]]; then
    echo "JPY_BASE_USER_URL cannot contain a '/' as a last character"
    exit 1
fi

mkdir -p /var/run/sshd

# This is the only effective way I found to obtain the full container id from
# within the container. We can't have it passed from the outside, or we have a
# chicken-egg problem, and --cidfile is unsupported by dockerpy
_tmp=`cat /proc/self/cgroup | grep ":cpu:" | cut -d: -f 3`
export CONTAINER_ID="`basename $_tmp`"

# Create the user
id -u $USER &>/dev/null || useradd --create-home --shell /bin/bash --user-group $USER
echo "$USER:$USER" | chpasswd

# Parse the templates and put their result in the appropriate places
cat /templates/nginx.conf.template | envsubst '$JPY_BASE_USER_URL $CONTAINER_ID' > /etc/nginx/sites-enabled/default
cat /templates/supervisord.conf.template | envsubst '$USER' > /etc/supervisor/conf.d/supervisord.conf

# Start the services
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
