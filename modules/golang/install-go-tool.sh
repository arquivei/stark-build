#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

toolsdir=${1}
bin=${2}
importpath=${3}
version=${4}

if ! ${bin} -version | grep -q -s -F "${version}"; then
    echo "Installing $(basename "${bin}") version ${version}"
    GOBIN=${toolsdir} go install "${importpath}@${version}"
else
    echo "$(basename "${bin}") already at version ${version}"
fi
