#!/bin/sh
export HOME="/home/$USER"
gunicorn --user $USER --group $USER wsgi:app -b "0.0.0.0:6081"
