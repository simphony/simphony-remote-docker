Docker specification for SimPhoNy Remote App project
====================================================

Source code for composing Dockerfiles that support remote access using Simphony-remote web
application.  Built docker images are hosted on DockerHub under the Simphony Organisation.

Docker image names
------------------

1. `simphonyproject/ubuntu-12.04-remote:{version}`
         Ubuntu 12.04 base image with remote access support

2. `simphonyproject/ubuntu-14.04-remote:{version}`
         Ubuntu 14.04 base image with remote access support

3. `simphonyproject/{other_image_name}:{version}`
         Built on top of one of the above two base images

Docker build context for these images can be found in this repository with branch/tag
`production-{version}`.


Deployment for DockerHub Repo
-----------------------------

To deploy, follow these steps:

1. git checkout the commit for deployment

2. in the top directory, do::

   $ ./scripts/create_production.sh ./base_images ./images ./wrapper $tag

where $tag is used for specifying the version of the base images, available tag
can be found on simphonyproject/ubuntu-12.04-base or simphonyproject/ubuntu-14.04-base
on DockerHub.

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


Building docker images locally
------------------------------

Docker images ready to be used by the web service are built in three stages.

Stage 1:
         Base (ubuntu) docker image with dependencies installed.
         They are in ./base_images

Stage 2:
         The needed application is built on top of these base docker images. Each application
         has its own Dockerfile and they are in ./images

Stage 3:
         Front-end components required for the remote access are built on top of the result of
         Stage 2.  These components are in ./wrapper

Scripts are provided in ./scripts for building the above images with the appropriate labels,
names and tags.

Scripts for Development
-----------------------

- ./scripts/build\_base.sh: Build base docker images from which other application docker images are built

- ./scripts/build\_docker.sh: Build individual docker image from the Dockerfile in a given directory, and
  then from the built image, add noVNC and other components required by the remote access

- ./scripts/build\_all.sh : Build all docker images under the given directory, i.e. call ./build\_docker.sh
  for all subdirectories in the given directory

IMPORTANT: if you deploy new images, do ensure that containers from the old images are deleted,
otherwise the user will continue to use the old container instead of creating a new one from
the new imaegs.
To do so, check ``docker ps -a`` and then do ``docker rm`` of all the obsolete containers.

For example, to build a base image::

  $ ./scripts/build_base.sh ./base_images

To build an image in ./images::

  $ ./scripts/build_docker.sh ./images/simphony-framework-mayavi/ ./wrapper/

To build all images in ./images::

  $ ./scripts/build_all.sh ./images ./wrapper


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


Make your own Docker images
---------------------------

You may build your own images that can be run with the remote access web application.

First, you should compose your docker image based on one of the base images hosted on DockerHub
un the Simphony Organisation.  For example, in your Dockerfile::

  FROM simphonyproject/ubuntu-14.04-remote

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
