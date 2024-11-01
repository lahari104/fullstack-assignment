resource "aws_vpc" "tf_vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    "Name" = "vpc"
  }
}

resource "aws_subnet" "tf_subnet" {
  availability_zone = "us-east-1a"
  cidr_block        = "192.168.0.0/24"
  vpc_id            = aws_vpc.tf_vpc.id
  tags = {
    "Name" = "subnet"
  }
}


resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    "Name" = "igw"
  }
}


resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    "Name" = "route_table"
  }
}

resource "aws_route" "tf_route" {
  route_table_id         = aws_route_table.tf_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_igw.id
}

resource "aws_route_table_association" "tf_rt_ass" {
  route_table_id = aws_route_table.tf_rt.id
  subnet_id      = aws_subnet.tf_subnet.id
}


resource "aws_security_group" "tf_security" {
  description = "alltcp"
  name        = "security"
  tags = {
    "Name" = "security group"
  }
  vpc_id = aws_vpc.tf_vpc.id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}


resource "aws_instance" "soul_instance" {
  ami                         = "ami-0557a15b87f6559cf"
  associate_public_ip_address = true
  availability_zone           = "us-east-1a"
  instance_type               = "t2.medium"
  key_name                    = "Lahari"
  security_groups             = [aws_security_group.tf_security.id]
  subnet_id                   = aws_subnet.tf_subnet.id
  tags = {
    "Name" = "ec2"
  }
}

resource "null_resource" "shell" {
    triggers = {
      "Name" = 1.0
    }
    provisioner "remote-exec" {
      connection {
        type = "ssh"
        user = "ubuntu"
        host = aws_instance.soul_instance.public_ip
        private_key = file("~/.ssh/id_rsa")
      }
      inline = [
        "sudo apt update",
        "curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
        "git clone https://github.com/soulpage/fullstack-assignment.git",
        "cd fullstack-assignment/frontend/",
        "sudo apt install -y nodejs",
        "npm install",
        "npm run build",
        "cd ..",
        "cd backend",
        "sudo apt install -y python3 python3-pip python3-venv",
        "sudo apt install -y pkg-config libmysqlclient-dev",
        "python3 -m venv venv",
        "source venv/bin/activate",
        "pip3 install -r requirements.txt",
        "pip3 install virtualenv",
        "pip3 install django mysqlclient",
        "pip3 install python-dotenv",
        "cp .env.example .env",
        "pip3 install python-decouple django-cors-headers djangorestframework django-nested-admin openai",
        "python3 manage.py migrate"
      ]    
    }
    depends_on = [
      aws_instance.soul_instance
    ]
    
}