#!/bin/sh
export HOME="/home/$USER"
sudo -u $USER -g $USER jupyter notebook --base-url=$JPY_BASE_USER_URL/containers/$URL_ID/
