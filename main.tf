terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    region = var.region
    profile = "terraform"
}

### Subnet Module
module "subnetModule" {
    source = "./subnet"
    appName = var.appName
    item_count = var.item_count
    vpc_id = aws_vpc.vpc-1.id
    availability_zone_names = var.availability_zone_names
    web_subnet_cidr = var.web_subnet_cidr
    application_subnet_cidr = var.application_subnet_cidr
    database_subnet_cidr = var.database_subnet_cidr
}

### Security Group Module
module "sgModule" {
    source = "./sg"
    appName = var.appName
    vpc_id = aws_vpc.vpc-1.id
}

### Create a VPC
resource "aws_vpc" "vpc-1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Three-tier App demo VPC"
    appName = var.appName
  }
}

### Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "IGW"
    appName = var.appName
  }
}

### Create a Web Facing Routing Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Rt"
    appName = var.appName
  }
}

### Create Subnet Association with Route Table
resource "aws_route_table_association" "a" {
  count          = var.item_count
  subnet_id      = module.subnetModule.subnet_web_facing[count.index]
  route_table_id = aws_route_table.public-rt.id
}

### Create External Load Balancer
resource "aws_lb" "external-lb" {
  name               = "External-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.sgModule.web_sg_id]
  subnets            = module.subnetModule.subnet_web_facing

  enable_deletion_protection = false
  tags = {
    Name = "External-LB"
    appName = var.appName
  }
}

### Create Internal Load Balancer
resource "aws_lb" "internal-lb" {
  name               = "Internal-LB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.sgModule.app_sg_id]
  subnets            = module.subnetModule.subnet_application

  enable_deletion_protection = false
  tags = {
    Name = "Inernal-LB"
    appName = var.appName
  }
}

### Create an External Target Group
resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-1.id
  tags = {
    Name = "ExternalTargetGroup"
    appName = var.appName
  }
}

### Create and Internal Target Group
resource "aws_lb_target_group" "internal-elb" {
  name     = "ILB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-1.id
  tags = {
    Name = "InternalTargetGroup"
    appName = var.appName
  }
}

### Create Target Group Attachment
resource "aws_lb_target_group_attachment" "external-elb1" {
  count            = var.item_count
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.webserver[count.index].id
  port             = 80

  depends_on = [
    aws_instance.webserver,
  ]
}

resource "aws_lb_target_group_attachment" "internal-elb1" {
  count            = var.item_count
  target_group_arn = aws_lb_target_group.internal-elb.arn
  target_id        = aws_instance.appserver[count.index].id
  port             = 80

  depends_on = [
    aws_instance.webserver,
  ]
}

### Create LB Listener
resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-lb.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}

resource "aws_lb_listener" "internal-elb" {
  load_balancer_arn = aws_lb.internal-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-elb.arn
  }
}

### Create WebServer Instance
resource "aws_instance" "webserver" {
  count                  = var.item_count
  key_name        		   = var.instance_key
  ami                    = var.ami_id
  instance_type          = lookup(var.instance_type,terraform.workspace)
  availability_zone      = var.availability_zone_names[count.index]
  vpc_security_group_ids = [module.sgModule.webserver_sg_id]
  subnet_id              = module.subnetModule.subnet_web_facing[count.index]
  user_data              = file("install_apache.sh")

  tags = {
    Name = "Web Server-${count.index}"
    appName = var.appName
  }
}

### Create App Instance
resource "aws_instance" "appserver" {
  count                  = var.item_count
  key_name        		   = var.instance_key
  ami                    = var.ami_id
  instance_type          = lookup(var.instance_type,terraform.workspace)
  availability_zone      = var.availability_zone_names[count.index]
  vpc_security_group_ids = [module.sgModule.database_sg_id]
  subnet_id              = module.subnetModule.subnet_application[count.index]

  tags = {
    Name = "App Server-${count.index}"
    appName = var.appName
  }
}

# ### Create RDS Instance
# resource "aws_db_instance" "default" {
#   allocated_storage      = var.rds_instance.allocated_storage
#   db_subnet_group_name   = aws_db_subnet_group.default.id
#   engine                 = var.rds_instance.engine
#   engine_version         = var.rds_instance.engine_version
#   instance_class         = var.rds_instance.instance_class
#   multi_az               = var.rds_instance.multi_az
#   name                   = var.rds_instance.name
#   username               = var.user_information.username
#   password               = var.user_information.password
#   skip_final_snapshot    = var.rds_instance.skip_final_snapshot
#   vpc_security_group_ids = [module.sgModule.database_sg_id]
#   tags = {
#     Name = "RDS"
#     appName = var.appName
#   }
# }

# ### Create RDS Subnet Group
# resource "aws_db_subnet_group" "default" {
#   name       = "main"
#   subnet_ids = module.subnetModule.subnet_db
#   tags = {
#     name = "My DB subnet group"
#     appName = var.appName
#   }
# }