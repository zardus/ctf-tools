from ubuntu:trusty
maintainer yans@yancomm.net

RUN apt-get update && apt-get install -y build-essential libtool g++ gcc \
    texinfo curl wget automake autoconf python python-dev git subversion \
    unzip virtualenvwrapper sudo

RUN useradd -m ctf
COPY .git /home/ctf/tools/.git
RUN chown -R ctf.ctf /home/ctf/tools

RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf
RUN apt-get update
RUN apt-get -y install git virtualenvwrapper

USER ctf

WORKDIR /home/ctf/tools
RUN git checkout .
RUN bin/manage-tools -s setup
RUN bin/ctf-tools-pip install appdirs
RUN echo "workon ctftools" >> /home/ctf/.bashrc

WORKDIR /home/ctf
CMD bash -i
