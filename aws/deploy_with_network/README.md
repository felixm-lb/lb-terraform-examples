---
Description: >-
    This code will enable you to deploy a Lightbits cluster in AWS via Cloud Formation along with a small EC2 instance for demo purposes.
---

# Deploy Lightbtis and all required resources in AWS using Terraform

This template uses the stack in the [documenation](https://www.lightbitslabs.com/techdoc/files/Lightbits_AWS_Guide.pdf) to deploy Lightbits for AWS.

For further reference about the AWS terraform, please look at the [AWS in Terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

This specific code will deploy:
* VPC
* Private subnet
* Public subnet
* IGW
* EC2 instance group for LB instances
* Lambdas needed for deploy/cleanup/maintenance

Extras:
* EC2 instance for demo/testing with cluster

## What you can change

To make this work for you, please change any of the input parameters inside the "variables.tf" file.

You will also need to add a "credentials" file in the "aws/" directory. The file should be in the form of:
```
[creds_name]
aws_access_key_id=
aws_secret_access_key=
aws_session_token=
```

For Lightbits, we can get the contents of this file through the login -> "Command line or programmatic access".
