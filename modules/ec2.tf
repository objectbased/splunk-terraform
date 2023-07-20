# EC2

resource "aws_instance" "splunk_single_node" {
  ami = "ami-03c7c1f17ee073747"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private_subnet.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.splunk_single_node.name
  vpc_security_group_ids = [aws_security_group.splunk_ingress.id, aws_security_group.splunk_egress.id]
  user_data = data.template_file.splunk_bootstrap.rendered

  tags = {
    Name = "Splunk-Single-Host"
  }
}

# Security Groups

resource "aws_security_group" "splunk_ingress" {
  name        = "splunk_listener_ports"
  description = "Splunk listener ports used for communication with application."
  vpc_id = aws_vpc.private_vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.home_nat_ip]
  }

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = [var.home_nat_ip]
  }
}

resource "aws_security_group" "splunk_egress" {
  name        = "splunk_egress_ports"
  description = "Splunk egress ports used for communication with application."
  vpc_id = aws_vpc.private_vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Shell script for bootstrap

data "template_file" "splunk_bootstrap" {
  template = file("./scripts/splunk.sh")
}