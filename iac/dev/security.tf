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
