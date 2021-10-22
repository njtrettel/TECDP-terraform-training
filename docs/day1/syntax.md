---
layout: default
title: Syntax
nav_order: 1
parent: Day 1
permalink: /docs/day1/syntax.html
---

# Syntax overview

### File structure

Terraform requires all of your configuration files to be in one directory. When you run Terraform commands, it looks at all files in that directory that end in `.tf`. It does not include sub-directories. In this example, if you run terraform from the `my-app/` directory, only `iam.tf` and `s3.tf` will be used:

```
> my-app/
    - iam.tf
    - s3.tf
    > subdir/
        - sns.tf
        - sqs.tf
```

### File contents

The language for terraform files is called `HCL`. You could also write it in `JSON`, but that's not very common.

You express items in the terraform files with _blocks_. Each block is denoted with curly braces (`{}`), and has a few labels in front of it. The main _block types_ we'll be concerned with are: `resource`, `data`, `variable`, and `module`.

They're declared like this:

```
<BLOCK_TYPE> "<BLOCK_LABEL>" "<BLOCK_NAME>" {
    <IDENTIFIER> = <EXPRESSION>
}
```

And here's some examples:

```hcl
resource "aws_sns_topic" "my_topic" {
    name = "this-is-my-sns-topic"
}

data "aws_ssm_parameter" "imported_ssm_param" {
    name = "param-that-already-exists"
}
```


We'll also see some blocks that don't conform to this syntax, such as `local` variables, the `terraform` block, and the `provider` block.