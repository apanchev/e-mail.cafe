

module "aws" {
  source = "./modules/aws"

  env         = var.env
  region      = var.region
  domain_name = var.domain_name
}