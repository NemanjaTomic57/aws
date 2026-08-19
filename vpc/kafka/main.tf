terraform {
  backend "s3" {
    bucket = "terraform-761018874759"
    key    = "aws/vpc/kafka.tfstate"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

##################################################
# VPC
##################################################

module "vpc" {
  source = "./modules/vpc"

  name     = var.name
  vpc_cidr = "192.168.0.0/16"
  public_subnet_cidrs = {
    "public-1" = {
      cidr = "192.168.0.0/24",
      az   = "eu-central-1a"
    },
  }
  private_subnet_cidrs = {
    "private-1" = {
      cidr = "192.168.32.0/24",
      az   = "eu-central-1a"
    },
  }
}

##################################################
# Security Groups
##################################################

module "security_groups" {
  source = "./modules/security"

  name     = var.name
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr
}

##################################################
# EC2
##################################################

module "ec2" {
  source = "./modules/ec2"

  name            = var.name
  vpc_id          = module.vpc.vpc_id
  igw             = module.vpc.igw
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  nat_sg          = module.security_groups.nat_sg
  kafka_sg        = module.security_groups.kafka_sg
  ami_id = {
    nat   = "ami-07b68a9bcf82c54eb",
    kafka = "ami-0007785b133e034f0"
  }
  instance_type = {
    nat   = "t4g.nano"
    kafka = "t4g.medium"
  }
  key_name = "aws"
}
