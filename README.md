# smart-gateway-operator

Operator for the smart gateway available
https://github.com/redhat-service-assurance/smart-gateway

# Building

You can build this with the `operator-sdk` by running:

    operator-sdk build quay.io/redhat-service-assurance/smart-gateway-operator:latest

# Deployment

You'll need to deploy the components under the `deploy/` directory.

    oc apply -f deploy/smartgateway_v1alpha1_smartgateway_crd.yaml
    oc apply -f deploy/operator.yaml
    oc apply -f deploy/role_binding.yaml
    oc apply -f deploy/role.yaml
    oc apply -f deploy/service_account.yaml

# Creating a Smart Gateway

Start a new smart gateway by creating a CustomResource object. You can do this
with the `smartgateway_v1alpha1_smartgateway_cr.yaml` file in `deploy/crds/`.

Here is an example CustomResource for the `white` smart gateway.

    apiVersion: smartgateway.infra.watch/v1alpha1
    kind: SmartGateway
    metadata:
      name: white
    spec:
      size: 1
