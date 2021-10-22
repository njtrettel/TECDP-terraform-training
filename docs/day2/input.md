---
layout: default
title: Input Variables
nav_order: 1
parent: Day 2
permalink: /docs/day2/input.html
---

# Input Variables

You may have noticed in the example on the Day 2 main page that we hard-coded a `vpc_id` in the arguments to the security group. This is really a terrible idea. What if we need to deploy our app to several environments? That VPC ID is going to change depending on which AWS account we deploy to, and we definitely don't want to update that value every time we deploy. This is where terraform variables come into play.

There are several reasons why you want to store your app configuration values in variables instead of hard-coding. One reason is that all your variables will be stored in one place (a file) and any developer can quickly glance and see all of them. The most valuable reason, however, is what I hinted at above: separating your environments.

## Variable Syntax

I think of terraform variables in 2 parts: the definition and the value. You first need to define all of your variables to tell terraform which to expect. Then, you have separate files per environment with a list of environment-specific values. Just like all of the other resources and blocks we've seen so far, the definitions can technically live in _any_ of your `.tf` files, but it's best practice to put them in a new file called `_variables.tf`:

```
variable "vpc_id" {
    type = string
    description = "the vpc id"
    default = ""
}
```

The values of the variables are treated a little differently though. Those live in a file ending in `.tfvars` (instead of just `.tf`), and they are just key-value pairs. It's common to see `.tfvars` files to live in a subdirectory inside of the terraform configuration with environment-specific names, like `dev.tfvars`:

```
vpc_id = "123456789"
something_else = {
    key_one = "value_one"
}
```

## Variable Usage

Terraform automatically looks for certain `.tfvars` files, but you can also specifiy them explicitly. If the same variable is specified in multiple ways, terraform takes the "last" value it sees, in this order:

- Environment variables
- A file called exactly `terraform.tfvars`
- Any file with the naming convention: `*.auto.tfvars`
- Any `-var` or `-var-file` CLI argument

In other words, you can load your variables automatically by putting them in a file called `terraform.tfvars` or `something.auto.tfvars`, or explicitly by passing the CLI a `-var` or `-var-file` argument. If your app has multiple environments, it makes the most sense to pass these variables in via the `-var-file`, like so:

```
terraform plan -var-file "config/dev.tfvars"
```

Now your variables are loaded into terraform, and you can use them in your resource configurations like so:

```
resource "aws_security_group" "my_sg" {
    vpc_id = var.vpc_id
    ...REDACTED...
}
```

## Local variables

Sometimes, you have some value that is used multiple times throughout your app, but you don't want to keep typing it out because it may be some long ID and you don't want to subject yourself to human errors. Or maybe you have two variables that you need to parse down into one complex variable. For these types of situations, you need a `local` variable. We'll see this more later, but in short it looks like this:

```
locals {
    my_local_variable = "something"
}

resource "aws_s3_bucket" "my_bucket" {
    bucket = local.my_local_variable
}
```