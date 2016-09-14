#!/bin/sh
# Placeholder for the entry point to start the web application.
# The web application must listen on port 6081. nginx will take care,
# in its current form, to expose it at the appropriate user-facing url
# Note that nginx will _not_ perform any URL rewriting, so the application
# at port 6081 must be able to deal with the full URL.
# Also note that this script will be started as the root user,
# with HOME set as /root. The code in this script must take care of 
# changing to the appropriate user if needed.
