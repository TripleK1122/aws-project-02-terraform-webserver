🚀 AWS Project 02 — WordPress Infrastructure using Terraform

🌱 Overview
This project demonstrates end-to-end deployment of a WordPress application on AWS using Terraform following Infrastructure as Code (IaC) best practices.
The setup includes a production-grade architecture with VPC, public/private subnets, NAT, EC2, RDS MySQL, and S3 storage.

🏗️ Architecture

VPC (10.0.0.0/16)
├── Public Subnet → EC2 (Apache, PHP, WordPress)
├── Private Subnets → RDS MySQL (assgdb)
├── NAT Gateway → outbound internet for private subnets
└── S3 Bucket (private) for WordPress assets


⚙️ Components

Service	Description
VPC	Custom AWS network with DNS support and isolated architecture
EC2	Amazon Linux 2 running Apache + PHP + WordPress
RDS	MySQL 8.x in private subnets (not publicly accessible)
S3 Bucket	Private storage (optional for media uploads)
NAT Gateway	Internet access for private subnets
Internet Gateway	Public internet routing
Security Groups	Access control for EC2 and RDS
Terraform	Full IaC provisioning

🚀 Deployment Guide

🧩 Step 1 — Deploy the infrastructure
terraform init
terraform apply


Terraform outputs:

ec2_public_ip = <your-ec2-ip>
rds_endpoint  = <your-rds-endpoint>

💻 Step 2 — Connect to EC2
ssh -i ~/.ssh/keyforminiproject.pem ec2-user@<ec2_public_ip>

🏗️ Step 3 — Install WordPress stack
sudo yum install -y httpd php mariadb105-server
sudo systemctl enable --now httpd mariadb

cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz

⚙️ Step 4 — Configure WordPress
cd wordpress
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php


Update with values from Terraform:

define( 'DB_NAME', 'assgdb' );
define( 'DB_USER', 'admin' );
define( 'DB_PASSWORD', '<your-rds-password>' );
define( 'DB_HOST', '<rds_endpoint>' );


Restart Apache:

sudo systemctl restart httpd


Open in browser:
👉 http://<ec2_public_ip>/wordpress

🧰 Tools & Technologies
Terraform • AWS • EC2 • RDS • VPC • S3 • NAT Gateway • Internet Gateway • Linux • Apache • MySQL • PHP • WordPress
