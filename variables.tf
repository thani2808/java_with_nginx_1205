variable "region" {}

variable "vpc_name" {}

variable "vpc_cidr" {}

variable "cidr_blocks_egress" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "public_subnets" {
  type = list(string)
  default = [
    "10.0.101.0/24",
  ]
}

variable "public_subnet_names" {
  type = list(string)
  default = [
    "public-ap-south-1a",
  ]
}

variable "ami" {}

variable "key_name" {}

variable "instance_type" {}

variable "cidr_blocks_ingress_bastion" {
  type    = list(string)
  default = ["49.204.129.237/32"]
}