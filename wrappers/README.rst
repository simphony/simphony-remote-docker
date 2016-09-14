Wrappers
========

Wrappers are a set of files and applications that are used to support
the final application. At the moment we have two types of wrapper:

    - vncapp: support X11 applications. The wrapper exports them on a
              running X11 desktop exported to the web via noVNC.
    - webapp: support for web-based applications (e.g. browsepy, jupyter). 
              The wrapper runs the script `/webapp.sh`. Individual docker 
              images are supposed to personalise this script to start
              the appropriate web application.

They are combined (copied) with the `base_image` to provide the final Docker
image that is usable for our application needs.

Individual application images must then choose the appropriate base image.
For example, an application relying on VNC to work must use e.g. 
`ubuntu-14.04-vncapp` as base image.
