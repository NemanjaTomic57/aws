output "nat_public_ips" {
  value = module.ec2.nat_public_ips
}

output "kafka_private_ips" {
  value = module.ec2.kafka_private_ips
}

output "kafka_bootstrap_server" {
  value = module.ec2.kafka_bootstrap_server
}

