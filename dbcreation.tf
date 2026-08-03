resource "random_password" "db_password" {
  length           = 16
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password_wo          = random_password.db_password.result
  password_wo_version  = 1
  skip_final_snapshot  = true
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "db_pass6"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id                = aws_secretsmanager_secret.db_password.id
    secret_string_wo = jsonencode({
      username = "admin"
      password = random_password.db_password.result
  })
  secret_string_wo_version = 1
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret_version.db_password.secret_id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_address" {
  value = aws_db_instance.mysql.address
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}

output "rds_arn" {
  value = aws_db_instance.mysql.arn
}

output "rds_id" {
  value = aws_db_instance.mysql.id
}
