variable "rds_password" {
  description = "Password for MySQL RDS instance"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Home public IP for SSH/HTTP access"
  type        = string
}



variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}
