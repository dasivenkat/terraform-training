variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "Terraform-EC2"
}

variable "aws_region" {
  default = "ap-south-2"
}

variable "db_port" {
 default = "3306"
}
