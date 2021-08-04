
provider "aws" {
  region  = local.region
  profile = local.profile
}

locals {
  name      = "workspaceadventures"
  env       = "dev"
  region    = "eu-central-1"
  profile   = "tsberlin"
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF
  tags = {
    Project     = "workspaceadventures"
    Environment = "dev"
  }
}


# TODO: Needs larger disk space
module "ec2" {

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"



  instance_count = 1

  name          = local.name
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.wsa-subnet-public.id
  #  private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  # placement_group             = aws_placement_group.web.id
  key_name         = aws_key_pair.public_key.key_name
  user_data_base64 = data.template_cloudinit_config.config.rendered
  # base64encode(local.user_data)

  enable_volume_tags = false
  # TODO: EC2 Needs a little more disk attached to it

  # root_block_device = [
  #   {
  #     volume_type = "gp2"
  #     volume_size = 10
  #     tags = {
  #       Name = "my-root-block"
  #     }
  #   },
  # ]

  # ebs_block_device = [
  #   {
  #     device_name = "/dev/sdf"
  #     volume_type = "gp2"
  #     volume_size = 5
  #     encrypted   = true
  #     kms_key_id  = aws_kms_key.this.arn
  #   }
  # ]

  tags = local.tags
}
