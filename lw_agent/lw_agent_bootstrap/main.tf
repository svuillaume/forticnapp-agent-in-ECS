provider "aws" {
  region = "ca-central-1"
}

# SSH-only security group
resource "aws_security_group" "samv_demo_sg" {
  name        = "allow_ssh_only"
  description = "Allow SSH inbound only"
  vpc_id      = "vpc-02bb3bfffb72e11c1"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSHOnlySecurityGroup"
  }
}

# EC2 instance using templatefile() for user_data
resource "aws_instance" "samv_demo_instance" {
  ami                    = "ami-052f47efa5f766ee3" # Ubuntu 22.04 LTS in ca-central-1
  instance_type          = "t2.micro"
  subnet_id              = "subnet-017564b2267b23fae"
  vpc_security_group_ids = [aws_security_group.samv_demo_sg.id]
  key_name               = "samv-ssh"

  user_data = templatefile("${path.module}/cloud-init.tpl", {
    install_url = "https://partner-demo.lacework.net/mgr/v1/download/8013ba88dd52a34f72db6acde72cb14dafa6a7b86a565de9f34bd02c/install.sh"
  })

  tags = {
    Name = "samv_demo_instance_cloudinit"
  }

  depends_on = [aws_security_group.samv_demo_sg]
}
