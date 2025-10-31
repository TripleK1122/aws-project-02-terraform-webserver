# 🚀 AWS Project 02 — WordPress Infrastructure using Terraform  

## 🌱 Overview  
Deploy a **WordPress web application** on **AWS** using **Terraform**.  
The project demonstrates Infrastructure as Code (IaC) principles with a complete AWS setup:  
**VPC**, **EC2**, **RDS (MySQL)**, **S3**, **NAT**, and **Security Groups**.

---

## 🏗️ Architecture  
VPC (10.0.0.0/16)
├── Public Subnet → EC2 (Apache + PHP + WordPress)
├── Private Subnets → RDS MySQL (assgdb)
├── NAT & Internet Gateway
└── S3 Bucket (private)

yaml


---

## ⚙️ Components  
| Service | Description |
|----------|-------------|
| **VPC** | Custom network with DNS support |
| **EC2** | Amazon Linux 2 + Apache + PHP + WordPress |
| **RDS** | MySQL 8.x in private subnet |
| **S3** | Private storage for WordPress assets |
| **NAT/IGW** | Enables Internet access |
| **Security Groups** | Controlled inbound/outbound traffic |

---

## 🚀 Deployment Guide  

### 🧩 Step 1: Deploy Infrastructure
```bash
terraform init
terraform apply
Outputs:


ec2_public_ip = <your-ec2-ip>
rds_endpoint  = <your-rds-endpoint>

💻 Step 2: Connect to EC2
ssh -i ~/.ssh/keyforminiproject.pem ec2-user@<ec2_public_ip>

🏗️ Step 3: Install WordPress Stack
sudo yum install -y httpd php mariadb105-server
sudo systemctl enable --now httpd mariadb
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz


⚙️ Step 4: Configure WordPress
cd wordpress
sudo cp wp-config-sample.php wp-config.php
sudo nano wp-config.php
Update database credentials:

PHP
define( 'DB_NAME', '-----' );
define( 'DB_USER', '----' );
define( 'DB_PASSWORD', '-----' );
define( 'DB_HOST', '<rds_endpoint>' );
Restart Apache:

sudo systemctl restart httpd
Then open in browser:
👉 http://<ec2_public_ip>/wordpress

🧰 Tools Used
Terraform • AWS • EC2 • RDS • S3 • VPC • Linux • MySQL • Apache

