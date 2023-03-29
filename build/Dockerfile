FROM quay.io/openshift/origin-ansible-operator:4.10

USER 0
RUN dnf install -y python3-passlib python3-bcrypt
USER 1001

COPY roles/ ${HOME}/roles/
COPY watches.yaml ${HOME}/watches.yaml
