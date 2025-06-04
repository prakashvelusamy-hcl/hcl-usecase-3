# data "aws_security_group" "sg" {
#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.main.id]
#   }
#   filter {
#     name   = "group-name"
#     values = ["default"]
#   }
# }
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-http-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id 

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# locals {
#   user_data_files = [
#     file("${path.module}/userdata_1.sh"),
#     file("${path.module}/userdata_2.sh")
#   ]
# }


resource "aws_instance" "public_instances" {
  count         = var.public_instance
  ami           = "ami-0e35ddab05955cf57"
  instance_type = "t2.2xlarge"
  subnet_id     = var.public_subnet_ids[count.index]
  associate_public_ip_address = true
  security_groups = [aws_security_group.ec2_sg.id]
  # user_data = local.user_data_files[0]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              systemctl start docker
              systemctl enable docker
              sleep 10
              docker run -d -p 80:80 -e OPENPROJECT_SECRET_KEY_BASE=secret -e OPENPROJECT_HOST__NAME=0.0.0.0:80 -e OPENPROJECT_HTTPS=false openproject/community:12
              EOF

  tags = {
    Name = "Public-Instance-${count.index}"
  }
}

# docker run -it -p 8080:80 \
#   -e OPENPROJECT_SECRET_KEY_BASE=secret \
#   -e OPENPROJECT_HOST__NAME=3.110.179.134 \
#   -e OPENPROJECT_HTTPS=false \
#   -e OPENPROJECT_DEFAULT__LANGUAGE=en \
#   openproject/openproject:15




 resource "aws_security_group" "alb_sg" {
   name        = "alb_sg"
   description = "Allow HTTP inbound to ALB"
   vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
 }


resource "aws_lb" "alb" {
  name               = "usecase-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
 }


resource "aws_lb_target_group" "tg" {
   count    = 1
   name     = "tg-${count.index}"
   port     = 80
   protocol = "HTTP"
   vpc_id   = var.vpc_id
   target_type = "instance"

   health_check {
     path                = "/"
     protocol            = "HTTP"
     matcher             = "200"
     interval            = 30
     timeout             = 5
     healthy_threshold   = 2
     unhealthy_threshold = 2
   }
 }


 resource "aws_lb_target_group_attachment" "attach" {
   count            = 1
   target_group_arn = aws_lb_target_group.tg[count.index].arn
   target_id        = aws_instance.public_instances[count.index].id
   port             = 80
 }


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
}


# resource "aws_lb_listener_rule" "image" {
#   count=2
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 10

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg[1].arn
#   }

#   condition {
#     path_pattern {
#       values = ["/image/*"]
#     }
#   }
# }





