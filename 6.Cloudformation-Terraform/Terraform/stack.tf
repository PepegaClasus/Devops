provider "aws" {
  region  = "us-west-1"
}


#VPC
resource "aws_vpc" "vpc_terraform" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block = "10.0.0.0/16"
}


#Internet Gateaway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc_terraform.id
}


#Elastic Ip1
resource "aws_eip" "nat_eip1" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}



#Private NAT Gateaway
resource "aws_nat_gateway" "privateNAT" {
  allocation_id = aws_eip.nat_eip1.id
  connectivity_type = "private"
  subnet_id = aws_subnet.private_subnet1.id
}


#Public Subnet1
resource "aws_subnet" "public_subnet1" {
  vpc_id     = aws_vpc.vpc_terraform.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1b"
}
#Public Subnet2
resource "aws_subnet" "public_subnet2" {
  vpc_id     = aws_vpc.vpc_terraform.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-1c"
}
#Private Subnet2
resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.vpc_terraform.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-1c"
}


#Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_terraform.id
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_terraform.id
}


#Public Route
resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
}


#Private Route
resource "aws_route" "private_nat_gateway" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.privateNAT.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = "${aws_route_table.private_route_table.id}"
}


#Security group
resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_terraform.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["37.214.61.132/32"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["37.214.61.132/32"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["37.214.61.132/32"]
  }

  ingress {
    from_port        = 11211
    to_port          = 11211
    protocol         = "tcp"
    cidr_blocks      = ["37.214.61.132/32"]
  }

  ingress{
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = ["37.214.61.132/32"]
  }

  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["37.214.61.132/32"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }


}


#Instance 1
resource "aws_instance" "Ter_instance1"{
  ami = "ami-0a8a24772b8f01294"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet1.id
  security_groups = [aws_security_group.web-sg.id]
  key_name = "RSA_KEY"
}
#Instance 2
resource "aws_instance" "Ter_instance2"{
  ami = "ami-0a8a24772b8f01294"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet2.id
  security_groups = [aws_security_group.web-sg.id]
  key_name = "RSA_KEY"
}


#Elastic Load Balancer
resource "aws_elb" "bar" {
  name  = "foobar-terraform-elb"
  subnets = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 5
  }

  instances                   = [aws_instance.Ter_instance1.id, aws_instance.Ter_instance2.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }

  security_groups = [aws_security_group.web-sg.id]
}



#Subnet Group
resource "aws_db_subnet_group" "subnet_group" {
  name = "subnet_group"
  subnet_ids = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}


#RDS
resource "aws_db_instance" "my_rds" {
allocated_storage    = 20
engine               = "postgres"
engine_version       = "14.1"
instance_class       = "db.t3.micro"
name                 = "mydb"
username             = "vladimir"
password             = "vladimir"
skip_final_snapshot  = true
db_subnet_group_name = aws_db_subnet_group.subnet_group.name
}

resource "aws_elasticache_subnet_group" "elasti_cache_group" {
name       = "cache-subnet-group"
subnet_ids = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

#ElastiCacheRedis
resource "aws_elasticache_cluster" "redis" {
  cluster_id = "cluster-redis"
  engine = "redis"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  port = 6379
  subnet_group_name = aws_elasticache_subnet_group.elasti_cache_group.name
  security_group_ids = [aws_security_group.web-sg.id]
}
#ElastiCacheMemcached
resource "aws_elasticache_cluster" "memcached" {
  cluster_id = "cluster-memcached"
  engine = "memcached"
  node_type = "cache.t2.micro"
  num_cache_nodes = 2
  engine_version = "1.6.6"
  port = 11211
  security_group_ids = [aws_security_group.web-sg.id]
  subnet_group_name = aws_elasticache_subnet_group.elasti_cache_group.name
}


