# ---------- VPC ----------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "Assg-VPC" }
}

# ---------- Subnets ----------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "Assg-Public" }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.48.0/20"
  availability_zone = "us-east-1a"
  tags              = { Name = "Assg-Private-1a" }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/20"
  availability_zone = "us-east-1b"
  tags              = { Name = "Assg-Private-1b" }
}

# ---------- Internet Gateway & NAT ----------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Assg-IGW" }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.nat_eip.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "Assg-NAT" }
}

# ---------- Route Tables ----------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "Public-RT" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "Private-RT" }
}

resource "aws_route_table_association" "private_1a_assoc" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_1b_assoc" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private.id
}

# ---------- Security Groups ----------
## EC2 Public Instance SG
resource "aws_security_group" "public_instance_sg" {
  name        = "public-instance-sg"
  description = "Allow HTTP and MySQL outbound to RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from my IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "public-instance-sg" }
}

## RDS SG (принимает только от EC2)
resource "aws_security_group" "assg_rds_mysql_sg" {
  name        = "assg-rds-mysql-sg"
  description = "Allow MySQL from EC2 SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL/Aurora from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "assg-rds-mysql-sg" }
}

# ---------- EC2 ----------
resource "aws_instance" "web" {
  ami                         = "ami-0c101f26f147fa7fd" # Amazon Linux 2
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_instance_sg.id]
  associate_public_ip_address = true
  key_name                    = "keyforminiproject"

  tags = { Name = "Assg-EC2" }
}

# ---------- RDS Subnet Group ----------
resource "aws_db_subnet_group" "assg_db_sg" {
  name        = "assg-db-sg"
  description = "Subnet group for MYSQL"
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id
  ]

  tags = { Name = "assg-db-sg" }
}

# ---------- Discover latest supported MySQL version ----------
data "aws_rds_engine_version" "mysql_latest" {
  engine = "mysql"
}

# ---------- RDS MySQL ----------
resource "aws_db_instance" "assg_mysql" {
  identifier                 = "database-1"
  engine                     = "mysql"
  engine_version             = data.aws_rds_engine_version.mysql_latest.version
  instance_class             = "db.t3.micro"
  allocated_storage          = 20
  max_allocated_storage      = 1000
  storage_type               = "gp2"
  username                   = "admin"
  password                   = var.rds_password
  db_name                    = "assgdb"
  port                       = 3306
  multi_az                   = false
  publicly_accessible        = false
  db_subnet_group_name       = aws_db_subnet_group.assg_db_sg.name
  vpc_security_group_ids     = [aws_security_group.assg_rds_mysql_sg.id]
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  deletion_protection        = false
  backup_retention_period    = 1
  storage_encrypted          = false

  tags = {
    Name = "Assg-RDS-MySQL"
    Env  = "Dev"
  }
}

# ---------- OUTPUTS ----------
output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.assg_mysql.address
}

# ---------- S3 Bucket ----------
resource "aws_s3_bucket" "assg_bucket" {
  bucket = "assg-bucket-kostya-miniproject"
  tags = {
    Name = "assg-bucket-kostya-miniproject"
    Env  = "Dev"
  }
}

# ---------- Block Public Access ----------
resource "aws_s3_bucket_public_access_block" "assg_bucket_block" {
  bucket = aws_s3_bucket.assg_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------- Ownership Control ----------
resource "aws_s3_bucket_ownership_controls" "assg_bucket_ownership" {
  bucket = aws_s3_bucket.assg_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
