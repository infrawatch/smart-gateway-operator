# smart-gateway-operator

Operator for the infra.watch [smart gateway](https://github.com/redhat-service-assurance/smart-gateway)

NOTE: Development environment for OCP 4.2 controlled from Service Assurance Operato (SAO)

## Deployment to an existing cluster

Use the OperatorHub deployment from the Community catalog.

For development or latest version, create an OperatorSource for quay.io/redhat-service-assurance/smartgateway-operator.

## Build and test against CodeReady Containers

NOTE: You'll need a Red Hat subscription to access CodeReady Containers. Access of the pull secret
is available at https://cloud.redhat.com/openshift/install/crc/installer-provisioned. Upstream CodeReady
development is available at https://github.com/code-ready/crc.

A procedure for testing in CodeReady Containers will be available soon.

* buildah
  * <todo>
* kubernetes
  * v1.14.0
* crc
  * <todo>
* oc
  * <todo>
* operator-sdk
  * v0.12.0

### Set up crc and buildah

<todo>

### Build the operator

<todo>

### Deploy with the newly built operator

<todo>

### FIXME - Unit testing

With molecule (Currently broken)

### Integration testing

Test the newly built operator with the Service Assurance Operator.

<todo>

## Creating a Smart Gateway

<update>

Start a new smart gateway by creating a CustomResource object
based on the example:

```shell
oc create -f deploy/crds/smartgateway_v2alpha1_smartgateway_cr.yaml
```

Here is an example CustomResource for the `cloud1`` smart gateway.

```yaml
apiVersion: infra.watch/v2alpha1
kind: SmartGateway
metadata:
  name: cloud1
spec:
  size: 1
```
