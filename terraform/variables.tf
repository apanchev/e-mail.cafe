locals {
  zone            = "${substr(split("-", var.region)[0], 0, 1)}${substr(split("-", var.region)[1], 0, 1)}${substr(split("-", var.region)[2], 0, 1)}"
  resource_suffix = "${var.project}-${local.zone}-${var.env}"
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "project" {
  type    = string
  default = "e-mail.cafe"
}

variable "domain_name" {
  type = string
}