---
layout: default
title: Day 1
nav_order: 2
has_children: true
permalink: /docs/day1/index.html
---

# What is Terraform?

Terraform is a very popular and robust Infrastructure as Code (IaC) tool. But what is IaC? 

IaC is a conceptual term meaning you deploy and provision your application's infrastructure by writing configuration files, commiting them to your version control repo, and running some tool on those files to actually perform the creation of resources. This makes it extremely easy to collaborate across a development team (because your architecture is stored as a file on version control) and automate (because you can trigger deployments based on pushes to version control repo). Additionally, you can create reusable chunks of infrastructure that applications can consume, which standardizes common patterns and reduces code duplication.

## Core features

#### Multi-cloud

You can deploy resources to any of the popular Cloud Providers (AWS, GCP, Azure, Alibaba, etc). If terraform doesn't support your Cloud Provider out of the box, you can even write your own "provider" to enable support.

#### Declarative

Not imperative. That means you don't need to know _how_ to create the resources. You don't need to execute a bunch of `create` commands to deploy resources. Similarly you don't need to execute a bunch of `change` commands to change a resource.

Instead, you just tell Terraform _what_ resources you want, and it will do all the creating, updating, or deleting for you.

#### Maintains the current state

In order to determine whether or not it needs to create, update, or delete a resource, Terraform needs to remember the state of the infrastructure. It stores the state file in a user-specified location. The next time you run Terraform, it compares your configuration files against the current state and decides what needs to change.

#### Generates an execution plan

Terraform will print out a human-readable "plan" that you can (and should) verify before actually deploying. This becomes particularly valuable when your resources are dependent on each other - e.g. you don't want to accidentally recreate a security group if it's in use because the `id` will change (AWS won't let you anyway).