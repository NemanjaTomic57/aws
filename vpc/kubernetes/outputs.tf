output "ec2_bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "ec2_controlplane_private_ips" {
  value = aws_instance.controlplanes[*].private_ip
}

output "ec2_worker_private_ips" {
  value = aws_instance.workers[*].private_ip
}
