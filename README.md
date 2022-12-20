# SSRF vulnerablity demo
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

## Demo diagram 
![Diagram]()

## Purpose
Demonstrating a Server Side Request Forgery (SSRF) attack in AWS environment , similar to the [CapitalOne breach](https://www.capitalone.com/digital/facts2019/).
The environment will be deployed with Terraform IaC module.



## Prerequisites
* Active AWS account
* AWS IAM user with AWS credential type: ["Access key - Programmatic access"](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) and [AdministratorAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

*  [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli)

* update main.tf with : region , key-pair , instacne profile
* update providers.tf with profile , region




##Providers version
```
Terraform v1.0.1
```

## How to run this code

- Clone this repo to the enviromet which you run terraform from.
- cd to the the directory secure-s3-deployment
- use terraform __init__ command prepare your working directory for other commands
- terraform __validate__ command check whether the configuration is valid
- terraform __plan__ command show changes required by the current configuration
- terraform __apply__ create or update infrastructure
- Alternate command : terraform apply -auto-approve
- terraform __destroy__ destroy previously-created infrastructure
- Alternate command : terraform destroy -auto-approve
- terraform __fmt__ reformat your configuration in the standard style

- Update the unique bucket name in the __variable.tf__ file

```

bucket_name = "unique-backet-name"
target_bucket = "unique-backet-name"

```

## Mitigation Steps

1. Enabling IMDS version 2 of the service

2. Fix the application by sanitize/validate all client-supplied input data.

3. dfgsd

## Refrences
* [FreeCodeCamp - Learn Terraform (and AWS) by Building a Dev Environment – Full Course for Beginners](https://www.youtube.com/watch?v=iRaai1IBlB0)
* [An SSRF, privileged AWS keys and the Capital One breach](https://blog.appsecco.com/an-ssrf-privileged-aws-keys-and-the-capital-one-breach-4c3c2cded3af)
* [How to hack AWS instances that have the metadata service (IMDSv1) enabled](https://alexanderhose.com/how-to-hack-aws-instances-with-the-metadata-service-enabled/)