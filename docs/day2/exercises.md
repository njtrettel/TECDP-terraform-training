---
layout: default
title: Exercises and Lab
nav_order: 4
parent: Day 2
permalink: /docs/day2/exercises.html
---

In this exercise and lab, we're going to create a simple app with an SNS topic that simply forwards its messages to SQS.

**In your terminal, navigate to `/exercises/dependencies`**

1. In the `main.tf`, replace all occurences of `YOUR_NAME` with your last name (or some other unique identifier).
1. Run `terraform init` to initialize terraform and the providers

## Creating Dynamic Terraform apps with variables

We're going to start by transforming our app into multiple environments. You'll notice our SNS topic and SQS queue names have `dev` hard-coded. We want to make this dynamic, so that we can just tell terraform to deploy to dev, prod, or wherever, and it uses the appropriate value.

<input type="checkbox" class="task-list-item-checkbox">Create a `_variables.tf` file and add a variable called `env` - [docs](https://www.terraform.io/docs/language/values/variables.html)

<details><summary>Not sure how?</summary>

Add a new file called `_varibles.tf`. Inside that file, add the variable block:

<pre>
variable "env" {
    type = string
    description = "the environment to deploy"
}
</pre>

Don't give it a `default`, because we want to force the environment to be passed explicitly.

</details>

Now our variable is defined, so terraform expects to see it. But we still need to actually provide the value. Recall that we can stick all of our variable values in a file ending in `.tfvars`, and then tell terraform to use that file during plan and apply. That's the best fit for our scenario because we always want to chose one file or the other, never both.

<input type="checkbox" class="task-list-item-checkbox">In a new directory called `config/`, add a `dev.tfvars` and `prod.tfvars` which provide values for the `env` variable

<details><summary>Not sure how?</summary>

Add two new files: `config/dev.tfvars` and `config/prod.tfvars`.

Inside of `dev.tfvars`, add:

<pre>
env = "dev"
</pre>

Likewise in `prod.tfvars`:

<pre>
env = "prod"
</pre>

</details>

The last thing we need to do is actually use that variable in our resource. In `main.tf`, you'll see that the SNS and SQS names have `-dev` hard-coded. We need to replace that with our variable. 

<input type="checkbox" class="task-list-item-checkbox">Replace the hard-coded `dev` with the `env` variable value

_**Hint**: You can use string "interpolation" in terraform like this: `"foo-${var.bar}"`_

<details><summary>Not sure how?</summary>

<pre>
resource "aws_sns_topic" "my_topic" {
    name = "YOUR_NAME-${var.env}"
}

resource "aws_sqs_queue" "my_queue" {
    name = "YOUR_NAME-${var.env}
}
</pre>

</details>

<input type="checkbox" class="task-list-item-checkbox">Run terraform `plan` and `apply` and ensure your resources are created correctly

## Creating outputs

You might imagine a scenario where we need the SNS topic ARN in a different app or account. For example, apps that utilize the CCOE Alarm Funnel require its SNS topic arn. It might be useful to print that out when terraform runs so we can easily verify it and copy it. Let's add an output to do just that.

<input type="checkbox" class="task-list-item-checkbox">Add an output for the SNS topic in a new file called `_outputs.tf`

<details><summary>Not sure how?</summary>

In <code>_outputs.tf</code>
<pre>
output "sns_topic_arn" {
    value = aws_sns_topic.my_topic.arn
}
</pre>

</details>

Now when we run terraform, we should see the output.

<input type="checkbox" class="task-list-item-checkbox">Run terraform `plan` and `apply` again and see the output value. You can also run `terraform output` and it will print them.

## Creating resource dependencies

Our app isn't quite done yet. So far, we only have the SNS topic and SQS queue, but nothing to connect them yet. To do that, we're going to need an [`aws_sns_topic_subscription`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) resource. For our super basic example, we only need to specify the required arguments.

We can use the outputs of our SNS and SQS resources inside of our `aws_sns_topic_subscription` resource instead of hard-coding some long ARN.

<input type="checkbox" class="task-list-item-checkbox">Create the `aws_sns_topic_subscription` resource and wire it up to the SQS queue

<details><summary>Not sure how?</summary>

<pre>
resource "aws_sns_topic_subscription" "my_subscription" {
    topic_arn = aws_sns_topic.my_topic.arn
    protocol = "sqs"
    endpoint = aws_sqs_queue.my_queue.arn
}
</pre>

</details>

Now we've told terraform to use the output values of the `aws_sns_topic` and `aws_sqs_queue` resources. That means terraform must know those values before it can create the `aws_sns_topic_subscription` resource. This is called a _dependency_.

When we run `terraform plan`, you'll see the values for the SNS topic subscription say `(known after apply)`. This is because terraform won't know those values until after the creation of those resources. Furthermore, you'll notice that terraform creates the SNS topic and SQS queue immediately, but it waits until those are done to create the subscription.

<input type="checkbox" class="task-list-item-checkbox">Run terraform `plan` and `apply` and notice the order in which the resources are created


### Lab

In the lab, we're going to extend our dependency example to something more useful.

Let's say our SQS queue already exists. The SQS queue is some centralized processing queue that several apps funnel messages into. In this scenario, we wouldn't be creating the SQS queue - the application that owns it would. So, we need to change our app so we _query_ for the existing SQS queue instead of creating our own.

In order to do this, we'll need to pretend like that SQS application is already in place. 

<input type="checkbox" class="task-list-item-checkbox">Remove your `aws_sqs_queue` resource
<input type="checkbox" class="task-list-item-checkbox">Manually create a dummy SQS queue in the AWS console
    - in your browser, go into your AWS console and navigate to SQS. Create a standard SQS queue and give it a unique name (**different than the name you gave your queue created via terraform**)

Now change the queue in the `aws_sns_topic_subscription` to be the value of the existing queue you just created manually

<input type="checkbox" class="task-list-item-checkbox">Replace your `aws_sqs_queue` resource with a data source and use it in the `aws_sns_topic_subscription`

<details><summary>Solution</summary>

<pre>
data "aws_sqs_queue" "my_existing_queue" {
    name = "WHATEVER_NAME_YOU_CHOSE"
}

resource "aws_sns_topic_subscription" "my_subscription" {
    topic_arn = aws_sns_topic.my_topic.arn
    protocol = "sqs"
    endpoint = data.aws_sqs_queue.my_existing_queue.arn
}
</pre>

</details>

Data sources are extremely useful when it comes to creating apps that can talk to each other. One very common example at Cigna is setting up "centralized logging". Instead of requiring consumers of the centralized logging to store the ARN of the centralized logging destination, we add an SSM parameter containing the ARN to every child account. Then, child accounts can use a terraform `data` source to query the SSM parameter and pull in that ARN.

### Bonus

The last thing we'll look at is how to process variables in terraform. We've already seen variables in terraform, but now we'll see how you can parse these variables in terraform to generate complex or reduced variables.

This is really where Terraform starts to shine. Most other IaC tools, notably CloudFormation, don't have much ability to add logic such as conditionals, for loops, etc. Terraform, however, does this very well by exposing some built in functions. Check out the docs for [functions](https://www.terraform.io/docs/language/functions/index.html). There are so many!

Let's explore these functions with `local` variables. In `main.tf`, create a local variable called `my_map` and set it to:

```
locals {
    my_map = {
        keyOne = "valueOne"
        keyTwo = "valueTwo"
    }
}
```

We haven't talked about this yet, but use the [`terraform console`](https://www.terraform.io/docs/cli/commands/console.html) CLI command to open an interactive terraform shell. In there, we can print out our local variable we just created. 

<details><summary>Not sure how?</summary>

<pre>
~$ terraform console
> local.my_map
{
  "keyOne" = "valueOne"
  "keyTwo" = "valueTwo"
}
</pre>

</details>

Now let's take that variable and parse it into a flat array of just the values. In this scenario, perhaps we have one resource which cares about the key, but another resource only cares about the value. Instead of creating one map variable and one array variable, we can just parse the map.

Use terraform functions to grab only the values of the local map variable and put it into a local array variable.

<details><summary>Not sure how?</summary>

<pre>
locals {
    my_map = {
        keyOne = "valueOne"
        keyTwo = "valueTwo"
    }
    my_list = values(local.my_map)
}
</pre>

Now print it:
<pre>
~$ terraform console
> local.my_list
[
  "valueOne",
  "valueTwo",
]
</pre>

</details>

Another common use case for `local` variables is creating a local tags variable that you can use when creating resources instead of specifying the tags every time. Typically, you might see some common tags like an app name or a Configuration Item, and then some environment-specific tags. You might combine them all into one local like so:

```
locals {
    tags = merge(var.common_tags, var.env_tags)
}
```