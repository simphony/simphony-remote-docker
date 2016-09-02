#!/bin/sh
gunicorn --user $USER wsgi:app -b "0.0.0.0:6081"
