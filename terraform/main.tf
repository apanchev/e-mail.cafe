module "aws" {
  count  = var.deploy_aws ? 1 : 0

  source = "./modules/aws"

  env         = var.env
  region      = var.region
  domain_name = var.domain_name
}