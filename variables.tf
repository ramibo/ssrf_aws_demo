variable "availability_zone" {
  type    = string
  default = "us-east-2a"
}

variable "key_name" {
  type    = string
  default = "aws_ssrf_demo_key"
}

variable "public_key" {
  type    = string
  default = "aws_ssrf_demo_key.pub"
}