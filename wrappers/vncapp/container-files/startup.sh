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

if [[ $X11_WIDTH = "" ]]; then
    export X11_WIDTH="1024"
fi

if [[ $X11_HEIGHT = "" ]]; then
    export X11_HEIGHT="768"
fi

if [[ $X11_DEPTH = "" ]]; then
    export X11_DEPTH="16"
fi

export X11_RESOLUTION="${X11_WIDTH}x${X11_HEIGHT}"
export X11_MODE="${X11_RESOLUTION}x${X11_DEPTH}"

mkdir -p /var/run/sshd

# This is the only effective way I found to obtain the full container id from
# within the container. We can't have it passed from the outside, or we have a
# chicken-egg problem, and --cidfile is unsupported by dockerpy
_tmp=`cat /proc/self/cgroup | grep ":cpu" | head -1 | cut -d: -f 3`

# If URL_ID is given as an environment variable, use it,
# Otherwise, use the container id from $_tmp
export URL_ID="`(test $URL_ID && echo $URL_ID) || basename $_tmp`"

# Create the user
id -u $USER &>/dev/null || useradd --create-home --shell /bin/bash --user-group $USER
echo "$USER:$USER" | chpasswd

# Make sure that the workspace is actually writable by the user.
if [ -e /workspace ]; then
    chmod 777 /workspace
fi

# Parse the templates and put their result in the appropriate places
cat /templates/nginx.conf.template | envsubst '$JPY_BASE_USER_URL $URL_ID' > /etc/nginx/sites-enabled/default
cat /templates/supervisord.conf.template | envsubst '$USER $X11_MODE' > /etc/supervisor/conf.d/supervisord.conf

# Start the services
nginx -c /etc/nginx/nginx.conf
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
