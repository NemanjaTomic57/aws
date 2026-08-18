import json
import subprocess

import yaml

# Output names for Terraform output
TF_OUTPUT_NAT_PUBLIC_IPS = "nat_public_ips"
TF_OUTPUT_KAFKA_PRIVATE_IPS = "kafka_private_ips"

# Default SSH user used by Ansible to connect to all hosts.
BASTION_USER = "ec2-user"
KAFKA_USER = "admin"

def terraform_output():
    result = subprocess.run(
        ["terraform", "output", "-json"],
        capture_output=True,
        text=True,
        cwd="./..",
        check=True,
    )

    return json.loads(result.stdout)


def build_inventory(tf):
    bastion_ip = next(iter(tf[TF_OUTPUT_NAT_PUBLIC_IPS]["value"].values()))
    kafka_private_ips = tf[TF_OUTPUT_KAFKA_PRIVATE_IPS]["value"]

    inventory = {
        "all": {
            "vars": {
                "ansible_ssh_private_key_file": "~/.ssh/aws.pem",
            },
            "children": {
                "kafka": {
                    "vars": {
                        "ansible_user": KAFKA_USER,
                        # Route all SSH connections through the bastion host.
                        "ansible_ssh_common_args": (
                            "-o StrictHostKeyChecking=no "
                            "-o ProxyCommand=\"ssh "
                            "-i ~/.ssh/aws.pem "
                            "-o StrictHostKeyChecking=no "
                            f"-W %h:%p {BASTION_USER}@{bastion_ip}\""
                        ),

                        "kafka": "/opt/kafka",
                        "kafka_logs": "{{ kafka }}/logs",
                        "kafka_bin": "{{ kafka }}/bin",
                        "kafka_config": "{{ kafka }}/config",
                        "kafka_config_server": "{{ kafka_config }}/server.properties",
                        "kafka_cluster_uuid": "9QRITYyyS2qeAIfDgxB3OA"
                        },
                    "hosts": {}
                },
            },
        }
    }

    print()
    print('---------------------------------------')
    print('SSH command for bastion:')
    ssh_command_bastion(bastion_ip)

    print()
    print('---------------------------------------')
    print('SSH command for Kafka nodes:')
    # Add every Kafka node to the inventory.
    for idx, (_, ip) in enumerate(kafka_private_ips.items(), start=1):
        inventory["all"]["children"]["kafka"]["hosts"][f"kafka-{idx}"] = {
            "ansible_host": ip
        }
        ssh_command_kafka(bastion_ip, ip)

    return inventory


def ssh_command_bastion(bastion: str) -> None:
    print(f'ssh -i ~/.ssh/aws.pem {BASTION_USER}@{bastion}')


def ssh_command_kafka(bastion: str, kafka_node: str) -> None:
    print(f'ssh -i ~/.ssh/aws.pem -o ProxyCommand="ssh -i ~/.ssh/aws.pem -W %h:%p {BASTION_USER}@{bastion}" {KAFKA_USER}@{kafka_node}')


def main():
    """
    Generate an Ansible inventory from Terraform outputs.

    The inventory is written to 'inventory.yml' in the current directory.
    """
    # Read Terraform outputs.
    tf = terraform_output()

    # Convert Terraform outputs into an Ansible inventory.
    inventory = build_inventory(tf)

    # Write the inventory to disk.
    with open("inventory.yml", "w") as f:
        yaml.safe_dump(inventory, f, sort_keys=False)

    print("Generated inventory.yml")


if __name__ == "__main__":
    main()

