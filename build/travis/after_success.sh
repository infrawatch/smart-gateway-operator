#!/bin/bash

# Fail on error
set -e

REL=$(dirname "$0")

# Add everything, get ready for commit. But only do it if we're on master or a
# named branch of the format <#>.<#>.X. If you want to deploy on different
# branches, you can change this.
if [[ "$BRANCH" =~ ^mazter$|^[0-9]+\.[0-9]+\.X$ ]]; then
    echo "Branch is master, so push new application to Quay registry"
    export PATH=$HOME/bin:$PATH
    curl -L https://github.com/operator-framework/operator-sdk/releases/download/v0.12.0/operator-sdk-v0.12.0-x86_64-linux-gnu -o $HOME/bin/operator-sdk
    chmod +x $HOME/bin/operator-sdk
    ${REL}/../update_csv.sh
    ${REL}/../push_app2quay.sh
else
    echo "Not on master, so won't push new application artifacts"
fi
