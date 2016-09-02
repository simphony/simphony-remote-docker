FROM simphonyproject/ubuntu-12.04-remote:latest
LABEL eu.simphony-project.docker.ui_name="Simphony Framework (w/ Paraview)"
LABEL eu.simphony-project.docker.description="Ubuntu machine with simphony framework preinstalled (with paraview)"


COPY simphony-framework /tmp/simphony-framework
WORKDIR /tmp/simphony-framework

# From this point on we should install python packages in site-package
# not dist-pakcage (ubuntu's default)
ENV PREFIX /usr/local
ENV PYTHONPATH /usr/local/lib/python2.7/site-packages

RUN apt-get update -qq \
    && apt-get install -y make \
    && make base \
    apt-openfoam-deps \
    apt-simphony-deps \
    apt-paraview-deps \
    apt-lammps-deps \
    fix-pip \
    fix-python-path \
    lammps \
    jyu-lb \
    simphony \
    simphony-paraview \
    simphony-openfoam \
    simphony-jyu-lb \
    simphony-lammps \
    && rm -rf /var/lib/apt/lists/*

# Examples files for simphony paraview
# and put it on the Desktop
RUN apt-get update -qq \
    && apt-get install -y unzip \
    && wget https://github.com/simphony/simphony-paraview/releases/download/0.2.0/examples.zip -O /tmp/simphony-framework/examples.zip \
    && unzip /tmp/simphony-framework/examples.zip \
    && mkdir -p /etc/skel/Desktop \
    && mv examples /etc/skel/Desktop/

WORKDIR /tmp
RUN rm -rf /tmp/simphony-framework

# install ipython and qtconsole
RUN apt-get install -y ipython ipython-qtconsole \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Autostart IPython Qtconsole
# Create directory for openbox user's config
RUN mkdir -p /etc/skel/.config/openbox
RUN /bin/bash -c 'echo "ipython qtconsole" > /etc/skel/.config/openbox/autostart'
RUN chmod 755 /etc/skel/.config/openbox/autostart
