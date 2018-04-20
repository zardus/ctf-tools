FROM fedora

RUN dnf -y install which sudo git redhat-lsb

RUN useradd -m ctf
COPY .git /home/ctf/tools/.git
RUN chown -R ctf.ctf /home/ctf/tools

RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf
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

USER ctf
RUN bin/manage-tools -s setup
RUN bin/ctf-tools-pip install appdirs
RUN echo 'source $(which ctf-tools-venv-activate)' >> /home/ctf/.bashrc

WORKDIR /home/ctf
CMD bash -i
