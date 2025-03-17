
# 🚀 Deploying Secure EC2 Instances with a Shared RDS Database

This project demonstrates how to deploy **secure EC2 instances** connected to a **shared RDS database** on AWS using **Terraform**. We'll walk through setting up a **Virtual Private Cloud (VPC)**, **Elastic Compute Cloud (EC2) instances**, and a **Relational Database Service (RDS) instance**, while adhering to best practices for **security**, **scalability**, and **maintainability**.

---

## 📋 Table of Contents
- [Infrastructure Diagram](#-infrastructure-diagram)
- [Prerequisites](#-prerequisites)
- [Terraform Configuration](#-terraform-configuration)
  - [Provider Setup](#provider-setup)
  - [VPC Setup](#-vpc-setup)
  - [Subnets](#-subnets)
  - [Security Groups](#-security-groups)
  - [EC2 Instances](#-ec2-instances)
  - [RDS Database](#-rds-database)
- [Deploying the Infrastructure](#-deploying-your-infrastructure)

---

## 🖼️ Infrastructure Diagram

<div align="center">
  <img src="https://github.com/Mohamed0Mourad/Deploying_Secure_EC2_Instances_with_a-_Shared_RDS_Database/raw/main/infra.png" alt="Infrastructure Diagram" width="600" />
</div>

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:
- **Terraform**: [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- **AWS CLI**: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **AWS Account**: With necessary permissions to create EC2, RDS, and VPC resources.

---

## 🧮 Terraform Configuration

### Provider Setup
Define the AWS provider and region in your `main.tf` file:
```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

### 🧱 Building the Infrastructure

#### Virtual Private Cloud (VPC)
A VPC is a virtual network dedicated to your AWS account. It provides isolation and security for your resources.
```hcl
resource "aws_vpc" "app_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "AppVPC"
  }
}
```

#### Subnets
Create subnets in different availability zones for high availability.
```hcl
resource "aws_subnet" "app_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "AppSubnet1"
  }
}

resource "aws_subnet" "app_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "AppSubnet2"
  }
}
```

#### Security Groups
Security groups act as a virtual firewall to control inbound and outbound traffic.
```hcl
resource "aws_security_group" "app_sg" {
  name        = "app_security_group"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppSecurityGroup"
  }
}
```

#### Elastic Compute Cloud (EC2)
Deploy EC2 instances to host your web application.
```hcl
resource "aws_instance" "app_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.app_subnet_1.id
  security_groups = [aws_security_group.app_sg.name]

  tags = {
    Name = "AppInstance"
  }
}
```

#### Relational Database Service (RDS)
Set up an RDS instance for data persistence.
```hcl
resource "aws_db_instance" "app_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "appdb"
  username             = "admin"
  password             = "yourpassword"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.app_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "AppDBInstance"
  }
}
```

---

## 💥 Deploying Your Infrastructure

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the Execution Plan**:
   ```bash
   terraform plan
   ```

3. **Apply the Configuration**:
   ```bash
   terraform apply
   ```

---
