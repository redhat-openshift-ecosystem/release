SHELL=/usr/bin/env bash -o errexit

.PHONY: jobs prow-config new-repo

# these are useful for devs
jobs:
	docker pull registry.svc.ci.openshift.org/ci/ci-operator-prowgen:latest
	docker run -v "${CURDIR}/ci-operator:/ci-operator:z" registry.svc.ci.openshift.org/ci/ci-operator-prowgen:latest --from-dir /ci-operator/config --to-dir /ci-operator/jobs
	docker pull registry.svc.ci.openshift.org/ci/determinize-prow-jobs:latest
	docker run -v "${CURDIR}/ci-operator/jobs:/ci-operator/jobs:z" registry.svc.ci.openshift.org/ci/determinize-prow-jobs:latest --prow-jobs-dir /ci-operator/jobs

prow-config:
	docker pull registry.svc.ci.openshift.org/ci/determinize-prow-config:latest
	docker run -v "${CURDIR}/core-services/prow/02_config:/config:z" registry.svc.ci.openshift.org/ci/determinize-prow-config:latest --prow-config-dir /config

new-repo:
	docker pull registry.svc.ci.openshift.org/ci/repo-init:latest
	docker run -it -v "${CURDIR}:/release:z" registry.svc.ci.openshift.org/ci/repo-init:latest --release-repo /release
	$(MAKE) jobs
	$(MAKE) prow-config
