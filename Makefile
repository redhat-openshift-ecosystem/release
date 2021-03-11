SHELL=/usr/bin/env bash -o errexit

CONTAINER_ENGINE ?= docker

.PHONY: jobs prow-config ci-operator-config new-repo

# these are useful for devs
jobs:
	$(CONTAINER_ENGINE) pull registry.ci.openshift.org/ci/ci-operator-prowgen:latest
	$(CONTAINER_ENGINE) run --rm -v "$(CURDIR):/go/src/github.com/openshift/release:z" -e GOPATH=/go registry.ci.openshift.org/ci/ci-operator-prowgen:latest --from-release-repo --to-release-repo
	$(CONTAINER_ENGINE) pull registry.ci.openshift.org/ci/sanitize-prow-jobs:latest
	$(CONTAINER_ENGINE) run --rm -v "$(CURDIR)/ci-operator/jobs:/ci-operator/jobs:z" -v "$(CURDIR)/core-services/sanitize-prow-jobs:/core-services/sanitize-prow-jobs:z" registry.ci.openshift.org/ci/sanitize-prow-jobs:latest --prow-jobs-dir /ci-operator/jobs --config-path /core-services/sanitize-prow-jobs/_config.yaml

ci-operator-config:
	$(CONTAINER_ENGINE) pull registry.ci.openshift.org/ci/determinize-ci-operator:latest
	$(CONTAINER_ENGINE) run --rm -v "$(CURDIR)/ci-operator/config:/ci-operator/config:z" registry.ci.openshift.org/ci/determinize-ci-operator:latest --config-dir /ci-operator/config --confirm

prow-config:
	docker pull registry.ci.openshift.org/ci/determinize-prow-config:latest
	docker run -v "${CURDIR}/core-services/prow/02_config:/config:z" registry.ci.openshift.org/ci/determinize-prow-config:latest --prow-config-dir /config

new-repo:
	docker pull registry.ci.openshift.org/ci/repo-init:latest
	docker run -it -v "${CURDIR}:/release:z" registry.ci.openshift.org/ci/repo-init:latest --release-repo /release
	$(MAKE) jobs
	$(MAKE) prow-config
