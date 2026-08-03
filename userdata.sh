#!/bin/bash
set -ex
exec > /var/log/user-data.log 2>&1
echo "Starting user-data..."
sudo dnf update -y
sudo dnf install mariadb105 jq awscli -y
cd /home/ec2-user
curl -O https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
sleep 30
SECRET=$(aws secretsmanager get-secret-value \
    --region ${aws_region} \
    --secret-id ${secret_name} \
    --query SecretString \
    --output text)

echo "SECRET CONTENT:"
echo "$SECRET"

PASSWORD=$(echo "$SECRET" | jq -r '.password')
USERNAME=$(echo "$SECRET" | jq -r '.username')

echo "Waiting for RDS..."

until mysql \
    -h ${db_endpoint} \
    -P ${db_port} \
    -u"$USERNAME" \
    -p"$PASSWORD" \
    --ssl-ca=/home/ec2-user/global-bundle.pem \
    -e "SELECT 1;" >/dev/null 2>&1
do
    sleep 10
done

echo "Connected to RDS"

mysql \
-h ${db_endpoint} \
 -P ${db_port} \
 -u"$USERNAME" \
 -p"$PASSWORD" \
--ssl-ca=/home/ec2-user/global-bundle.pem <<EOF

CREATE DATABASE IF NOT EXISTS company_db;

USE company_db;

CREATE TABLE IF NOT EXISTS employees
(
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE,
    department VARCHAR(50)
);

INSERT INTO employees
(
first_name,
last_name,
email,
salary,
hire_date,
department
)
VALUES
(
'John',
'Doe',
'john.doe@example.com',
50000,
'2026-07-31',
'IT'
),
(
'Jane',
'Smith',
'jane.smith@example.com',
60000,
'2026-07-31',
'HR'
);

INSERT INTO employees
(
first_name,
last_name,
email,
salary,
hire_date,
department
)
VALUES
(
'Dasi',
'Venkat',
'venkat@example.com',
50001,
'2027-07-31',
'IT'
),
(
'suresh',
'raja',
'jane.smith@example.com',
60001,
'2026-07-31',
'HR'
);

EOF

echo "Database initialized successfully."