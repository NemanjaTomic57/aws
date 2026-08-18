output "nat_public_ips" {
  value = {
    for name, instance in aws_instance.nat :
    name => instance.public_ip
  }
}

output "kafka_private_ips" {
  value = {
    for name, instance in aws_instance.kafka :
    name => instance.private_ip
  }
}

output "kafka_bootstrap_server" {
  value = join(",", [
    for _, instance in aws_instance.kafka :
    "${instance.private_ip}:9092"
  ])
}

