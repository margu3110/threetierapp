variable "application_subnet_cidr" {
    type = list
}

variable "database_subnet_cidr" {
    type = list
}

variable "web_subnet_cidr" {
    type = list
}

variable "availability_zone_names" {
    type = list
}

variable "vpc_id" {
    type = string
}

variable "item_count" {
    type = number
}

variable "appName" {
    type = string
}

### Create Web Public Subnet
resource "aws_subnet" "web-facing" {
  count                   = var.item_count
  vpc_id                  = var.vpc_id
  cidr_block              = var.web_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "web-${count.index + 1}"
    appName = var.appName
  }
}

### Create Application Private Subnet
resource "aws_subnet" "application" {
  count                   = var.item_count
  vpc_id                  = var.vpc_id
  cidr_block              = var.application_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "application-${count.index + 1}"
    appName = var.appName
  }
}


### Create Database Private Subnet
resource "aws_subnet" "db" {
  count             = var.item_count
  vpc_id            = var.vpc_id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "db-${count.index + 1}"
    appName = var.appName
  }
}

