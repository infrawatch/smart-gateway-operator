FROM quay.io/openshift/origin-ansible-operator:4.12

USER 0
RUN dnf update -y --exclude=ansible* && dnf clean all && rm -rf /var/cache/dnf

USER 1001
COPY roles/ ${HOME}/roles/
COPY watches.yaml ${HOME}/watches.yaml
