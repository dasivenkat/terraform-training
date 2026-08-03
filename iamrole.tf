resource "aws_iam_role" "ec2_secret_role" {

  name = "EC2-SecretsManager-Role1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_manager_policy" {

  name        = "SecretsManagerReadPolicy"
  description = "Allow EC2 to read secrets from AWS Secrets Manager"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = "*"
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secret_policy" {

  role       = aws_iam_role.ec2_secret_role.name

  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {

  name = "EC2-SecretsManager-Profile1"

  role = aws_iam_role.ec2_secret_role.name
}