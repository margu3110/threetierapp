variable "region" {
    default = "us-east-1"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

### App name
variable "appName" {}

### SSH key name
variable "instance_key" {}

### Count variable
variable "item_count" {
  description = "default count used to set AZs and instances"
  type        = number
  default     = 2
}

### VPC variable
variable "vpc_cidr" {
  description = "default VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

### Availability Zone variable
variable "availability_zone_names" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

### Web Subnet CIDR
variable "web_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]

}

### Application Subnet CIDR
variable "application_subnet_cidr" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

### Database Subnet CIDR
variable "database_subnet_cidr" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]

}

### Database variables
variable "rds_instance" {
  type = map(any)
  default = {
    allocated_storage   = 10
    engine              = "mysql"
    engine_version      = "8.0.33"
    instance_class      = "db.t2.micro"
    multi_az            = true
    name                = "my_db"
    skip_final_snapshot = true
  }
}

### User DB Variables
variable "user_information" {
  type = map(any)
  default = {
    username = "username"
    password = "password"
  }
  sensitive = true
}

### Instance variable 
variable "ami_id" {
  description = "default ami"
  type        = string
  default     = "ami-0e1d30f2c40c4c701"
}
variable "instance_type" {
  description = "default instance type"
  type        = string
  default     = "t2.micro"
}