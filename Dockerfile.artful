FROM ubuntu:artful

# wrapper script for apt-get
COPY .docker/apt-get-install /usr/local/bin/apt-get-install
RUN chmod +x /usr/local/bin/apt-get-install

RUN apt-get-install build-essential libtool g++ gcc \
    texinfo curl wget automake autoconf python python-dev git subversion \
    unzip virtualenvwrapper sudo  git virtualenvwrapper

RUN useradd -m ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

COPY .git /home/ctf/tools/.git
RUN chown -R ctf.ctf /home/ctf/tools

# git checkout of the files
USER ctf
WORKDIR /home/ctf/tools
RUN git checkout .

# add non-commited scripts
USER root
COPY bin/manage-tools /home/ctf/tools/bin/
COPY bin/ctf-tools-pip /home/ctf/tools/bin/
COPY bin/ctf-tools-venv-activate /home/ctf/tools/bin/
COPY bin/ctf-tools-venv-activate3 /home/ctf/tools/bin/
RUN chown -R ctf.ctf /home/ctf/tools

# finally run ctf-tools setup
USER ctf
RUN bin/manage-tools -s setup
RUN bin/ctf-tools-pip install appdirs
#RUN echo "workon ctftools" >> /home/ctf/.bashrc
RUN echo 'source $(which ctf-tools-venv-activate)' >> /home/ctf/.bashrc

WORKDIR /home/ctf
#CMD bash -i
