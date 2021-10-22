---
layout: default
title: Day 2
nav_order: 3
has_children: true
permalink: /docs/day2/index.html
---

# Terraform Variables and Dependencies

Today's training is going to introduce a new concept in terraform: dependencies. Up to this point, we've created an S3 bucket with static values as the arguments we pass. This is very basic, and more complex apps will use, for example, the result of resource A as a value for an argument to resource B.

In order to do this, terraform creates a dependency graph. If resource B requires the result of creating resource A, then terraform will know to create resource A first and only then will it create resource B. Let's see a real example.

You might have an AWS Lambda function running inside a VPC. To do this, you must pass an AWS Security Group ID (and subnet IDs) to the lambda. We can create that security group in the same terraform configuration, and then tell the lambda to wait until that security group is created. It's pretty intuitive, and terraform is able to recognize the dependency automatically:

```
resource "aws_security_group" "my_sg" {
    name = "some-lambda-security-group"
    vpc_id = "123456789"
    ...REDACTED...
}

resource "aws_lambda_function" "my_function" {
    ...REDACTED...
    vpc_config {
        security_group_ids = [aws_security_group.my_sg.id]
    }
}
```

We'll take a look at exactly how this is working, but first let's pause to look at Terraform Variables and Outputs.