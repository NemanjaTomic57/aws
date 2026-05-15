# HACK: For merging tags
# tags = merge(
#   var.common_tags,
#   {
#     Name = "web-server"
#   }
# )

variable "tag_name" {
  description = "Name tag to apply to all resrouces."
  type        = string
  default     = "Kubernetes"
}

variable "tag_instance_controlplane" {
  type = map(string)

  default = {
    NodeType = "Controlplane"
  }
}

variable "tag_instance_worker" {
  type = map(string)

  default = {
    NodeType = "Worker"
  }
}

variable "luconsult_ip" {
  description = "Allow SSH traffic from this IP."
  type        = string
  default     = "62.4.93.238/32"
}

variable "ami_id" {
  description = "AMI for the EC2 instances. Defaults to Debian 13."
  type        = string
  default     = "ami-0b75f821522bcff85"
}
