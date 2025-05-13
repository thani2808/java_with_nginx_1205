output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "igw_id" {
  value = module.vpc.igw_id
}