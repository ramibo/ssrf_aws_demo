
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

# route_table
resource "aws_route_table" "aws_ssrf_demo_route_table" {
  vpc_id = aws_vpc.aws_ssrf_demo_vpc.id

  tags = {
    Name = "aws_ssrf_demo_rt"

  }

}

#route
resource "aws_route" "aws_ssrf_demo_default_route" {
  route_table_id         = aws_route_table.aws_ssrf_demo_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws_ssrf_demo_internet_gateway.id
}

# route_table_association
resource "aws_route_table_association" "aws_ssrf_demo_public_association" {
  subnet_id      = aws_subnet.aws_ssrf_demo_public_subnet.id
  route_table_id = aws_route_table.aws_ssrf_demo_route_table.id

}

# security groups

resource "aws_security_group" "aws_ssrf_demo_security_group" {
  name        = "aws_ssrf_demo_sg"
  description = "ssrf demo securitygroup"
  vpc_id      = aws_vpc.aws_ssrf_demo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #To add instead of ingress above
  #   resource "aws_security_group_rule" "aws_ssrf_demo_web" {
  #   type              = "ingress"
  #   from_port         = 80
  #   to_port           = 443
  #   protocol          = "tcp"
  #   cidr_blocks       = ["0.0.0.0/0"]
  #   security_group_id = aws_security_group.aws_ssrf_demo_security_group.id
  # }

  # resource "aws_security_group_rule" "aws_ssrf_demo_ssh" {
  #   type              = "ingress"
  #   from_port         = 22
  #   to_port           = 22
  #   protocol          = "tcp"
  #   cidr_blocks       = ["0.0.0.0/0"]
  #   security_group_id = aws_security_group.aws_ssrf_demo_security_group.id
  # }

}

# key_pair
resource "aws_key_pair" "aws_ssrf_demo_key_pair" {
  key_name   = "aws_ssrf_demo_key"
  public_key = file("~/.ssh/aws_ssrf_demo_key.pub")
}

#================================================================================
#https://cloudkatha.com/how-to-attach-an-iam-role-to-ec2-instance-using-terraform/

# Create IAM policy with required permission
resource "aws_iam_policy" "aws_ssrf_demo_s3_policy" {
  name        = "S3_Bucket_Access_Policy"
  description = "Provides permission to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Create an IAM role for EC2 Instance
resource "aws_iam_role" "aws_ssrf_demo_iam_role" {
  name = "aws_ssrf_demo_iam_role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
  })
  tags = {
    tag-key = "aws_ssrf_demo_ir"
  }
}

# Attach the Policy to the created IAM role
resource "aws_iam_policy_attachment" "aws_ssrf_demo_attach" {
  name       = "aws_ssrf_demo_attach"
  roles      = [aws_iam_role.aws_ssrf_demo_iam_role.name]
  policy_arn = aws_iam_policy.aws_ssrf_demo_s3_policy.arn
}

# Create an instance profile using role

resource "aws_iam_instance_profile" "aws_ssrf_demo_instacne_profile" {
  name = "aws_ssrf_demo_instacne_profile"
  role = aws_iam_role.aws_ssrf_demo_iam_role.name
}


#================================================================================

# aws_instacne
resource "aws_instance" "aws_ssrf_demo_node" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true


  key_name               = aws_key_pair.aws_ssrf_demo_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.aws_ssrf_demo_security_group.id]
  subnet_id              = aws_subnet.aws_ssrf_demo_public_subnet.id
  user_data              = templatefile("userdata.tpl", {})

  # Attach the Instance Profile to EC2
  iam_instance_profile = aws_iam_instance_profile.aws_ssrf_demo_instacne_profile.name

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "aws_ssrf_demo_nd"
  }

  # metadata_options  {
  # }

  #Adding VScode remote connection-not for production !
  #To addsh connection to .ssh/config .
  #Need to run command: terraform apply -replace aws_instance.aws_ssrf_demo_node 
  provisioner "local-exec" {
    command = templatefile("ssh-config.tpl", { #tpl file is in unix format
      hostname = self.public_ip,
      user     = "ubuntu",
    identityfile = "~/.ssh/aws_ssrf_demo_key" })
    # interpreter = ["bash", "-c"] # linux default
  }

}

# aws s3 bucket

resource "aws_s3_bucket" "aws_ssrf_demo_s3_bucket" {
  bucket        = "aws-ssrf-demo-s3-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.aws_ssrf_demo_s3_bucket.id
  acl    = "private"
}

# Upload the secret file
resource "aws_s3_object" "aws_ssrf_demo_object" {
  bucket = aws_s3_bucket.aws_ssrf_demo_s3_bucket.id
  key    = "aws_ssrf_demo_data_file.json"
  source = "${path.module}/content/aws_ssrf_demo_data_file.json"
  etag   = filemd5("${path.module}/content/aws_ssrf_demo_data_file.json")
}

