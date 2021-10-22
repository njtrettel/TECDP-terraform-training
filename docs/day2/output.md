---
layout: default
title: Output Values
nav_order: 2
parent: Day 2
permalink: /docs/day2/output.html
---

# Output Values

In addition to input variables that you provide to dynamically create resources, you can also specify outputs. 

Every resource created by terraform has at least one output value. In the terraform docs, these are listed as "attributes" - see the attributes for the [`aws_lambda_function`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#attributes-reference) resource. All of these attributes are usable by other resources, like we saw in the Day 2 main page example. Sticking with the lambda example, you could grab the `arn` from the lambda resource terraform creates and use that output in a different resource:

```
resource "aws_lambda_function" "my_function" {
    ...REDACTED...
}

resource "aws_sns_topic_subscription" "my_sub" {
    protocol = "lambda"
    endpoint = aws_lambda_function.my_function.arn
    ...REDACTED...
}
```

## User-defined Outputs

You can't modify the outputs of each resource. But, you can specify outputs at the application level. This isn't super useful to us yet, but it will be when we get to Terraform Modules.

The outputs can live in any `.tf` file, but it's best practice to put them in a file called `_outputs.tf`. In short, it looks like this:

```
output "lambda_arn" {
    value = aws_lambda_function.my_function.arn
}
```

Now, when you run terraform, it will print out the `lambda_arn` output variable. You might do this if you need to manually get a list of IDs or ARNs after running terraform to use somewhere else (so you don't need to go into the console). Or maybe you just want to print it out to debug.