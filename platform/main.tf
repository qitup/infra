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
