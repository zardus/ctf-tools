#!/bin/bash

DOCKERIMAGE=ctf-tools-travisbuildcheck
GITDIR=`git rev-parse --show-toplevel`

all: image logs stats

image:
	docker build -t $(DOCKERIMAGE) .

logs: 
	docker run --rm -it \
		-v $(GITDIR):/gitdata:rw,z \
		-v $(GITDIR)/_buildstatus/logs/:/logs/:rw,z \
		$(DOCKERIMAGE) \
		/gitdata/bin/travis-ci-status/fetch_latest_timingdata.inside-docker.sh

stats:
	docker run --rm -it \
		-v $(GITDIR):/gitdata:rw,z \
		-v $(GITDIR)/_buildstatus/logs/:/logs/:rw,z \
		$(DOCKERIMAGE) \
		bash -c \
		"/gitdata/bin/travis-ci-status/make_build_status_md.py /logs/travis.log > /gitdata/_buildstatus/index.md"

travisyml:
	docker run --rm -it \
		-v $(GITDIR):/gitdata:rw,z \
		-v $(GITDIR)/_buildstatus/logs/:/logs/:rw,z \
		$(DOCKERIMAGE) \
		/gitdata/bin/travis-ci-status/gen_travis_yml.sh
