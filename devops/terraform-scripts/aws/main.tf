provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
  version = "1.46"
}
# Create a vpc 
resource "aws_vpc" "default" {
    cidr_block            = "${var.aws_vpc_cidr}"
   #### this 2 true values are for use the internal vpc dns resolution
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags                 = "${var.tags}"
} 
# Creating Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id              = "${aws_vpc.default.id}"
  cidr_block          = "${var.aws_public_subnet_cidr}"
  availability_zone   = "ap-south-1a"
  tags                = "${var.tags}"
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"
   tags                = "${var.tags}"
}
# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}
#############################################################
resource "aws_instance" "nat" {
  ami = "ami-75ae8245" # this is a special ami preconfigured to do NAT
  availability_zone = "${element(var.availability_zones, 0)}"
  instance_type = "t2.small"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address = true
  source_dest_check = false
  tags {
      Name = "terraform_nat_instance"
  }
}

resource "aws_eip" "nat" {
  instance = "${aws_instance.nat.id}"
  vpc = true
}

##############################################################
# Creating Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id              = "${aws_vpc.default.id}"
  cidr_block          = "${var.aws_private_subnet_cidr}"
  availability_zone   = "ap-south-1a"
  tags                = "${var.tags}"
}

# Define the route table
resource "aws_route_table" "web-private-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}" 
  }

  tags {
    Name = "Private Subnet RT"
  }
}

# Assign the route table to the private Subnet
resource "aws_route_table_association" "web-private-rt" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_route_table.web-private-rt.id}"
}
##############################################################


##############################################################

# Define the security group for public subnet
resource "aws_security_group" "sg" {
  name = "vpc_test"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.aws_public_subnet_cidr}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags {
    Name = "Security Group SG"
  }
}

#Creating Ngnix Instance
resource "aws_instance" "nginx" {
   ami  = "${var.aws_ami}"
   instance_type = "t2.micro"
   key_name = "${var.aws_key_name}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sg.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   tags {
    Name = "Nginx"
  }
}
#Creating Node JS instance
resource "aws_instance" "nodejs" {
   ami  = "${var.aws_ami}"
   instance_type = "t2.micro"
   key_name = "${var.aws_key_name}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sg.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   tags {
    Name = "NodeJs"
  }
}
resource "aws_instance" "postgres" {
   ami  = "${var.aws_ami}"
   instance_type = "t2.micro"
   key_name = "${var.aws_key_name}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.sg.id}"]
   associate_public_ip_address = true
   source_dest_check = false
   tags {
    Name = "Postgres"
  }
}
resource "null_resource" "install_script" {
   provisioner "file" {
      source = "scripts/install_nginx.sh"
      destination = "/home/ubuntu/install_nginx.sh"

      connection {
         host = "${aws_instance.nginx.public_dns}"
         type = "ssh"
         user = "ubuntu"
         private_key = "${file("${var.pvtkey}")}"
         agent = false
      }
   }
   provisioner "file" {
      source = "scripts/install_nodejs.sh"
      destination = "/home/ubuntu/install_nodejs.sh"

      connection {
         host = "${aws_instance.nodejs.public_dns}"
         type = "ssh"
         user = "ubuntu"
         private_key = "${file("${var.pvtkey}")}"
         agent = false
      }
   }
   
   provisioner "file" {
      source = "scripts/install_postgres.sh"
      destination = "/home/ubuntu/install_postgres.sh"

      connection {
         host = "${aws_instance.postgres.public_dns}"
         type = "ssh"
         user = "ubuntu"
         private_key = "${file("${var.pvtkey}")}"
         agent = false
      }
   }
   provisioner "remote-exec" {
      connection {
         host = "${aws_instance.nginx.public_dns}"
         type = "ssh"
         user = "ubuntu"
         private_key = "${file("${var.pvtkey}")}"
         agent = false
      }

      inline = [
         "chmod +x /home/ubuntu/install_nginx.sh",
         "/home/ubuntu/install_nginx.sh"
      ]
   }
      provisioner "remote-exec" {
      connection {
         host = "${aws_instance.nodejs.public_dns}"
         type = "ssh"
         user = "ubuntu"
         private_key = "${file("${var.pvtkey}")}"
         agent = false
      }

      inline = [
         "chmod +x /home/ubuntu/install_nodejs.sh",
         "/home/ubuntu/install_nodejs.sh"
      ]
   }
      provisioner "remote-exec" {
      connection {
         host = "${aws_instance.postgres.public_dns}"
         type = "ssh"
         user = "ubuntu"
         private_key = "${file("${var.pvtkey}")}"
         agent = false
      }

      inline = [
         "chmod +x /home/ubuntu/install_postgres.sh",
         "/home/ubuntu/install_postgres.sh"
      ]
   }
}   