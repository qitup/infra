variable "name"              { }
variable "artifact_type"     { }
variable "region"            { }
variable "sub_domain"        { }

variable "vpc_cidr"        { }
variable "azs"             { }
variable "private_subnets" { }
variable "public_subnets"  { }
//
//variable "bastion_instance_type" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.atlas_environment}"
  public_key = "${var.site_public_key}"

  lifecycle { create_before_destroy = true }
}

resource "terraform_remote_state" "aws_global" {
  backend = "s3"

  config {
    name = "${var.atlas_username}/${var.atlas_aws_global}"
  }

  lifecycle { create_before_destroy = true }
}

data "aws_availability_zones" "available_zones" {}

resource "random_shuffle" "azs" {
  input = data.available_zones
  result_count = 1
}

module "network" {
  source = "../../../modules/aws/network"

  name            = "${var.name}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${random_shuffle.azs.result}"
  region          = "${var.region}"
  private_subnets = ""
  public_subnets  = "${var.public_subnets}"
  key_name        = "${aws_key_pair.site_key.key_name}"
  private_key     = "${var.site_private_key}"
  sub_domain      = "${var.sub_domain}"
  route_zone_id   = "${terraform_remote_state.aws_global.output.zone_id}"
}

module "data" {
  source = "../../../modules/aws/data"

  name               = "${var.name}"
  region             = "${var.region}"
  vpc_id             = "${module.network.vpc_id}"
  vpc_cidr           = "${var.vpc_cidr}"
  private_subnet_ids = "${module.network.private_subnet_ids}"
  public_subnet_ids  = "${module.network.public_subnet_ids}"
  ssl_cert           = "${var.vault_ssl_cert}"
  ssl_key            = "${var.vault_ssl_key}"
  key_name           = "${aws_key_pair.site_key.key_name}"
  atlas_username     = "${var.atlas_username}"
  atlas_environment  = "${var.atlas_environment}"
  atlas_token        = "${var.atlas_token}"
  sub_domain         = "${var.sub_domain}"
  route_zone_id      = "${terraform_remote_state.aws_global.output.zone_id}"
}
