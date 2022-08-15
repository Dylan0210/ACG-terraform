## public ip of ec2 instance in public1 subnet
output "public_ip" {
  value = aws_instance.webserver1.public_ip
}

## DNS for the application load balancer
output "lb_dns_name" {
  value = aws_lb.my_alb.dns_name
}

## instance address for DB
output "db_instance_address" {
  value = aws_db_instance.database.address
}
