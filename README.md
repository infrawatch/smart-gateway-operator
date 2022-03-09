# smart-gateway-operator

Operator for the infra.watch [smart gateway](https://github.com/infrawatch/smart-gateway)

## Deployment to an existing cluster

## Released Smart Gateway Operator

Use the OperatorHub in OpenShift to deploy from the Community catalog for a released version of Smart Gateway Operator.

## Development Instance of Smart Gateway Operator in STF

The easiest way to get everything deployed is with the Service Telemetry Framework (STF). You can deploy a development version
with the [stf-run-ci role](https://github.com/infrawatch/service-telemetry-operator/tree/master/build/stf-run-ci)


This snippet will deploy the `master` (future `main`) branch across all repositories related to STF.

```
git clone https://github.com/infrawatch/service-telemetry-operator
oc new-project service-telemetry
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
ansible-playbook build/run-ci.yaml -e __service_telemetry_events_enabled=false -e __service_telemetry_storage_ephemeral_enabled=true
```

Alternatively you can deploy the latest published artifacts. Currently this is not the recommended method.

```
ansible-playbook build/run-ci.yaml -e __local_build_enabled=false
```

# Generate a bundle

Use the `generate_bundle.sh` script.

```
./build/generate_bundle.sh
## Begin bundle creation
-- Generating operator version
---- Operator Version: 1.3.1620788433
-- Create working directory
---- Created working directory: /tmp/smart-gateway-operator-bundle-1.3.1620788433
-- Generate Dockerfile for bundle
---- Generated Dockerfile complete
-- Generate bundle
~/src/github.com/infrawatch/smart-gateway-operator ~/src/github.com/infrawatch/smart-gateway-operator
INFO[0000] Generating bundle manifests version 1.3.1620788433
INFO[0000] Bundle manifests generated successfully in /tmp/smart-gateway-operator-bundle-1.3.1620788433
INFO[0000] Building annotations.yaml
INFO[0000] Generating output manifests directory
INFO[0000] Writing annotations.yaml in /tmp/smart-gateway-operator-bundle-1.3.1620788433/metadata
INFO[0000] Building Dockerfile
INFO[0000] Writing bundle.Dockerfile in /home/lmadsen/src/github.com/infrawatch/smart-gateway-operator
~/src/github.com/infrawatch/smart-gateway-operator
---- Replacing variables in generated manifest
---- Generated bundle complete at /tmp/smart-gateway-operator-bundle-1.3.1620788433/manifests/smart-gateway-operator.clusterserviceversion.yaml
-- Commands to create a bundle build
docker build -t quay.io/infrawatch-operators/smart-gateway-operator-bundle:1.3.1620788433 -f /tmp/smart-gateway-operator-bundle-1.3.1620788433/Dockerfile /tmp/smart-gateway-operator-bundle-1.3.1620788433
docker push quay.io/infrawatch-operators/smart-gateway-operator-bundle:1.3.1620788433
```

# Build and test against CodeReady Containers

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

## Set up CRC and buildah

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

## Login to CRC registry

```
REGISTRY=$(oc registry info)
TOKEN=$(oc whoami -t)
INTERNAL_REGISTRY=$(oc registry info --internal=true)
buildah login --tls-verify=false -u openshift -p "${TOKEN}" "${REGISTRY}"
```

## Create working project (namespace)

Create a namespace for the application called `service-telemetry`.

```
oc new-project service-telemetry
```

## Build the operator

```
buildah bud -f build/Dockerfile -t "${REGISTRY}/service-telemetry/smart-gateway-operator:latest" .
buildah push --tls-verify=false "${REGISTRY}/service-telemetry/smart-gateway-operator:latest"
```

## Deploy with the newly built operator

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

# Simple Smart Gateway Deployment

To create a Smart Gateway, you'll need to connect it to a compatible AMQP 1.x
message bus. For demonstration purposes we're going to use the Red Hat AMQ
Interconnect Operator, create an AMQ Interconnect instance, then create a Smart
Gateway instance that connects to it.

## Create Message Bus Deployment

Subscribe to the AMQ Interconnect Operator and AMQ Certificate Manager. After subscribing create a new `Interconnect` object.

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


### Create Interconnect Object

Create a simple `Interconnect` object to deploy AMQ Interconnect router.

```
apiVersion: interconnectedcloud.github.io/v1alpha1
kind: Interconnect
metadata:
  name: amq-interconnect
  namespace: smart-gateway
spec:
  addresses:
  - distribution: multicast
    prefix: collectd
  - distribution: multicast
    prefix: ceilometer
  deploymentPlan:
    livenessPort: 8888
    placement: AntiAffinity
    resources: {}
    role: interior
    size: 1
  edgeListeners:
  - expose: true
    port: 5671
    saslMechanisms: ANONYMOUS
    sslProfile: openstack
  interRouterListeners:
  - port: 55672
  listeners:
  - port: 5672
  sslProfiles:
  - generateCaCert: true
    generateCredentials: true
    name: openstack
  users: amq-interconnect-users
```

Validate that you see an AMQ Interconnect router come up with `oc get pods`.


## Creating a Smart Gateway

Create a Smart Gateway deployment.

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

