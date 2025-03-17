

# 🚀 Deploying Secure EC2 Instances with a Shared RDS Database

<h3 align="center">
  <b>Secure AWS Infrastructure with Terraform 🛡️</b><br>
  <b>Scalable EC2 Instances ⚙️</b><br>
  <b>Shared RDS Database 💾</b><br>
  <b>Best Practices for Security and Scalability 🔒</b>
</h3>

This project demonstrates how to deploy **secure EC2 instances** connected to a **shared RDS database** on AWS using **Terraform**. The infrastructure includes a **Virtual Private Cloud (VPC)**, **Elastic Compute Cloud (EC2) instances**, and a **Relational Database Service (RDS) instance**, all configured with best practices for **security**, **scalability**, and **maintainability**.

---

## 📋 Table of Contents
- [Infrastructure Diagram](#-infrastructure-diagram)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Setup Instructions](#-setup-instructions)
- [Terraform Configuration](#-terraform-configuration)
  - [VPC Setup](#-vpc-setup)
  - [Subnets](#-subnets)
  - [Security Groups](#-security-groups)
  - [EC2 Instances](#-ec2-instances)
  - [RDS Database](#-rds-database)
- [Deploying the Infrastructure](#-deploying-the-infrastructure)
---

## 🖼️ Infrastructure Diagram

<div align="center">
  <img src="https://github.com/Mohamed0Mourad/Deploying_Secure_EC2_Instances_with_a-_Shared_RDS_Database/raw/main/infra.png" alt="Infrastructure Diagram" width="600" />
</div>

---

## ✨ Features

- **Secure VPC**: Isolated network environment with DNS support and hostnames enabled.
- **High Availability**: Subnets spread across multiple availability zones.
- **Web Traffic Security**: Security group allowing SSH, HTTP, HTTPS, and MySQL traffic.
- **Publicly Accessible RDS**: MySQL database accessible from the web servers.
- **Elastic IPs**: Public IPs assigned to EC2 instances for external access.
- **Automated Deployment**: Infrastructure as Code (IaC) using Terraform.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:
- **Terraform**: [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- **AWS CLI**: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- **AWS Account**: With necessary permissions to create EC2, RDS, and VPC resources.
- **SSH Key Pair**: Create a key pair for EC2 instance access.

---

## 🚀 Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Mohamed0Mourad/Deploying_Secure_EC2_Instances_with_a-_Shared_RDS_Database.git
   cd Deploying_Secure_EC2_Instances_with_a-_Shared_RDS_Database
   ```

2. **Configure AWS Credentials**:
   Replace the `access_key` and `secret_key` in `provider.tf` with your AWS credentials.

3. **Create an SSH Key Pair**:
   Generate an SSH key pair and save it to `/root/my-ec2-key.pem`:
   ```bash
   aws ec2 create-key-pair --key-name my-ec2-key --query 'KeyMaterial' --output text > /root/my-ec2-key.pem
   chmod 600 /root/my-ec2-key.pem
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Review the Execution Plan**:
   ```bash
   terraform plan
   ```

6. **Deploy the Infrastructure**:
   ```bash
   terraform apply
   ```

---

## 🧮 Terraform Configuration

### VPC Setup
A VPC named `AppVPC` is created with a CIDR block of `10.0.0.0/16`. DNS support and hostnames are enabled.

```hcl
resource "aws_vpc" "AppVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "AppVPC"
  }
}
```

### Subnets
Two subnets are created in different availability zones for high availability.

```hcl
resource "aws_subnet" "AppSubnet1" {
  vpc_id            = aws_vpc.AppVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "AppSubnet1"
  }
}

resource "aws_subnet" "AppSubnet2" {
  vpc_id            = aws_vpc.AppVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "AppSubnet2"
  }
}
```

### Security Groups
A security group named `WebTrafficSG` allows SSH, HTTP, HTTPS, and MySQL traffic.

```hcl
resource "aws_security_group" "WebTrafficSG" {
  vpc_id = aws_vpc.AppVPC.id
  name   = "WebTrafficSG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "WebTrafficSG"
  }
}
```

### EC2 Instances
Two EC2 instances are deployed, one in each subnet, using the `t2.micro` instance type.

```hcl
resource "aws_instance" "WebServer1" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.nw-interface1.id
    device_index         = 0
  }

  key_name = "my-ec2-key"

  tags = {
    Name = "WebServer1"
  }
}

resource "aws_instance" "WebServer2" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.nw-interface2.id
    device_index         = 0
  }

  key_name = "my-ec2-key"

  tags = {
    Name = "WebServer2"
  }
}
```

### RDS Database
A MySQL RDS instance is provisioned with 20 GB of storage and publicly accessible.

```hcl
resource "aws_db_instance" "app_database" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.micro"
  identifier             = "appdatabase"
  db_name                = "appdatabase"
  username               = "admin"
  password               = "db*pass123"
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.app_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.WebTrafficSG.id]

  tags = {
    Name = "AppDatabase"
  }
}
```

---

This README provides a comprehensive guide to your project, making it easy for users to understand and deploy the infrastructure. Let me know if you need further adjustments! 🚀
