output "database_sg_id" {
    description = "Id for the database sg"
    value = aws_security_group.database-sg.id
}

output "webserver_sg_id" {
    description = "Id for the webserver sg"
    value = aws_security_group.webserver-sg.id
}

output "web_sg_id" {
    description = "Id for the web sg"
    value = aws_security_group.web-sg.id
}
output "app_sg_id" {
    description = "Id for the app sg"
    value = aws_security_group.app-sg.id
}