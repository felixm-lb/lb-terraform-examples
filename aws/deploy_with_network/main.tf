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
    shared_credentials_files = ["${path.module}./credentials"]
    profile = "442210967146_ps-global-storage-sandbox-admin"
}

locals {
  felix_east1_key = "felixm-lightbits-se-01-us-east-1-key"
  east1_deployment_bucket = "lightbitslabs-deployment"
  felix_ip = "99.92.54.50/32"
}

resource "aws_cloudformation_stack" "lightbits_cf" {
  name = "fm-lightbits-with-network-tf"

  capabilities = [ "CAPABILITY_IAM" ] // Required because we're deploying IAM related resources in the nested stacks

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
    "KeyPairName" = local.felix_east1_key
    "S3ConfBucketName" = local.east1_deployment_bucket
  }

  template_url = var.lb_latest_template_url

  tags = var.tags
}

data "aws_vpc" "lb_vpc" {
  filter {
    name = "tag:Name"
    values = [format("*${aws_cloudformation_stack.lightbits_cf.name}*")]
  }
}

data "aws_subnet" "public_sn" {
  filter {
    name = "tag:Name"
    values = [format("*${aws_cloudformation_stack.lightbits_cf.name}*public*")]
  }
}

resource "aws_security_group" "allow_external" {
  name        = "allow_external"
  description = "Allow inbound traffic from specific address"
  vpc_id      = data.aws_vpc.lb_vpc.id

  ingress {
    description      = "SSH from External"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [local.felix_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "client" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = local.felix_east1_key
  associate_public_ip_address = true
  availability_zone = var.availability_zone[0]
  subnet_id = data.aws_subnet.public_sn.id
  security_groups = [ aws_security_group.allow_external.id ]

  user_data = "${file("configure_ubuntu.sh")}"

  tags = {
    Name = "felixm-client"
    Creator = "felixm"
    Method = "Terraform"
  }
}
