FROM simphonyproject/ubuntu-14.04-webapp

LABEL eu.simphony-project.docker.ui_name="Jupyter"
LABEL eu.simphony-project.docker.description="Jupyter notebook"

COPY build-framework /tmp/build-framework
WORKDIR /tmp/build-framework

# Fix pip
RUN apt-get update -qq \
    && apt-get install -y make \
    && make base fix-pip jupyter

WORKDIR /tmp
RUN rm -rf /tmp/build-framework
COPY container-files/webapp.sh /
RUN chmod 755 /webapp.sh
