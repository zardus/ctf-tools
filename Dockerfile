FROM ubuntu:noble

run <<END
    export DEBIAN_FRONTEND="noninteractive" 
    apt-get -q update 
    apt-get dist-upgrade -y --no-install-recommends --auto-remove 
    apt-get install -y --no-install-recommends --auto-remove \
        build-essential libtool g++ gcc rubygems \
        texinfo curl wget automake autoconf python3 python3-dev git \
        unzip virtualenvwrapper sudo subversion ca-certificates
    apt-get -q clean 
    rm -rf /var/lib/apt/lists/*
END

RUN sed -i -e "s/Types: deb/Types: deb deb-src/g" /etc/apt/sources.list.d/ubuntu.sources

RUN userdel -f -r ubuntu; useradd -m ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

USER ctf
WORKDIR /home/ctf/tools
ADD --chown=ctf:ctf bin/manage-tools /home/ctf/tools/bin/manage-tools
RUN bin/manage-tools -s setup
ADD --chown=ctf:ctf .git /home/ctf/tools/.git
RUN git checkout .

ARG PREINSTALL=""
RUN <<END
    for TOOL in $PREINSTALL
    do
    	/home/ctf/tools/bin/manage-tools -s -v install $TOOL
    done
END

ENV PATH=/home/ctf/tools/bin:/bin:/sbin
WORKDIR /home/ctf
