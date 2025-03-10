FROM ubuntu:noble

# wrapper script for apt-get
COPY .docker/apt-get-install /usr/local/bin/apt-get-install
RUN chmod +x /usr/local/bin/apt-get-install

RUN sed -i -e "s/Types: deb/Types: deb deb-src/g" /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get-install build-essential libtool g++ gcc rubygems \
    texinfo curl wget automake autoconf python3 python3-dev git \
    unzip virtualenvwrapper sudo git subversion virtualenvwrapper ca-certificates

RUN userdel -f -r ubuntu; useradd -m ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

# a bit weird so that we don't invalidate this cache unless manage-tools changes
USER ctf
WORKDIR /home/ctf/tools
ADD --chown=ctf:ctf bin/manage-tools /home/ctf/tools/bin/manage-tools
RUN bin/manage-tools -s setup && rm bin/manage-tools

# now check out the repo and re-copy the script if modified
ADD --chown=ctf:ctf .git /home/ctf/tools/.git
RUN git checkout .
COPY bin/manage-tools /home/ctf/tools/bin/manage-tools

ARG PREINSTALL=""
RUN <<END
for TOOL in $PREINSTALL
do
	/home/ctf/tools/bin/manage-tools -s -v install $TOOL
done
END

ENV PATH=/home/ctf/tools/bin:/bin:/sbin
WORKDIR /home/ctf
