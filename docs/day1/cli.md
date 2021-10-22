---
layout: default
title: CLI Overview
nav_order: 2
parent: Day 1
permalink: /docs/day1/cli.html
---

# CLI Overview

After you've created some terraform configuration files, you'll need to use the Terraform CLI to actually deploy the resources.

## Basic CLI Commands

We'll talk about more advanced CLI commands later

### `terraform init`

This initializes the terraform configuration. It creates the `.terraform/` folder that stores files used by terraform. It also downloads any "providers" that you've specified. See the section at the bottom for more info on providers.

### `terraform plan`

This compares any changes you've made to the configuration files against current state to determine what should change. Terraform outputs a human-readable plan that you can verify before actually making changes.

### `terraform apply`

The apply command will first run a plan again just to be extra certain you want to actually make these changes. Then it asks for approval before making them. You could bypass the additional plan step and approval process by passing in some command line arguments.

### `terraform destroy`

This destroys any resources currently in the terraform state.

## Providers

Since the terraform CLI is responsible for creating, modifying, and deleting resources, it needs to know how to talk to your chosen cloud provider. To do this, terrafom creates cloud-specific "providers", and makes them available for download separately from the CLI itself. When you run `init` for the first time, terraform will detect which providers it needs and then download them.

Now is a good time to explore some documentation. The overall terraform docs describe the configuration files syntax and how to use the CLI, and the "registry" docs contain provider-specific information like creating resources.

Terraform docs: [https://www.terraform.io/docs/language/](https://www.terraform.io/docs/language/) <br>
Terraform provider docs (registry): [https://registry.terraform.io/browse/providers](https://registry.terraform.io/browse/providers)