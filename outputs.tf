output "aws_ssrf_demo_node_public_ip" {
  value = aws_instance.aws_ssrf_demo_node.public_ip
}

output "aws_ssrf_demo_node_public_dns" {
  value = aws_instance.aws_ssrf_demo_node.public_dns
}