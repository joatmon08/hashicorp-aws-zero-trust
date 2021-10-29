resource "aws_security_group" "ecs" {
  name        = "ecs-container-instances"
  description = "ECS security group"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "egress_ecs" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "https_client" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = aws_security_group.ecs.id
  description              = "Allow all TCP traffic between ECS container instances"
}

resource "aws_kms_key" "ecs" {
  description             = "${var.name}-ecs"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = var.name
}

resource "aws_ecs_cluster" "cluster" {
  name = var.name

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
      }
    }
  }

  tags = local.tags
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "ec2_profile" {
  source  = "terraform-aws-modules/ecs/aws//modules/ecs-instance-profile"
  version = "3.4"
  name    = var.name
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.7"

  name = var.name

  use_lc    = true
  create_lc = true
  lc_name   = var.name

  key_name                  = var.key_pair_name
  image_id                  = data.aws_ami.amazon_linux_ecs.id
  instance_type             = "t2.micro"
  security_groups           = [aws_security_group.ecs.id]
  iam_instance_profile_name = module.ec2_profile.iam_instance_profile_id
  user_data = templatefile("./templates/user_data.tmpl.sh", {
    cluster_name = aws_ecs_cluster.cluster.name
  })

  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = var.ecs_cluster_size
  desired_capacity          = var.ecs_cluster_size
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Cluster"
      value               = var.name
      propagate_at_launch = true
    }
  ]
}