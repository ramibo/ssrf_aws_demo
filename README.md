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
* Clone this repo to the enviromet which you run terraform from :
```ShellSession
git clone https://github.com/ramibo/ssrf_aws_demo.git 
```

* Optional - In the following files ,set the paramters with your values :
**main.tf: `availability_zone` , `resource "aws_key_pair"{public_key}`
**providers.tf: `shared_config_files`,`shared_credentials_files` `profile` , `region`



## How to run this code

1. `cd` to the  `ssrf_aws_demo` directory.
2. Run `terraform init` command to prepare your working directory for next commands.
3. Run `terraform validate` command check whether the configuration is valid.
4. Run `terraform plan` command show changes required by the current configuration.
5. Run `terraform apply` / `terraform apply -auto-approve` to create / update the infrastructure at AWS

## Mitigation Steps

1. Enabling IMDS version 2 of the service

2. Fix the application by sanitize/validate all client-supplied input data.

3. dfgsd

## Refrences
* [FreeCodeCamp - Learn Terraform (and AWS) by Building a Dev Environment – Full Course for Beginners](https://www.youtube.com/watch?v=iRaai1IBlB0)
* [An SSRF, privileged AWS keys and the Capital One breach](https://blog.appsecco.com/an-ssrf-privileged-aws-keys-and-the-capital-one-breach-4c3c2cded3af)
* [How to hack AWS instances that have the metadata service (IMDSv1) enabled](https://alexanderhose.com/how-to-hack-aws-instances-with-the-metadata-service-enabled/)