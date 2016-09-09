FROM simphonyproject/ubuntu-14.04-remote

LABEL eu.simphony-project.docker.ui_name="File manager"
LABEL eu.simphony-project.docker.description="Upload and download utility"

COPY build-framework /tmp/build-framework
COPY container-files/webapp.sh /
COPY container-files/webapp /webapp

WORKDIR /tmp/build-framework

# Fix pip
RUN apt-get update -qq \
    && apt-get install -y make \
    && make base app

WORKDIR /tmp
RUN rm -rf /tmp/build-framework
RUN chmod 755 /webapp.sh
