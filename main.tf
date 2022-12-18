
# VPC
resource "aws_vpc" "aws_ssrf_demo_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "aws_ssrf_demo"
  }
}

# subnet
resource "aws_subnet" "aws_ssrf_demo_public_subnet" {
  vpc_id                  = aws_vpc.aws_ssrf_demo_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = "aws_ssrf_demo_public"
  }
}

# internet_gateway
resource "aws_internet_gateway" "aws_ssrf_demo_internet_gateway" {
  vpc_id = aws_vpc.aws_ssrf_demo_vpc.id

  tags = {
    Name = "aws_ssrf_demo_igw"
  }

}