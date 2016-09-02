#!/bin/sh
export HOME="/home/user"
gunicorn --user user --group user wsgi:app -b "0.0.0.0:6081"
