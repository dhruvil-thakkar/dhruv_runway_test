output lb_dns_name {
    description = "DNS name of the LB"
    value = aws_lb.web_elb.dns_name
}