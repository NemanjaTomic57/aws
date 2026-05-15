output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "controlplane_private_ips" {
  value = aws_instance.controlplanes[*].private_ip
}

output "worker_private_ips" {
  value = aws_instance.workers[*].private_ip
}
