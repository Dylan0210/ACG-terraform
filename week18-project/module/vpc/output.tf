output "public1_id" {
  value = aws_subnet.public1.id
  name  = "public1"
}

output "public2_id" {
  value = aws_subnet.public2.id
  name  = "public2"
}

output "private1_id" {
  value = aws_subnet.private1.id
  name  = "private1"
}

output "private2_id" {
  value = aws_subnet.private2.id
  name  = "private2"
}

output "ami_id" {
  value = data.aws_ssm_parameter.ami.value
}
