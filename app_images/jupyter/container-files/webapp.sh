#!/bin/sh
export HOME="/home/$USER"
sudo -u $USER -g $USER jupyter notebook --no-browser --notebook-dir=$HOME --NotebookApp.base_url=$JPY_BASE_USER_URL/containers/$URL_ID/ --NotebookApp.allow_origin='*' --port 6081
