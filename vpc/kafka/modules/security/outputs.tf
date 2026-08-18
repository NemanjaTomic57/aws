output "nat_sg" {
  value = aws_security_group.nat.id
}

output "kafka_sg" {
  value = aws_security_group.kafka.id
}
