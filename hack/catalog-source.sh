#!/bin/sh

if [[ -z ${1} ]]; then
    CATALOG_NS="openshift-marketplace"
else
    CATALOG_NS=${1}
fi

CSV=`cat deploy/olm-catalog/smartgateway-operator/0.1.0/smartgateway-operator.v0.1.0.clusterserviceversion.yaml | sed -e 's/^/          /' | sed '0,/ /{s/          /        - /}'`
CRD=`cat deploy/crds/smartgateway_v1alpha1_smartgateway_crd.yaml  | sed -e 's/^/          /' | sed '0,/ /{s/          /        - /}'`
PKG=`cat deploy/olm-catalog/smartgateway-operator/smartgateway-operator.package.yaml | sed -e 's/^/          /' | sed '0,/ /{s/          /        - /}'`

cat << EOF > deploy/olm-catalog/smartgateway-operator/0.1.0/smartgateway_v1alpha1_smartgateway_crd.yaml
${CRD}
EOF

cat << EOF > deploy/olm-catalog/smartgateway-operator/0.1.0/catalog-source.yaml
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: collectd-resources
      namespace: ${CATALOG_NS}
    data:
      clusterServiceVersions: |
${CSV}
      customResourceDefinitions: |
${CRD}
      packages: >
${PKG}

  - apiVersion: operators.coreos.com/v1alpha1
    kind: CatalogSource
    metadata:
      name: smartgateway-resources
      namespace: ${CATALOG_NS}
    spec:
      configMap: smartgateway-resources
      displayName: SmartGateway Operators
      publisher: Red Hat
      sourceType: internal
    status:
      configMapReference:
        name: smartgateway-resources
        namespace: ${CATALOG_NS}
EOF