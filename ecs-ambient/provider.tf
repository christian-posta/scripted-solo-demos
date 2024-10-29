terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = local.region
  default_tags {
    tags = {
      owner = "ceposta"
    }
  }
}

variable "ECHO_TOKEN" {
  type = string
}

variable "SHELL_TOKEN" {
  type = string
}


locals {
  name          = "ceposta-ecs-ambient"
  ecs_cluster_arn = "arn:aws:ecs:us-east-2:606469916935:cluster/ceposta-ecs-ambient"
  region        = "us-east-2"
  vpc           = "vpc-0ec6fe1dd6b071ca9"
  ztunnel_image = "606469916935.dkr.ecr.us-east-2.amazonaws.com/ceposta:ztunnel-ecs-1724286208"
}

// Made out of tf for now
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [local.vpc]
  }
}


resource "aws_service_discovery_private_dns_namespace" "this" {
  name = local.name
  vpc  = local.vpc
}

resource "aws_service_discovery_service" "echo-ztunnel" {
  name        = "echo-ztunnel"
  description = "CloudMap namespace for echo"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}



module "echo_ztunnel_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.11"

  name        = "echo-ztunnel"
  cluster_arn = local.ecs_cluster_arn

  desired_count      = 1
  enable_autoscaling = false

  assign_public_ip = true
  # Task Definition
  enable_execute_command = true
  cpu                    = 256
  memory                 = "512"
  service_registries = {
    registry_arn = aws_service_discovery_service.echo-ztunnel.arn

  }
  subnet_ids = data.aws_subnets.private.ids
  container_definitions = {
    echo = {
      image                    = "gcr.io/istio-testing/app"
      readonly_root_filesystem = false
      port_mappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
    }

    ztunnel = {
      image       = local.ztunnel_image
      environment = [{ name = "BOOTSTRAP_TOKEN", value = var.ECHO_TOKEN }]
    }
  }
  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_all = {
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "shell_task" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = "shell"
  cluster_arn = local.ecs_cluster_arn

  assign_public_ip = true
  # Container definition(s)
  cpu    = 256
  memory = "512"
  container_definitions = {
    shell = {
      image                    = "howardjohn/shell"
      readonly_root_filesystem = false
      command                  = ["sleep infinity"]
      entrypoint               = ["bash", "-c"]
    }
  }
  enable_execute_command = true
  subnet_ids             = data.aws_subnets.private.ids
  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}


module "shell_task_ztunnel" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = "shell-ztunnel"
  cluster_arn = local.ecs_cluster_arn

  assign_public_ip = true
  # Container definition(s)
  cpu    = 256
  memory = "512"
  container_definitions = {
    shell = {
      image                    = "howardjohn/shell"
      readonly_root_filesystem = false
      command                  = ["sleep infinity"]
      entrypoint               = ["bash", "-c"]
    }
    ztunnel = {
      image       = local.ztunnel_image
      environment = [{ name = "BOOTSTRAP_TOKEN", value = var.SHELL_TOKEN }]
    }
  }
  enable_execute_command = true
  subnet_ids             = data.aws_subnets.private.ids
  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
