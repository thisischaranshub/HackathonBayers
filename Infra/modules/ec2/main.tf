locals {
  blue_green_map = {
    "blue" : "v1",
    "green": "v2"
  }
}

resource "aws_placement_group" "this" {
  name     = "${var.deduced_name}-placement-group"
  strategy = var.placement_group_strategy

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-placement-group"
  })
}

data "aws_ami" "this" {
  for_each         = tomap(var.ami_name_map)
  most_recent      = true
  name_regex       = each.value
  owners           = ["self"]

  filter {
    name   = "name"
    values = [each.value]
  }
}

resource "aws_key_pair" "this" {
  key_name = "${var.deduced_name}-keypair"
  public_key = file(var.keypair_file_path)

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-ssh-keypair"
  })
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.deduced_name}-ec2-sg"
  description = "SG rules for ${var.deduced_name} EC2 SG"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-ec2-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ec2_sg_ingress_rules" {
  for_each          = var.ec2_security_group_rules
  security_group_id = aws_security_group.ec2_sg.id
  description       = each.key
  from_port         = can(regex("([0-9]+)-([0-9]+)", "${each.value.ports}")) ? regex("([0-9]+)-([0-9]+)", "${each.value.ports}")[0] : "${each.value.ports}"
  ip_protocol       = "${each.value.ip_protocol}"
  to_port           = can(regex("([0-9]+)-([0-9]+)", "${each.value.ports}")) ? regex("([0-9]+)-([0-9]+)", "${each.value.ports}")[1] : "${each.value.ports}"
  referenced_security_group_id = each.value.type == "SG" ? each.value.source : null
  cidr_ipv4 = each.value.type == "CIDR" ? each.value.source : null
}

resource "aws_vpc_security_group_egress_rule" "ec2_sg_egress_rules" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.deduced_name}-alb-sg"
  description = "SG rules for ${var.deduced_name} EC2 SG"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { 
    Name = "${var.deduced_name}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_sg_ingress_rules" {
  for_each          = var.alb_security_group_rules
  security_group_id = aws_security_group.alb_sg.id
  description       = each.key
  from_port         = can(regex("([0-9]+)-([0-9]+)", "${each.value.ports}")) ? regex("([0-9]+)-([0-9]+)", "${each.value.ports}")[0] : "${each.value.ports}"
  ip_protocol       = "${each.value.ip_protocol}"
  to_port           = can(regex("([0-9]+)-([0-9]+)", "${each.value.ports}")) ? regex("([0-9]+)-([0-9]+)", "${each.value.ports}")[1] : "${each.value.ports}"
  referenced_security_group_id = each.value.type == "SG" ? each.value.source : null
  cidr_ipv4 = each.value.type == "CIDR" ? each.value.source : null
}

resource "aws_vpc_security_group_egress_rule" "alb_sg_egress_rules" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_lb" "this" {
  name               = "${var.deduced_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.alb_subnet_ids

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "this" {
  for_each = local.blue_green_map
  name     = "${var.deduced_name}-${each.key}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id  = var.vpc_id

  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.active_asg == "blue" ? aws_lb_target_group.this["blue"].id : aws_lb_target_group.this["green"].id
  }
}

resource "aws_launch_template" "this" {
  for_each = local.blue_green_map
  name = "${var.deduced_name}-${each.key}-lt"

  dynamic "block_device_mappings" {
    for_each = var.ec2_additional_block_device_mappings
    iterator = ebs
    content {
      device_name = ebs.key
      ebs {
        volume_size = ebs.value.volume_size
        volume_type = ebs.value.volume_type
        encrypted = ebs.value.encrypted
      }
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = var.ec2_capacity_reservation_preference
  }

  credit_specification {
    cpu_credits = var.ec2_cpu_credits
  }

  disable_api_stop        = false
  disable_api_termination = false

  ebs_optimized = true

  image_id = data.aws_ami.this["${each.key}"].id

  instance_market_options {
    market_type = var.ec2_market
  }

  instance_type = var.ec2_instance_type

  key_name = aws_key_pair.this.key_name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, { 
    Name = "${var.deduced_name}-instance"
  })
  }

  user_data = filebase64("${path.module}/user-data.sh")
}

resource "aws_autoscaling_group" "this" {
  for_each                  = local.blue_green_map
  name                      = "${var.deduced_name}-${each.key}-asg"
  max_size                  = (each.key == "blue" && var.active_asg == "blue") ? var.asg_scale.max : ((each.key == "green" && var.active_asg == "green")) ? var.asg_scale.max : 0
  min_size                  = (each.key == "blue" && var.active_asg == "blue") ? var.asg_scale.min : ((each.key == "green" && var.active_asg == "green")) ? var.asg_scale.min : 0
  desired_capacity          = (each.key == "blue" && var.active_asg == "blue") ? var.asg_scale.desired_capacity : ((each.key == "green" && var.active_asg == "green")) ? var.asg_scale.desired_capacity : 0
  health_check_grace_period = 300
  health_check_type         = "ELB"
  target_group_arns         = [var.active_asg == "blue" ? aws_lb_target_group.this["blue"].arn : aws_lb_target_group.this["green"].arn]
  force_delete              = true
  # Use only if instance type is not t2 or t3
  # placement_group           = aws_placement_group.this.id
  launch_template {
    id      = aws_launch_template.this["${each.key}"].id
    version = "$Latest"
  }
  vpc_zone_identifier       = var.asg_subnet_ids

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  timeouts {
    delete = "15m"
  }
}