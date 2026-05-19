#!/bin/bash

set -e

terraform apply -destroy -auto-approve
terraform apply -auto-approve
sleep 60

cd ./ansible
bash provision.sh
