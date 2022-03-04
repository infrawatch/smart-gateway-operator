#!/usr/bin/env bash
set -e
REL=$(dirname "$0")

# shellcheck source=build/metadata.sh
. "${REL}/metadata.sh"

generate_version() {
    echo "-- Generating operator version"
    UNIXDATE=$(date '+%s')
    OPERATOR_BUNDLE_VERSION=${OPERATOR_CSV_MAJOR_VERSION}.${UNIXDATE}
    echo "---- Operator Version: ${OPERATOR_BUNDLE_VERSION}"
}

generate_bundle() {
    echo "-- Generate bundle"
    REPLACE_REGEX="s#<<CREATED_DATE>>#${CREATED_DATE}#g;s#<<OPERATOR_IMAGE>>#${OPERATOR_IMAGE}#g;s#<<OPERATOR_TAG>>#${OPERATOR_TAG}#g;s#<<RELATED_IMAGE_BRIDGE_SMARTGATEWAY>>#${RELATED_IMAGE_BRIDGE_SMARTGATEWAY}#g;s#<<RELATED_IMAGE_BRIDGE_SMARTGATEWAY_TAG>>#${RELATED_IMAGE_BRIDGE_SMARTGATEWAY_TAG}#g;s#<<RELATED_IMAGE_CORE_SMARTGATEWAY>>#${RELATED_IMAGE_CORE_SMARTGATEWAY}#g;s#<<RELATED_IMAGE_CORE_SMARTGATEWAY_TAG>>#${RELATED_IMAGE_CORE_SMARTGATEWAY_TAG}#g;s#<<OPERATOR_BUNDLE_VERSION>>#${OPERATOR_BUNDLE_VERSION}#g;s#1.99.0#${OPERATOR_BUNDLE_VERSION}#g;s#<<BUNDLE_OLM_SKIP_RANGE_LOWER_BOUND>>#${BUNDLE_OLM_SKIP_RANGE_LOWER_BOUND}#g"

    pushd "${REL}/../"
    make bundle CHANNELS=${BUNDLE_CHANNELS} DEFAULT_CHANNEL=${BUNDLE_DEFAULT_CHANNEL} VERSION="${OPERATOR_BUNDLE_VERSION}" #--output-dir "${WORKING_DIR}"
    popd

    echo "---- Replacing variables in generated manifest"
    sed -i -E "${REPLACE_REGEX}" "bundle/manifests/${OPERATOR_NAME}.clusterserviceversion.yaml"
    echo "---- Generated bundle complete at bundle/manifests/${OPERATOR_NAME}.clusterserviceversion.yaml"
}

build_bundle_instructions() {
    echo "***"
    echo "Bundle has been created locally. To build and push the bundle to your remote registry run:"
    echo "> make bundle-build bundle-push"
    echo "***"
}

# generate templates
echo "## Begin bundle creation"
generate_version
generate_bundle
build_bundle_instructions
echo "## End Bundle creation"
