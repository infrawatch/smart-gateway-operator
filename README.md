# smart-gateway-operator

Operator for the infra.watch [sg-core](https://github.com/infrawatch/sg-core)

## Deployment to an existing cluster

You can deploy to a local cluster using kustomize via the `Makefile` in the
smart-gateway-operator repository. You must be running a compatible version of
kustomize. You can use `make kustomize-local` to install the preferred version
in your local repository source within the `bin/` subdirectory. You can pass
that the Makefile to use by appending `KUSTOMIZE=$(pwd)/bin/kustomize` to the
`make` command.

By default the `service-telemetry` namespace is used.

```bash
make kustomize-local
make deploy KUSTOMIZE=$(pwd)/bin/kustomize
```

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

```bash
ansible-playbook build/run-ci.yaml -e __local_build_enabled=false
```

# Create a new container image

Container images can be built and pushed using `docker` via `make`. You can
append `VERSION` to set which tagged version of the container image is created.
You can use `IMAGE_TAG_BASE` to set the image path and registry to target.

```bash
make docker-build docker-push VERSION=5.0.0-testing IMAGE_TAG_BASE=quay.io/leifmadsen/smart-gateway-operator
```

If you don't wish to push the image, remove the `docker-push` parameter from being used with the `make` command.

```bash
make docker-build VERSION=5.0.0-testing IMAGE_TAG_BASE=registry.openshift.local/service-telemetry/smart-gateway-operator
```

# Generate a bundle

Bundles can be created via the `./build/generate_bundle.sh` script.

```bash
## Begin bundle creation
-- Generating operator version
---- Operator Version: 5.0.1646425384
-- Generate bundle
~/src/github.com/infrawatch/smart-gateway-operator ~/src/github.com/infrawatch/smart-gateway-operator
operator-sdk generate kustomize manifests -q
cd config/manager && /home/leif/.local/bin/kustomize edit set image controller=quay.io/infrawatch/smart-gateway-operator:5.0.1646425384
/home/leif/.local/bin/kustomize build config/manifests | operator-sdk generate bundle -q --overwrite --version 5.0.1646425384 --channels=unstable --default-channel=unstable
INFO[0000] Creating bundle.Dockerfile
INFO[0000] Creating bundle/metadata/annotations.yaml
INFO[0000] Bundle metadata generated suceessfully
operator-sdk bundle validate ./bundle
INFO[0000] All validation tests have completed successfully
~/src/github.com/infrawatch/smart-gateway-operator
---- Replacing variables in generated manifest
---- Generated bundle complete at bundle/manifests/smart-gateway-operator.clusterserviceversion.yaml
***
Bundle has been created locally. To build and push the bundle to your remote registry run:
> make bundle-build bundle-push
***
## End Bundle creation
```
