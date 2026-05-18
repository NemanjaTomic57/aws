#!/bin/bash

set -e

python main.py
ansible-playbook -i hosts ./ansible.playbook.yml
