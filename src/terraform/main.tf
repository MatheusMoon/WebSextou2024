# Define the provider
provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

# Create the security group for EC2 instances
resource "aws_security_group" "sg" {
  name        = "worker_sg"
  description = "Security group for worker EC2 instances"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the Elastic Load Balancer
resource "aws_elb" "lb" {
  name               = "lb"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    protocol          = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  security_groups = [aws_security_group.sg.id]
}

# Create EC2 instances
resource "aws_instance" "worker" {
  count = 5  # Creates 5 instances

  ami           = "ami-12345678"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name      = "my-key"  # Replace with your key name

  security_groups = [aws_security_group.sg.name]

  tags = {
    Name = "worker${count.index + 1}"
  }
}

# Create the RDS database
resource "aws_db_instance" "events" {
  identifier        = "events-db"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  username          = "admin"
  password          = "password"  # Replace with a secure password
  db_name           = "events"
  publicly_accessible = false
  skip_final_snapshot = true

  # Add other configuration parameters as needed
}

# Output the ELB DNS name
output "elb_dns_name" {
  value = aws_elb.lb.dns_name
}
