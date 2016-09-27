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
_tmp=`cat /proc/self/cgroup | grep ":cpu" | head -1 | cut -d: -f 3`

# If URL_ID is given as an environment variable, use it,
# Otherwise, use the container id from $_tmp
export URL_ID="`(test $URL_ID && echo $URL_ID) || basename $_tmp`"

# Create the user
id -u $USER &>/dev/null || useradd --home-dir "/home/$USER" --shell /bin/bash --user-group $USER

# We create and copy the skel directory manually. useradd --create-home does not copy the skel if
# the directory is already there, as in the case someone mounted an external volume under the
# home directory.
mkdir -p "/home/$USER"
rsync -r /etc/skel/ "/home/$USER"
echo "$USER:$USER" | chpasswd

# Make sure that the workspace is actually writable by the user.
if [ -e /workspace ]; then
    chmod 777 /workspace
fi

# Parse the templates and put their result in the appropriate places
cat /templates/nginx.conf.template | envsubst '$JPY_BASE_USER_URL $URL_ID' > /etc/nginx/sites-enabled/default
cat /templates/supervisord.conf.template | envsubst '$USER' > /etc/supervisor/conf.d/supervisord.conf

# Start the services
nginx -c /etc/nginx/nginx.conf
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
