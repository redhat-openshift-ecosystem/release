#!/bin/bash

# pj-rehearse assumes all necessary config is present in the repository, but
# redhat-operator-ecosystem/release only contains job configuration, not Prow
# configuration (Prow config is in openshift/release). Work around this
# limitation by symlinking the openshift/release config. This script assumes:
#
# 1) To be called from r-o-e/release working copy root as CWD
# 2) With openshift/release checked out at ../../openshift/release from CWD

prow_config_dir="core-services/prow/02_config"

if [[ -e "${prow_config_dir}" ]]; then
  echo "ERROR: ${prow_config_dir} already exists in the repo (pj-rehearse should be called directly)"
  exit 1
fi

mkdir -p "$(dirname "${prow_config_dir}")"

trap 'rm -rf $prow_config_dir' EXIT
ln -s "$(pwd)/../../openshift/release/${prow_config_dir}" "${prow_config_dir}"

pj-rehearse "$@"
