output "vpc-id" {
  value = module.vpc.vpc-id
}

output "private-subnets" {
  value = module.vpc.private-subnets
}

output "public-subnets" {
  value = module.vpc.public-subnets
}

