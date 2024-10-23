FROM quay.io/operator-framework/ansible-operator:v1.35.0

# temporarily switch to root user to adjust image layers
USER 0

# update the base image to allow forward-looking optimistic updates during the testing phase, with the added benefit of helping move closer to passing security scans.
# -- excludes ansible so it remains at 2.9 tag as shipped with the base image
# -- cleans up the cached data from dnf to keep the image as small as possible
RUN dnf update -y --exclude=ansible* && dnf clean all && rm -rf /var/cache/dnf

# switch back to user 1001 when running the base image (non-root)
USER 1001

# copy in required artifacts for the operator
COPY roles/ ${HOME}/roles/
COPY watches.yaml ${HOME}/watches.yaml
