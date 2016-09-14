Docker specification for SimPhoNy Remote App project
====================================================

Source code for composing Dockerfiles that support remote access using Simphony-remote web
application.  Built docker images are hosted on DockerHub under the Simphony Organisation.


Overall concept and layout
--------------------------

We build images by combining three parts:

1. A base docker file (a plain ubuntu with some personalized additions), found under `base_images`
2. Boilerplate that just sets up the basics of the infrastructure (e.g. vnc), found under `wrappers`
3. For application images, the specifics for our application (under `app_images`)

The composition is done by copying and deploying the last two in a temporary directory
and then use docker building facilities to generate the final image. Note that Dockerfile
files are properly generated and merged together.

Automation of the above points is provided in the `scripts` directory.
These scripts are driven by a configuration file `build.conf`. Details of its usage are
provided in the inline comments.


Docker image names
------------------

1. `simphonyproject/ubuntu-<ubuntu-version>-<wrapper>:{version}`
         Ubuntu of a given version, together with the given wrapper.

3. `simphonyproject/{other_image_name}:{version}`
         Built on top of one of the above base images

Docker build context for these images can be found in this repository with branch/tag
`production-{version}`.


Deployment for DockerHub Repo
-----------------------------

To deploy, follow these steps:

1. git checkout the commit for deployment, then modify the `scripts/build.conf` to the
   appropriate tag. This parameter is used for specifying the version of the base images.
   Available tag can be found on simphonyproject/ubuntu-12.04-vncapp or 
   simphonyproject/ubuntu-14.04-vncapp/webapp on DockerHub.

2. in the top directory, do::

     $ ./scripts/create_production.sh ./build.conf

   This generates the `production` directory.

3. git checkout an orphan branch `production-vX.X.X`::

     $ git checkout --orphan production-v0.1.0
     $ git rm -rf .

4. cp the content of the directory `production` to the top directory::

     $ cp -rf production/* .

5. git add these content (excluding `production`)::

     $ rm -rf production
     $ git add .

6. git push to branch `production-vX.X.X`

7. Create a tag for the branch with the same name.


Scripts for Development
-----------------------

The scripts directory contains building scripts to build the images in the
`production` directory. Running the `create_production.sh` script is therefore
needed before using these scripts. To guarantee the use of the produced base
images, the tag in the `build.conf` must be set to `latest`.

- ./scripts/build\_base.sh: Build base docker images from which other application docker images are built upon

- ./scripts/build\_app.sh: Build application docker images 
 
- ./scripts/build\_docker.sh: Support script to build a requested image. You can use this script to build a specific
  application image.

- ./scripts/build\_all.sh: Build first the base images, then the application images.

IMPORTANT: if you deploy new images, do ensure that containers from the old images are deleted,
otherwise the user will continue to use the old container instead of creating a new one from
the new images.  To do so, check ``docker ps -a`` and then do ``docker rm`` of all the obsolete containers.

For example, to build a base image from the base docker and the wrapper script, do::
 
  $ ./scripts/build_base.sh ./build.conf
 
 To build all images::
 
  $ ./scripts/build_all.sh ./build.conf

 To build an application image::
 
  $ ./scripts/build_docker.sh ./production/simphony-framework-mayavi/ 
 

Test remote access of an image locally
--------------------------------------

If you are on Linux, you may use a script provided `./scripts/test_noVNC_directly.sh`
directly in your terminal::

  $ ./scripts/test_noVNC_directly.sh image_name ./scripts/test_env_file test

On Mac OS X, you should run the above script in your docker VM.
You should clean up the started container once you finish testing.


Running built images on the command-line
----------------------------------------

The docker images built have a default entrypoint for the use of the remote access web application.
Therefore you will get an error message if you try to run it interactively on the command-line::

  $ docker run -it image_name bash
  Cannot obtain USER variable

Instead you should override the entrypoint::

  $ docker run -it --entrypoint=/bin/bash image_name

Running the docker image from the command-line is often useful for debugging.

Make your own Docker images: vncapp
-----------------------------------

You may build your own images that can be run with the remote access web application.

First, you should compose your docker image based on one of the base images hosted on DockerHub
un the Simphony Organisation.  For example, in your Dockerfile::

  FROM simphonyproject/ubuntu-14.04-vncapp

Secondly, you should provide an autostart file that contains the commands to be executed on startup.
Otherwise the desktop would be blank.  The autostart file should be executable by the user
and should be placed in `/etc/skel/.config/openbox/autostart`.

For example, the Simphony Mayavi image autostarts with the Mayavi2 application by having the
following in its Dockerfile::

  RUN mkdir -p /etc/skel/.config/openbox
  RUN /bin/bash -c 'echo "mayavi2 -style cleanlooks" > /etc/skel/.config/openbox/autostart'
  RUN chmod 755 /etc/skel/.config/openbox/autostart

Note: Further customisation related to the remote access web application should be referred to
github.com/simphony/simphony-remote (pending). At the time of writing, you may attach a
pretty name to the image by specifying the 'eu.simphony-project.docker.ui_name' label.  You may
also provide a custom icon by first base encoding the image and then assigning the value to the
'eu.simphony-project.docker.icon_128' label.

Make your own Docker images: webapp
-----------------------------------

To build a container hosting a web application, the process is similar to the vncapp,
but we will use a different base image, and we need to provide an appropriate startup script.
The wrapper to use is webapp, and is selected as before::

  FROM simphonyproject/ubuntu-14.04-webapp

The wrapper is configured to start up, via supervisord, the script `webapp.sh` in the `/`
directory. This script is executed as root, and must start the web application.
There are a few caveats to the web application requirements for export:

- It must listen on port 6081. nginx will reverse proxy it to port 8888
- Note that nginx will _not_ perform any URL rewriting, so the application
  must be able to deal with the full URL. In general this is provided as an option
  `base url`. A common gotcha for this is to have an application that does not
  add the base url to its links, returning a front page that works, but can't be
  navigated because all links are based on `/`. Your application must support
  appropriate links with the specified base url.
- Note also that the container nginx is reverse proxying the request to your
  application, so your application will see requests coming from nginx. This
  might have consequences depending on how your application is designed.

The `webapp.sh`, and thus your application, will be started as root with HOME set as `/root`
If you want to run as user (recommended) you have to export HOME to the appropriate
path, and change to the specified user (e.g. using sudo or the appropriate
options of your application) inside the `webapp.sh` script.
