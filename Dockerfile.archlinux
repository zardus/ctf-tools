from base/archlinux

RUN cat /etc/pacman.d/mirrorlist \ 
        | sed 's/^#Server/Server/' \
        > /etc/pacman.d/mirrorlist.backup \
        && rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup \
        > /etc/pacman.d/mirrorlist

RUN echo "[multilib]" >> /etc/pacman.conf
RUN echo "Include = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

RUN pacman -Syy \
    && pacman -S --noconfirm archlinux-keyring \
    && pacman -Scc --noconfirm
RUN pacman-key --refresh-keys
RUN pacman -Syu --noconfirm \
    && pacman-db-upgrade \
    && pacman -Scc --noconfirm \
    && pacman -Syu --noconfirm \
    && pacman -Scc --noconfirm
RUN trust extract-compat
RUN pacman -Syu --noconfirm --needed \
        curl wget python2 python3 git subversion \
        python2-pip python-pip \
        unzip python-virtualenvwrapper \
        zsh grml-zsh-config \
        sudo which \
    && pacman -Scc --noconfirm

RUN useradd -m ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf
RUN chsh -s /usr/bin/zsh ctf

COPY .git /home/ctf/tools/.git
RUN chown -R ctf.ctf /home/ctf/tools

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
RUN echo 'source $(which virtualenvwrapper.sh)' >> ~/.zshrc
RUN echo 'workon ctftools' >> ~/.zshrc

WORKDIR /home/ctf
CMD ["zsh", "-i"]
