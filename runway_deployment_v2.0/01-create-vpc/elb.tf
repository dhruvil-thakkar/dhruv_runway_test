resource "aws_lb" "web_elb" {
  name               = "web-lb"
  load_balancer_type = "application"
  security_groups = [
    "${aws_security_group.web_sg.id}"
  ]
  subnets = [
    "${aws_subnet.useast1a_subnet.id}",
    "${aws_subnet.useast1b_subnet.id}",
    "${aws_subnet.useast1c_subnet.id}"
  ]
  # cross_zone_load_balancing   = true
  # health_check {
  #     healthy_threshold = 2
  #     unhealthy_threshold = 2
  #     timeout = 3
  #     interval = 30
  #     target = "HTTP:80/"
  #   }
  # listener {
  #     lb_port = 80
  #     lb_protocol = "http"
  #     instance_port = "80"
  #     instance_protocol = "http"
  #   }
}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-"
  image_id = "ami-0ba879fad570aff9d" 
  #image_id = "ami-05c13eab67c5d8861"
  #image_id      = "ami-0e8a34246278c21e4"
  instance_type = "t2.micro"
  # key_name = "tests"
  security_groups             = ["${aws_security_group.web_sg.id}"]
  associate_public_ip_address = true
  user_data                   = <<EOF
  #cloud-boothook
  #!/bin/bash 
  # yum install nginx -y
  echo "<h1>$(hostname)</h1>" >  /usr/share/nginx/html/index.html 
  # systemctl enable nginx
  # systemctl start nginx
  EOF

  #"${file("data.sh")}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1
  vpc_zone_identifier = ["${aws_subnet.useast1a_subnet.id}",
    "${aws_subnet.useast1b_subnet.id}",
  "${aws_subnet.useast1c_subnet.id}"] # Specify your subnet IDs

  launch_configuration = aws_launch_configuration.web.id

  health_check_type         = "EC2"
  health_check_grace_period = 300
}

resource "aws_lb_target_group" "example" {
  name        = "example-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dhruv_test_vpc.id # Specify your VPC ID
}

resource "aws_autoscaling_attachment" "example" {
  alb_target_group_arn   = aws_lb_target_group.example.arn
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.web_elb.arn #aws_elb.web_elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}