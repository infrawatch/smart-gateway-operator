# smart-gateway-operator

Operator for the infra.watch [smart gateway](https://github.com/redhat-service-assurance/smart-gateway)

NOTE: Development environment for OCP 4.2 controlled from Service Assurance Operator (SAO)

## Required CSV fields

More information about ClusterServiceVersion fields required for Operator Lifecycle Manager that
are not identified in the CSV Custom Resource Definition can be found here:

> https://github.com/operator-framework/community-operators/blob/master/docs/required-fields.md

## Deployment to an existing cluster

Use the OperatorHub deployment from the Community catalog.

For development or latest version, create an OperatorSource for quay.io/redhat-service-assurance/smartgateway-operator.

## Build and test against CodeReady Containers

NOTE: You'll need a Red Hat subscription to access CodeReady Containers. Access of the pull secret
is available at https://cloud.redhat.com/openshift/install/crc/installer-provisioned. Upstream CodeReady
development is available at https://github.com/code-ready/crc.

A procedure for testing in CodeReady Containers will be available soon.

* buildah
  * 1.12.0
* kubernetes
  * v1.14.0
* crc
  * crc version: 1.3.0+918756b
* oc
  * openshift-clients-4.2.0-201910041700
* operator-sdk
  * v0.12.0 (!0.13.0 which causes regressions via `gen-csv` command)

### Set up crc and buildah

<todo>

### Build the operator

<todo>

### Deploy with the newly built operator

<todo>

### FIXME - Unit testing

With molecule (Currently broken)

### Integration testing

Test the newly built operator with the Service Assurance Framework (SAF).

<todo>

## Creating a Smart Gateway

<update>

Start a new smart gateway by creating a CustomResource object
based on the example:

```shell
oc create -f deploy/crds/smartgateway.infra.watch_v2alpha1_smartgateway.metrics_cr.yaml
```
