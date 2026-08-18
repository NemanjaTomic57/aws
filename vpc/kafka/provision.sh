#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

terraform apply -auto-approve

cd ./ansible

python build_inventory.py
ansible-playbook -i inventory.yml playbook.yml -T 10

