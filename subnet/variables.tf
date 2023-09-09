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