Development/Deployment for DockerHub Repo
-----------------------------------------

Build images
''''''''''''

To generate the usable Docker layout, follow these steps:

1. git checkout the commit for deployment, then modify the ``scripts/build.conf`` to the
   appropriate tag. This parameter is used for specifying the version of the base images.
   Available tag can be found on simphonyproject/ubuntu-12.04-vncapp or 
   simphonyproject/ubuntu-14.04-vncapp/webapp on DockerHub. If you are doing development
   you should use ``latest``. If you are releasing a version, you should pick an appropriate
   one, in the form ``vX.X.X``. This tag will be added as the FROM dependency to all App images.

2. in the scripts directory, do::

     $ sh create_production.sh ./build.conf

   This generates the `production` directory containing the built Dockerfile and 
   the associated files.

These two steps are enough to create the buildable Dockerfiles and the associated
files. Skip to `Development` section if that's all you need to perform development,
or continue to do a production release.

Configure Docker Hub
''''''''''''''''''''

To do deployment and autobuild, first you have to configure DockerHub, but only if you added 
new images to your collection. If so, follow these steps for each new image you
want to add. Taking a freshly added ``simphonyproject/filemanager`` image as an
example:

1. Go to ``hub.docker.com`` and log in with your credentials to the ``simphonyproject``.
   You need to be authorized to do so.

2. Click `Create > Create automated build` in the topbar menu.

3. Click the giant ``create auto build Github`` button, 
   select ``simphony`` and ``simphony-remote-docker``

4. specify the conventional name (same as the directory you got out of
   ``production``: ``filemanager``), title, and description. Click the customize button, and specify
   two entries in the resulting list:
   
   - Push type: Branch, Name: production, Dockerfile location: ``/filemanager``, Docker tag: latest.
   - Push type: tag, Name ``/^v[0-9.]+$/``, Dockerfile location: ``/filemanager``, Docker tag: <leave empty>

Now DockerHub is ready to automatically build the filemanager image when you push appropriately.

**IMPORTANT**: Docker hub has a limitation of two hours for the build, on a rather slow machine.
If your image takes too much time to build, you will have to build locally and then push the image.
Be aware that you might incur disk space issues in this case.


Deploying images
''''''''''''''''

To perform deployment you need to move the content of the `production` directory in the ``production`` branch:

1. tag with ``master-vX.X.X`` the commit you used to generate the production,
   possibly using a PR to do so while adding the appropriate docs, and change the tag as described
   above.

2. git checkout the ``production`` branch. This branch is an orphan branch where the finalized
   Dockerfiles are stored::

     $ git checkout production
     $ git rm -rf .

3. cp the content of the directory `production` to the top directory, and get rid of the empty dir::

     $ cp -rf production/* .
     $ rm -rf production

4. git add these content, tag them with the `vX.X.X` and push them to origin::

     $ git add .
     $ git commit -m "version X.X.X"
     $ git tag vX.X.X
     $ git push --tags production origin

This will trigger the build on DockerHub for both latest and the tag you just pushed.


Development
-----------

The scripts directory contains building scripts to build the images in the
``production`` directory. Running the ``create_production.sh`` script is therefore
needed before using these scripts. To guarantee the use of the produced base
images, the tag in the ``build.conf`` must be set to ``latest``.

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
 
  $ ./scripts/build_docker.sh simphonyproject ./production/simphony-framework-mayavi/ 

 where the first option ``simphonyproject`` is a prefix for the image name. The final image name 
 will be ``prefix/dirname``, so in this case ``simphonyproject/simphony-framework-mayavi``
