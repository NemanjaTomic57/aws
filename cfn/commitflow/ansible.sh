#!/bin/bash -xeu

ansible-playbook -i ./ansible-inventory.yml ./ansible-playbook.yml
