output "subnet_web_facing" {
    description = "List of ids for the web-facing subnet"
    value = aws_subnet.web-facing.*.id
}

output "subnet_application" {
    description = "List of ids for the application subnet"
    value = aws_subnet.application.*.id
}

output "subnet_db" {
    description = "List of ids for the db subnet"
    value = aws_subnet.db.*.id
}