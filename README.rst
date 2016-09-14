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

The composition is done by copying and deploying the first two together in a base image+wrapper
and then use docker building facilities to generate the image. Note that Dockerfile
files are properly generated and merged together.

Automation of the above points is provided in the `scripts` directory.
These scripts are driven by a configuration file `build.conf`. Details of its usage are
provided in the inline comments.

The simphony-remote-docker repository has two branches: 
- `master` contains the above files, and all the generating infrastructure.
- `production` contains the built and ready docker layout generated from the 
  above scripts.  Autobuilds of docker images on Docker Hub is 
  done from this branch.

Docker image names
------------------

1. `simphonyproject/ubuntu-<ubuntu-version>-<wrapper>:{version}`
         Ubuntu of a given version, together with the given wrapper.
         Example `simphonyproject/ubuntu-14.04-webapp:v0.3.0`

3. `simphonyproject/{other_image_name}:{version}`
         Built on top of one of the above base images.
         Example `simphonyproject/filetransfer`

Docker build context for these images can be found in this repository in branch production, tag 
`v{version}`.

**IMPORTANT**: Due to DockerHub limitations in tag management when building, 
these tags `vX.X.X` are reserved to the production branch. They will be used to
tag the docker images.  For the master commit that generated the production,
use `master-vX.X.X` instead.

Development/Deployment for DockerHub Repo
-----------------------------------------

Build images
''''''''''''

To generate the usable Docker layout, follow these steps:

1. git checkout the commit for deployment, then modify the `scripts/build.conf` to the
   appropriate tag. This parameter is used for specifying the version of the base images.
   Available tag can be found on simphonyproject/ubuntu-12.04-vncapp or 
   simphonyproject/ubuntu-14.04-vncapp/webapp on DockerHub. If you are doing development
   you should use `latest`. If you are releasing a version, you should pick an appropriate
   one, in the form `vX.X.X`. This tag will be added as the FROM dependency to all App images.

2. in the top directory, do::

     $ ./scripts/create_production.sh ./build.conf

   This generates the `production` directory containing the built Dockerfile and 
   the associated files.

These two steps are enough to create the buildable Dockerfiles and the associated
files. Skip to `Development` section if that's the case.

Configure Docker Hub
''''''''''''''''''''

To do deployment and autobuild, first you have to configure DockerHub, but only if you added 
new images to your collection. If so, follow these steps for each new image you
want to add. Taking a freshly added `simphonyproject/filemanager` image as an
example:

1. Go to `hub.docker.com` and log in with your credentials to the `simphonyproject`.
   You need to be authorized to do so.

2. Click `Create > Create automated build` in the topbar menu.

3. Click the giant `create auto build Github` button, 
   select `simphony` and `simphony-remote-docker`

4. specify the conventional name (same as the directory you got out of
   `production`: `filemanager`), title, and description. Click the customize button, and specify
   two entries in the resulting list:
   
   - Push type: Branch, Name: production, Dockerfile location: `/filemanager`, Docker tag: latest.
   - Push type: tag, Name `/^v[0-9.]+$/`, Dockerfile location: `/filemanager`, Docker tag: <leave empty>

Now DockerHub is ready to automatically build the filemanager image when you push appropriately.

Deploying images
''''''''''''''''

To perform deployment you need to move the content of the `production` directory in the `production` branch:

1. tag with `master-vX.X.X` the commit you used to generate the production,
   possibly using a PR to do so while adding the appropriate docs, and change the tag as described
   above.

2. git checkout the `production` branch. This branch is an orphan branch where the finalized
   Dockerfiles are stored::

     $ git checkout production
     $ git rm -rf .

3. cp the content of the directory `production` to the top directory, and get rid of the empty dir::

     $ cp -rf production/* .
     $ rm -rf production

4. git add these content, tag them with the `vX.X.X` and push them to origin::

     $ git add .
     $ git tag vX.X.X
     $ git push --tags production origin

This will trigger the build on DockerHub for both latest and the tag you just pushed.


Development
-----------

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

