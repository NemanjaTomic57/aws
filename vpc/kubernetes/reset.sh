#!/bin/bash

terraform apply -destroy -auto-approve
terraform apply -auto-approve
cd ./ansible
bash provision.sh
