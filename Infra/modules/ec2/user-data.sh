#!/bin/bash

set -euo pipefail
exec > /var/log/cloud-init-output.log 2>&1

echo "Hello from poc2-instance"