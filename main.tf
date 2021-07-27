module "vpc" {
  source = "./modules/vpc"
  vpc    = var.vpc
}
