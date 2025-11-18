# 🚀 AWS Project 02 — WordPress Infrastructure using Terraform

This project demonstrates a full end-to-end deployment of a WordPress application on AWS using **Terraform**, following Infrastructure-as-Code (IaC) best practices.  
The architecture includes a production-style VPC, EC2 web server, RDS MySQL database in private subnets, and an optional S3 bucket for storage.

---

## 🌱 Overview

The goal of the project is to provision a fully functional WordPress environment on AWS:

- A secure and isolated **VPC**
- Public and private **subnets**
- **NAT Gateway** & **Internet Gateway**
- **EC2 instance** with Apache + PHP + WordPress
- Private **RDS MySQL** database (no public access)
- Optional **S3 bucket** for media/asset storage

Terraform manages all components — networking, compute, database, and security.

---

## 🏗️ Architecture

VPC (10.0.0.0/16)
│
├── Public Subnet (EC2 + WordPress)
│ └── EC2 Instance (Apache, PHP, WordPress)
│
├── Private Subnets
│ └── RDS MySQL (DB: assgdb, user: admin)
│
├── NAT Gateway
│ └── Provides outbound internet for private subnets
│
└── S3 Bucket (private, optional)




---

## ⚙️ Components

| Component | Description |
|----------|-------------|
| **VPC** | Custom AWS virtual network with DNS support |
| **EC2** | Apache web server running WordPress (Amazon Linux 2) |
| **RDS MySQL** | Managed MySQL 8.x in private subnets (not publicly accessible) |
| **S3 Bucket** | Private storage for WordPress media (optional) |
| **NAT Gateway** | Enables private subnets to reach the internet |
| **IGW** | Internet access for public resources |
| **Security Groups** | Inbound/outbound traffic rules |
| **Terraform** | Full IaC automation |

---

# 🚀 Deployment Guide

## 🧩 Step 1 — Deploy the infrastructure

```bash
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
Update values from Terraform:

define( 'DB_NAME', 'assgdb' );
define( 'DB_USER', 'admin' );
define( 'DB_PASSWORD', '<your-password>' );
define( 'DB_HOST', '<rds_endpoint>' );
Restart Apache:


sudo systemctl restart httpd
Open WordPress installer:

👉 http://<ec2_public_ip>/wordpress

🧰 Tools & Technologies
Terraform

AWS EC2, RDS, VPC, S3

NAT Gateway / IGW

Linux

Apache

MySQL

PHP

WordPress
