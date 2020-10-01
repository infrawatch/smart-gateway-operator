# Updating CSV for next bundle release

The following set of commands will allow updating the current CSV to a new
version.

## Prerequisites

You will need operator-sdk 0.17.2 (in sync with OCP 4.5).

```
curl --output operator-sdk -JL https://github.com/operator-framework/operator-sdk/releases/download/$RELEASE_VERSION/operator-sdk-$RELEASE_VERSION-x86_64-linux-gnu
chmod +x operator-sdk
mkdir -p ~/.local/bin
mv operator-sdk ~/.local/bin
```

## Creating a new release

Creating a new release requires 3 steps:

* update container image versions to deploy in `deploy/operator.yaml`
* generate a new CSV version
* create a new bundle image and push to quay.io/infrawatch-operators

### Updating container image tags

Update the `deploy/operator.yaml` file to target a new set of container image
tags. You will need to adjust the `smart-gateway-operator` version which should
align to the new CSV version. Optionally, update the related container images
for `smart-gateway`, `sg-core` and `sg-bridge` if there are new container
images that should be associated with this CSV release.

If there are any roles, role binding, or deployment adjustments for this
release, now is the time to make those changes. See files in the `deploy/`
root.

The following environment variables are used by the Operator to determine what
components to deploy into the environment. Set the container image tags
appropriately.

```
        - name: SMARTGATEWAY_IMAGE
          value: quay.io/infrawatch/smart-gateway:v2.0.0
        - name: CORE_SMARTGATEWAY_IMAGE
          value: quay.io/infrawatch/sg-core:v3.0.0
        - name: BRIDGE_SMARTGATEWAY_IMAGE
          value: quay.io/infrawatch/sg-bridge:v1.0.0
```

### Updating the CSV manifests

To update the CSV manifests to a new release version use `operator-sdk
generate csv` and pass the new version. The `replaces` line will be
automatically updated.

```
operator-sdk generate csv --csv-version 2.1.0
```

## Create a new bundle container image

Create a new bundle release by updating the bundle container image.

```
operator-sdk bundle create quay.io/infrawatch-operators/smart-gateway-operator-bundle:v2.1.0
```
