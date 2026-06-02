# ALB security group (allow HTTP from anywhere)
resource "aws_security_group" "alb_sg" {
    name = "${var.project_name}-alb-sg"
    description = "Security group for Application Load Balancer"
    vpc_id = aws_vpc.main.id.id

    ingress {
        description = "Allow HTTP anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-alb-sg"
    }
}

# ALB resource
resource "aws_lb" "main" {
    name = "${var.project_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    tags = {
        Name = "${var.project_name}-alb"
    }
}

# Target group for Flask API
resource "aws_lb_target_group" "flask" {
    name = "${var.project_name}-flask-tg"
    port = 5000
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id

    health_check {
        path = "/health"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
        matcher = "200"
    }
}

# Target group attachment for (EC2 instance)
resource "aws_lb_target_group_attachment" "flask" {
    target_group_arn = aws_lb_target_group.flask.arn
    target_id = aws_instance.cloudguard_server.id
    port = 5000
}

# Listener (HTTP 80 -> target group)
resource "aws_lb_listener" "http" {
   load_balancer_arn = aws_lb.main.arn
   port = "80"
   protocol = "HTTP"

   default_action {
       type = "forward"
       target_group_arn = aws_lb_target_group.flask.arn
   } 
}