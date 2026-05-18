#!/bin/bash

set -e

terraform apply -destroy -auto-approve
terraform apply -auto-approve

cd ./ansible
bash provision.sh
