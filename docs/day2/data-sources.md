---
layout: default
title: Data Sources
nav_order: 3
parent: Day 2
permalink: /docs/day2/data-sources.html
---

# Data Sources

Input varibles and resource outputs are two ways we can dynamically generate resources based on other resources. We'll take a look at one more way to dynamically generate resources that doesn't require storing any variables and ensuring their values are correct: [`data` sources](https://www.terraform.io/docs/language/data-sources/index.html).

Data sources allow you to query existing resources and use their values in your resource configuration. For example, instead of specifying a VPC ID in your variables, which would require manually grabbing the ID and storing it in your `.tfvars` file, you can query for the VPC in AWS and pull the ID from that queried resource. Another way to think of terraform data sources is that you are "importing" the resource into your terraform configuration. The word "import" is reserved for an entirely separate concept though, so I avoid that word.

## Data source syntax

The syntax is just like resource blocks:

```
data "TYPE" "NAME" {
    ARGUMENT = EXPRESSION
}
```

The arguments provided depend on which resource you are querying. Let's stick with the VPC example:

```
data "aws_vpc" "my_vpc" {
    filter {
        name = "tag:Name"
        value = "MyVPCName"
    }
}

resource "aws_security_group" "my_sg" {
    vpc_id = data.aws_vpc.my_vpc.id
    ...REDACTED...
}
```

Now, we don't need to store the ID of the VPC in our variables. We just need to know the name.

It's important to note that the `data` source is not _creating_ any resources. It just queries an existing resource and makes its outputs available to the rest of the resources.