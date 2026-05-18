#!/bin/bash

python main.py
ansible-playbook -i hosts ./ansible.playbook.yml
ansible-playbook -i hosts ./ansible.kubeadm-init-workers.yml
