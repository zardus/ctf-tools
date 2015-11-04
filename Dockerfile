from ubuntu:trusty
maintainer yans@yancomm.net

RUN adduser ctf
COPY .git /home/ctf/tools/.git
RUN chown -R ctf.ctf /home/ctf/tools

RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf
RUN apt-get update
RUN apt-get -y install git virtualenvwrapper

USER ctf

WORKDIR /home/ctf/tools
RUN git checkout .
RUN bin/manage-tools -s setup

WORKDIR /home/ctf
RUN bash -c "source /etc/bash_completion.d/virtualenvwrapper && mkvirtualenv ctf"
RUN echo "workon ctf" >> /home/ctf/.bashrc

ENTRYPOINT bash -i
