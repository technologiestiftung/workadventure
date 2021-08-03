

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

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
# data "aws_vpc" "default" {
#   default = true
# }

resource "aws_vpc" "wsa-vpc" {

  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true #gives you an internal domain name
  enable_dns_hostnames = true #gives you an internal host name
  enable_classiclink   = false
  instance_tenancy     = "default"
  tags                 = local.tags

}

resource "aws_subnet" "wsa-subnet-public" {
  vpc_id                  = aws_vpc.wsa-vpc.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true # it makes this a public subnet
  availability_zone       = "eu-central-1a"
  tags                    = local.tags

}

# make internet gateway
resource "aws_internet_gateway" "wsa-ig" {
  vpc_id = aws_vpc.wsa-vpc.id
  tags   = local.tags

}

# make a custom route table
resource "aws_route_table" "wsa-route-table" {
  vpc_id = aws_vpc.wsa-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsa-ig.id
  }
  tags = local.tags

}

resource "aws_route_table_association" "wsa-route-table-association" {
  subnet_id      = aws_subnet.wsa-subnet-public.id
  route_table_id = aws_route_table.wsa-route-table.id

}



# data "aws_subnet_ids" "all" {
#   vpc_id = data.aws_vpc.default.id
# }

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

}

resource "aws_key_pair" "public_key" {
  key_name   = "ff6347-key"
  public_key = file(var.public_key_path)
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "workspaceadventures"
  description = "Security group for workspaceadventures usage with EC2 instance"
  vpc_id      = aws_vpc.wsa-vpc.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH TCP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]


}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.ec2.id[0]
}

# resource "aws_placement_group" "web" {
#   name     = "${local.name}-hunky-dory-pg"
#   strategy = "cluster"
# }

resource "aws_network_interface" "this" {

  subnet_id = aws_subnet.wsa-subnet-public.id
}

module "ec2" {

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"



  instance_count = 1

  name          = local.name
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.wsa-subnet-public.id
  #  private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  # placement_group             = aws_placement_group.web.id
  key_name         = aws_key_pair.public_key.key_name
  user_data_base64 = base64encode(local.user_data)

  enable_volume_tags = false
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


# see https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/issues/48#issuecomment-767766578
# about provisioning on the remote while using this module
resource "null_resource" "ec2_instance" {

  # Changes to the instance will cause the null_resource to be re-executed
  triggers = {
    instance_ids = module.ec2.id[0]
  }

  # Running the remote provisioner like this ensures that ssh is up and running
  # before running the local provisioner

  provisioner "remote-exec" {
    inline = ["echo Hello World"]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = element(module.ec2.public_ip, 0)
  }
}
