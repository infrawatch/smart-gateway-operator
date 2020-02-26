#!/usr/bin/env bash
# contents of this file originally from https://redhat-connect.gitbook.io/certified-operator-guide/ocp-deployment/openshift-deployment

set -e

CSV_VERSION=${CSV_VERSION:-1.0.0-beta1}
UNIXDATE=$(date +%s)
ORGANIZATION=${ORGANIZATION:-infrawatch}

if [ -z "$USERNAME" ]; then
    echo -n "Username: "
    read -r USERNAME
fi

if [ -z "$PASSWORD" ]; then
    echo -n "Password: "
    read -r -s PASSWORD
fi
echo

AUTH_TOKEN=$(curl -sH "Content-Type: application/json" \
-XPOST https://quay.io/cnr/api/v1/users/login \
-d '{"user": {"username": "'"${USERNAME}"'", "password": "'"${PASSWORD}"'"}}' | jq -r '.token')

# The application registry name and the container registry name can not be the same on quay.io. Same as we do with the smart-gateway-operator we remove the first
# instance of the hyphen for the application registry (servicetelemetry-operator). For the container registry we match the git repository name (service-telemetry-operator).
operator-courier push "./deploy/olm-catalog/smart-gateway-operator" "${ORGANIZATION}" "smartgateway-operator" "${CSV_VERSION}-${UNIXDATE}" "${AUTH_TOKEN}"

# vim: set ft=bash:
