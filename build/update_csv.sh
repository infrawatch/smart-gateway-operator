#!/usr/bin/env sh
set -e
REL=$(dirname "$0"); source "${REL}/metadata.sh"
operator-sdk generate csv --csv-version=${CSV_VERSION} --operator-name smart-gateway-operator --update-crds
