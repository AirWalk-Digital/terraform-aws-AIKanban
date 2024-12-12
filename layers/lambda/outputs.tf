output "student_api_key" {
  value     = aws_api_gateway_api_key.student_key
  sensitive = true
}
