locals {
  zone            = "${substr(split("-", var.region)[0], 0, 1)}${substr(split("-", var.region)[1], 0, 1)}${substr(split("-", var.region)[2], 0, 1)}"
  resource_suffix = "${var.project}-${local.zone}-${var.env}"
}

data "aws_caller_identity" "current" {}

variable "env" {
  description = "Name of the environment Terraform is going to deploy the project. (ex: prod / dev)"
  type        = string
}

variable "region" {
  description = "AWS region name Terraform is going to deploy the project. (ex: eu-west-1)"
  type        = string
}

variable "project" {
  description = "Name of the project."
  type        = string
  default     = "emailcafe"
}

variable "domain_name" {
  description = "Domain name you want to use for the project. (ex: e-mail.cafe)"
  type        = string
}

variable "webapp_port" {
  description = "Port used for the web application"
  type        = number
  default     = 8000
}