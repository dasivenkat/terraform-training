resource "aws_instance" "myec2" {
  ami                    = "ami-0b2ac1bf38835e348"
  instance_type          = "t3.micro"
  key_name               = "terraform-key"
  vpc_security_group_ids = ["sg-0ebb3e1f9c1d52645"]

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/userdata.sh", {
    aws_region  = var.aws_region
    db_port = var.db_port
    db_endpoint = aws_db_instance.mysql.address
    secret_name = aws_secretsmanager_secret.db_password.name
  })

  provisioner "local-exec" {
    when    = destroy
    command = "echo ${self.public_ip} >> server_ip.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo Server destroyed at $(date) >> destroy.log"
  }

  tags = {
    Name = var.instance_name
  }

  depends_on = [
    aws_db_instance.mysql,
    aws_secretsmanager_secret_version.db_password
  ]
}