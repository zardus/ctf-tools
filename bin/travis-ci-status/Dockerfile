FROM ubuntu:xenial

RUN apt-get update
RUN apt-get -y install python-software-properties software-properties-common build-essential git python-pip ipython vim
RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get -y install ruby2.1 ruby2.1-dev ruby-switch 
RUN ruby-switch --set ruby2.1

RUN gem install travis -v 1.8.8 --no-rdoc --no-ri
RUN pip install binpacking

WORKDIR /gitdata
