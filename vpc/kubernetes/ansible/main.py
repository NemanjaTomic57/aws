import subprocess
import json

tf_output = subprocess.run(['terraform', 'output', '-state=../terraform.tfstate', '-json'], capture_output=True, text=True)
tf_output = json.loads(tf_output.stdout)

print(json.dumps(tf_output, indent=2, sort_keys=True))

bastion_ip = tf_output['ec2_bastion_public_ip']['value']
controlplane_ips = tf_output['ec2_controlplane_private_ips']['value']
worker_private_ips = tf_output['ec2_worker_private_ips']['value']

for ip in controlplane_ips:
    print(ip)
