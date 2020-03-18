# smart-gateway-operator

Operator for the infra.watch [smart gateway](https://github.com/infrawatch/smart-gateway)

NOTE: Development environment for OCP 4.2 controlled from Service Telemetry Operator (STO)

## Required CSV fields

More information about ClusterServiceVersion fields required for Operator Lifecycle Manager that
are not identified in the CSV Custom Resource Definition can be found here:

> https://github.com/operator-framework/community-operators/blob/master/docs/required-fields.md

## Deployment to an existing cluster

Use the OperatorHub deployment from the Community catalog.

For development or latest version, create an OperatorSource for quay.io/infrawatch/smartgateway-operator.

```
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1
kind: OperatorSource
metadata:
  labels:
    opsrc-provider: infrawatch
  name: infrawatch-operators
  namespace: openshift-marketplace
spec:
  authorizationToken: {}
  displayName: InfraWatch Operators
  endpoint: https://quay.io/cnr
  publisher: InfraWatch
  registryNamespace: infrawatch
  type: appregistry
EOF
```

## Build and test against CodeReady Containers

NOTE: You'll need a Red Hat subscription to access CodeReady Containers. Access of the pull secret
is available at https://cloud.redhat.com/openshift/install/crc/installer-provisioned. Upstream CodeReady
development is available at https://github.com/code-ready/crc.

A procedure for testing in CodeReady Containers will be available soon.

* buildah
  * 1.14.0
* kubernetes
  * v1.16.2
* crc
  * crc version: 1.6.0+8ef676f
* oc
  * openshift-clients-4.2.0-201910041700
* operator-sdk
  * v0.15.2 (!0.13.0 which causes regressions via `gen-csv` command)

### Set up CRC and buildah

Setup CRC and then login with the `kubeadmin` user.

```
$ crc setup
$ crc start --memory=32768
$ crc console --credentials
```

Install `buildah` via `dnf`.

```
sudo dnf install buildah -y
```

### Login to CRC registry

```
REGISTRY=$(oc registry info)
TOKEN=$(oc whoami -t)
INTERNAL_REGISTRY=$(oc registry info --internal=true)
buildah login --tls-verify=false -u openshift -p "${TOKEN}" "${REGISTRY}"
```

### Create working project (namespace)

Create a namespace for the application called `service-telemetry`.

```
oc new-project service-telemetry
```

### Build the operator

```
buildah bud -f build/Dockerfile -t "${REGISTRY}/service-telemetry/smart-gateway-operator:latest" .
buildah push --tls-verify=false "${REGISTRY}/service-telemetry/smart-gateway-operator:latest"
```

### Deploy with the newly built operator

Install required RBAC rules and service account.

```
oc apply \
    -f deploy/role_binding.yaml \
    -f deploy/role.yaml \
    -f deploy/service_account.yaml \
    -f deploy/operator_group.yaml
```

Pick a version from `deploy/olm-catalog/smart-gateway-operator/` and run the
following commands. Adjust version to what you want to test. We'll be using
`v1.0.0` as our example version.

```
CSV_VERSION=1.0.0
INTERNAL_REGISTRY=$(oc registry info --internal=true)
oc apply -f deploy/olm-catalog/smart-gateway-operator/${CSV_VERSION}/smartgateway.infra.watch_smartgateways_crd.yaml

oc create -f <(sed "\
    s|image: .\+/smart-gateway-operator:.\+$|image: ${INTERNAL_REGISTRY}/service-telemetry/smart-gateway-operator:latest|g;
    s|namespace: placeholder|namespace: service-telemetry|g"\
    "deploy/olm-catalog/smart-gateway-operator/${CSV_VERSION}/smart-gateway-operator.v${CSV_VERSION}.clusterserviceversion.yaml")
```

Validate that installation of the `ClusterServiceVersion` is progressing via
the `oc` CLI console.
```
oc get csv --watch
```
If you see `PHASE: Succeeded` then your CSV has been properly imported and
your Operator should be running locally. You can validate this by running `oc
get pods` and looking for the `smart-gateway-operator` and that it is
`Running`.

You can bring up the logs of the Smart Gateway Operator by running `oc logs
<<pod_name>> -c operator`.

## Creating a Smart Gateway

To create a Smart Gateway, you'll need to connect it to a compatible AMQP 1.x
message bus. For demonstration purposes we're going to use the Red Hat AMQ
Interconnect Operator, create an AMQ Interconnect instance, then create a Smart
Gateway instance that connects to it.

### Create AMQ Interconnect Subscription

```
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: amq7-interconnect-operator
  namespace: service-telemetry
spec:
  channel: 1.2.0
  installPlanApproval: Automatic
  name: amq7-interconnect-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

You can check the status of the AMQ Interconnect ClusterServiceVersion
installation with `oc get csv`. When complete you should see `PHASE:
Succeeded`.

### Create AMQ Interconnect Instance

```
oc apply -f - <<EOF
apiVersion: interconnectedcloud.github.io/v1alpha1
kind: Interconnect
metadata:
  name: amq-interconnect
  namespace: service-telemetry
spec:
  addresses:
  - distribution: closest
    prefix: closest
  - distribution: multicast
    prefix: multicast
  - distribution: closest
    prefix: unicast
  - distribution: closest
    prefix: exclusive
  - distribution: multicast
    prefix: broadcast
  deploymentPlan:
    livenessPort: 8888
    placement: Any
    resources: {}
    role: interior
    size: 2
  edgeListeners:
  - port: 45672
  interRouterListeners:
  - port: 55672
  listeners:
  - port: 5672
  - authenticatePeer: true
    expose: true
    http: true
    port: 8080
  users: amq-interconnect-users
EOF
```

Validate that you see both AMQ Interconnect routers come up with `oc get pods`.

### Create Smart Gateway Instance

```
oc apply -f - <<EOF
apiVersion: smartgateway.infra.watch/v2alpha1
kind: SmartGateway
metadata:
  name: cloud1-metrics
  namespace: service-telemetry
spec:
  amqpUrl: amq-interconnect:5672/collectd/telemetry
  debug: true
  prefetch: 15000
  serviceType: metrics
  size: 1
EOF
```

