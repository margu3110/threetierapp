variable "vpc_id" {
    type = string
}

variable "web_ports" {
    type        = list(number)
    description = "list of web ports"
    default     = [80,443] 
}
