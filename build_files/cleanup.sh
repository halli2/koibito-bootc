#!/usr/bin/bash

set -eoux pipefail
dnf clean all
rm -rf /tmp/* || true
rm /var/{log,cache,lib}/* -rf
