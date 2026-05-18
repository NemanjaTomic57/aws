from pathlib import Path
import subprocess
import json

TF_STATE = "../terraform.tfstate"
ANSIBLE_USER = "admin"
OUTPUT_FILE = "hosts"

TF_VARS = {
    "bastion_ip": "ec2_bastion_public_ip",
    "controlplane_ips": "ec2_controlplane_private_ips",
    "worker_ips": "ec2_worker_private_ips"
}


def get_terraform_output(state_file: str) -> tuple[str, list[str], list[str]]:
    """
    Returns the IPs from the bastion host (public), the controlplanes (private) 
    and the workers (private) in the VPS.
    """

    tf_output = subprocess.run(["terraform", "output", f"-state={state_file}", "-json"], capture_output=True, text=True)
    tf_output =  json.loads(tf_output.stdout)

    return (
        tf_output[TF_VARS["bastion_ip"]]["value"],
        tf_output[TF_VARS["controlplane_ips"]]["value"],
        tf_output[TF_VARS["worker_ips"]]["value"]
    )


def build_inventory(bastion_ip: str, controlplane_ips: list[str], worker_ips: list[str], ansible_user: str) -> str:
    """Build the Ansible inventory file content."""

    proxy_args = f"-o StrictHostKeyChecking=off -o ProxyJump={ansible_user}@{bastion_ip}"

    lines = ["[controlplanes]"]
    lines += [f"controlplane{i} ansible_host={ip}" for i, ip in enumerate(controlplane_ips)]

    lines += ["\n[workers]"]
    lines += [f"worker{i} ansible_host={ip}" for i, ip in enumerate(worker_ips)]

    lines += [
        "\n[nodes:children]",
        "controlplanes",
        "workers",
        "\n[nodes:vars]",
        f"ansible_user={ansible_user}",
        f"ansible_ssh_common_args={proxy_args}",
        "\napiserver_vip=192.168.72.100"
        "\napiserver_dest_port=6221"
    ]

    return "\n".join(lines) + "\n"


def write_inventory(content: str, output_path: str) -> None:
    """Write inventory content to the specified file."""
    Path(output_path).write_text(content, encoding='utf8')


def ssh_command(bastion: str, controlplane: str) -> None:
    print(f"ssh -J admin@{bastion} admin@{controlplane}")


def main():
    bastion_ip, controlplane_ips, worker_ips = get_terraform_output(TF_STATE)
    inventory = build_inventory(bastion_ip, controlplane_ips, worker_ips, ANSIBLE_USER)
    write_inventory(inventory, OUTPUT_FILE)
    print(f"Inventory written to '{OUTPUT_FILE}'")

    ssh_command(bastion_ip, controlplane_ips[0])

    
if __name__ == "__main__":
    main()
