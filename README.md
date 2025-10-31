🚀 AWS Project 02 — WordPress Infrastructure using Terraform
🧠 Overview

This project deploys a WordPress web application on AWS using Terraform.
It demonstrates modern Infrastructure as Code (IaC) practices with a fully functional cloud setup including:

🏗️ VPC with public and private subnets

💻 EC2 instance (Apache + PHP + WordPress)

🗄️ RDS MySQL database (private subnet)

🌐 Internet Gateway and NAT Gateway

☁️ S3 Bucket for object storage

🔐 Security Groups for controlled access

🧱 Architecture Diagram
                ┌────────────────────────────────────────────┐
                │                 AWS VPC                    │
                │                 10.0.0.0/16                │
                │                                            │
                │  ┌────────────────────────┐  ┌──────────┐  │
Internet  ─────▶│  Public Subnet 10.0.0.0/20│  │ NAT GW   │  │
                │   EC2 (Apache, PHP, WP)    │  │          │  │
                │   SG: HTTP + SSH (from IP) │  │          │  │
                │  └────────────────────────┘  └──────────┘  │
                │                                            │
                │  ┌────────────────────────┐                │
                │  Private Subnets          │                │
                │  RDS MySQL (assgdb)       │                │
                │  SG: allow from EC2 only  │                │
                │  └────────────────────────┘                │
                │                                            │
                │  S3 Bucket (private access)                │
                └────────────────────────────────────────────┘

⚙️ Components
Service	Description
VPC	Custom VPC with CIDR 10.0.0.0/16
Subnets	1 public (EC2) + 2 private (RDS)
EC2	Amazon Linux 2, Apache, PHP, WordPress
RDS	MySQL db.t3.micro, private subnet
S3	Private bucket for backups or media
IGW/NAT	Internet + outbound access
Security Groups	Restrictive inbound rules, open egress
🧩 Project Structure
aws-project-02-terraform-webserver/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars      # not committed
├── .gitignore
└── README.md

🚀 Deployment Steps
1️⃣ Initialize Terraform
terraform init

2️⃣ Review the Plan
terraform plan

3️⃣ Apply Configuration
terraform apply

4️⃣ Outputs

After apply, Terraform will output:

ec2_public_ip = <your EC2 public IP>
rds_endpoint  = <your RDS endpoint>

🌐 Configure WordPress on EC2
ssh -i ~/.ssh/keyforminiproject.pem ec2-user@<ec2_public_ip>
sudo yum install -y httpd php mariadb105-server
sudo systemctl enable --now httpd mariadb


Download and set up WordPress:

cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php
sudo nano wordpress/wp-config.php


Update with your RDS info:

define( 'DB_NAME', 'assgdb' );
define( 'DB_USER', 'admin' );
define( 'DB_PASSWORD', 'Kos123321' );
define( 'DB_HOST', '<rds_endpoint>' );


Restart Apache:

sudo systemctl restart httpd


Visit in browser:

http://<ec2_public_ip>/wordpress

🛠️ Variables
Variable	Description
rds_password	RDS Master password (sensitive)
my_ip	Your public IP (e.g. 73.247.13.42/32)
key_name	AWS key pair name for EC2

Example (terraform.tfvars):

rds_password = "MySecurePass123!"
my_ip        = "73.247.13.42/32"
key_name     = "keyforminiproject"

🧰 Tools & Technologies

🧱 Terraform v1.x

☁️ AWS (VPC, EC2, RDS, S3)

💻 Amazon Linux 2

🐘 PHP & Apache

🗄️ MySQL 8.0

🔒 IAM, Security Groups

🧩 Lessons Learned

CIDR conflicts cause subnet creation errors.

RDS engine versions must exist in AWS region.

"Error establishing a database connection" = wrong DB name or privileges.

Use nmap-ncat to test RDS connectivity from EC2.

Always hide credentials with .tfvars and .gitignore.
