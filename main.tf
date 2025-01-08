provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "ansible_key" {
  key_name   = "ansible-key"
  public_key = file("~/.ssh/roadmap.pub")  
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]  # Allow to any destination
  }
}

resource "aws_instance" "ansible_ready_instance" {
  ami             = "ami-08eb150f611ca277f"  # Ubuntu t3 24.04 AMI ID
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.ansible_key.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  tags = { Name = "Roadmap-project" }
}

output "instance_ip" {
  value = aws_instance.ansible_ready_instance.public_ip
}