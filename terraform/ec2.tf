locals {
  user_data = base64encode(templatefile("${path.module}/../scripts/install-web-server.sh", {
    s3_bucket   = aws_s3_bucket.static_assets.bucket
    region      = var.aws_region
    project_name = var.project_name
  }))
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null
  vpc_security_group_ids = [aws_security_group.web_server.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
  user_data = local.user_data
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
