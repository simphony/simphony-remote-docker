FROM simphonyproject/ubuntu-14.04-vncapp

LABEL eu.simphony-project.docker.ui_name="Simphony Framework (w/ Mayavi)"
LABEL eu.simphony-project.docker.description="Ubuntu machine with simphony framework preinstalled"


# Simphony Framework with mayavi
COPY simphony-framework /tmp/simphony-framework
WORKDIR /tmp/simphony-framework

# Fix pip
RUN apt-get update -qq \
    && apt-get install -y make \
    && make base fix-pip

# Virtual environments for PYTHONPATH etc.
ENV SIMPHONYENV /simphony

# Create virtual environment with system site-packages
RUN virtualenv --system-site-packages $SIMPHONYENV

# Make sure that the virtual environment would be activated on startup
RUN /bin/bash -c 'echo ". $SIMPHONYENV/bin/activate" >> /etc/skel/.bashrc'

# These are installed before loading the virtualenv
RUN make apt-simphony-deps \
    apt-openfoam-deps \
    apt-mayavi-deps \
    apt-lammps-deps \
    lammps \
    jyu-lb

# Install packages within the virtual environment.
# Downgrade also the setuptools in the venv to 27.2.0 to workaround mayavi issue #443
RUN /bin/bash -c 'source /simphony/bin/activate; \
     pip install setuptools==27.2.0; \
     make simphony \
     simphony-mayavi \
     simphony-openfoam \
     simphony-jyu-lb \
     simphony-lammps' \
     && rm -rf /var/lib/apt/lists/*

# The Openfoam Ubuntu prebuilt package installs the library in
# /root/OpenFOAM/-2.3.1/platforms/linux64GccDPOpt/lib
# which is not accessible by the user, they need to be copied over
RUN cp -rf /root/OpenFOAM/-2.3.1/platforms/linux64GccDPOpt/lib/* $SIMPHONYENV/lib

# Examples files for simphony mayavi
# and put it on the Desktop
RUN apt-get update -qq \
    && apt-get install -y unzip \
    && wget https://github.com/simphony/simphony-mayavi/releases/download/0.4.0/examples.zip -O /tmp/simphony-framework/examples.zip \
    && unzip /tmp/simphony-framework/examples.zip \
    && mkdir -p /etc/skel/Desktop \
    && mv examples /etc/skel/Desktop/

WORKDIR /tmp
RUN rm -rf /tmp/simphony-framework

# Setup preference for loading simphony-mayavi plugin in Mayavi2
RUN mkdir -p /etc/skel/.enthought/mayavi_e3
COPY container-files/preferences.ini /etc/skel/.enthought/mayavi_e3/

# Autostart Mayavi2
# Create directory for openbox user's config
RUN mkdir -p /etc/skel/.config/openbox
RUN /bin/bash -c 'echo "(eval `cat $SIMPHONYENV/bin/activate` && mayavi2 -style cleanlooks) &" > /etc/skel/.config/openbox/autostart'
RUN chmod 755 /etc/skel/.config/openbox/autostart
