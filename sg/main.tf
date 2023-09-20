locals {
    web_ports = [80,443] 
    ssh_port = 22
    mysql_port = 3306
}


### Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "Web-SG"
  description = "Allow HTTP Inbound Traffic"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.web_ports
    content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-SG"
    appName = var.appName
  }
}

### Create Web Server Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "Webserver-SG"
  description = "Allow Inbound Traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from web layer"
    from_port       = local.web_ports[0]
    to_port         = local.web_ports[0]
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  ingress {
    description     = "Allow SSH Inbound Traffic"
    from_port   = local.ssh_port
    to_port     = local.ssh_port
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
    Name = "Webserver-SG"
    appName = var.appName
  }
}

### Create Application Security Group
resource "aws_security_group" "app-sg" {
  name        = "App-SG"
  description = "Allow SSH Inbound Traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from VPC"
    from_port       = local.ssh_port
    to_port         = local.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-SG"
    appName = var.appName
  }
}

### Create Database Security Group
resource "aws_security_group" "database-sg" {
  name        = "Database-SG"
  description = "Allow Inbound Traffic from application layer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from application layer"
    from_port       = local.mysql_port
    to_port         = local.mysql_port
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database-SG"
    appName = var.appName
 }
}