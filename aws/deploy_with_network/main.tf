terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
      }
    }
}

provider "aws" {
    region = var.region[0]
    shared_credentials_files = ["${file("${path.module}/credentials")}"]
}

locals {
  felix_east1_key = "felixm-lightbits-se-01-us-east-1-key"
  east1_deployment_bucket = "lightbitslabs-deployment"
}

resource "aws_cloudformation_stack" "lightbits_cf" {
  name = "fm_lightbits_with_network_tf"

  parameters = {
    //Network
    "Region" = var.region[0]
    "AvailabilityZone" = var.availability_zone[0]
    "ExistingVpcId" = var.existing_vpc_id
    "VpcCIDR" = var.vpc_cidr
    "PrivateSubnetCIDR" = var.private_subnet_cidr
    "ConnectivityCIDR" = var.vpc_cidr

    //Storage
    "InstanceCount" = var.instance_count
    "InstanceType" = var.instance_type[0]
    "KeyName" = local.felix_east1_key
    "S3ConfBucketName" = local.east1_deployment_bucket
  }

  template_url = var.lb_latest_template_url

  tags = var.tags
}