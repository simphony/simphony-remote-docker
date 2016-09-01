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

Individual docker images must specify which wrapper they need. They do
so with a Metainfo file containing the mandatory entry `wrapper`, e.g.::

    wrapper=vncapp
