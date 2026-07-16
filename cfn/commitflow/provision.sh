#!/bin/bash -xeu

aws cloudformation deploy --template-file cfn-deploy.yml --stack CommitFlow

IP=$(aws cloudformation describe-stacks \
    --stack-name CommitFlow \
    --query "Stacks[0].Outputs[?OutputKey=='PublicIP'].OutputValue" \
    --output text)

cat > ansible-inventory.yml <<EOF
---
ec2:
  hosts:
    vm1:
      ansible_host: $IP

  vars:
    ansible_user: admin
    ansible_ssh_private_key_file: /home/ntomic/.ssh/aws.pem
    ansible_ssh_common_args: "-o StrictHostKeyChecking=no"
EOF

ansible-playbook \
  -i ansible-inventory.yml \
  ansible-playbook.yml \
  --vault-password-file <(
    ANSIBLE_VAULT_PASSWORD=$(aws ssm get-parameter \
      --name /commitflow/ansible-vault-password \
      --query "Parameter.Value" \
      --output text --with-decryption)
    )
