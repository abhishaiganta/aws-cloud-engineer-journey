# Week 8: Infrastructure as Code (Terraform)

In Week 5 I built my VPC by clicking through the console wizard. This week I described the same kind of network in code instead (`main.tf`): a VPC called `training-vpc-tf` (`10.1.0.0/16`) with two public subnets and two private subnets across `us-east-1a` and `us-east-1b`, an internet gateway, and one NAT gateway. I used the community `terraform-aws-modules/vpc/aws` module, which creates all the pieces (subnets, route tables, routes, gateways) from a few lines of settings. The big difference from Week 5 is that the file is the source of truth. Anyone can read it, review changes to it in git, and rebuild the exact same network with one command.

## What plan, apply, and destroy do

- **`terraform init`** runs once per folder. It downloads the AWS provider and the VPC module so Terraform knows how to talk to AWS.
- **`terraform plan`** is a dry run. It compares what my code says should exist with what Terraform's state says already exists, then lists exactly what it would create, change, or delete. Nothing in AWS changes. This is the safety check, so I read every line before applying, especially anything marked to be destroyed or replaced.
- **`terraform apply`** shows the same plan again and, after I type `yes`, makes the real API calls to create or change resources until AWS matches the code. When it finishes, it saves what it built to the state file and prints my outputs (VPC ID and subnet IDs).
- **`terraform destroy`** is the opposite of apply. It uses the state file to find everything this configuration created and deletes all of it, in the right order. This is my cleanup step, and it's much safer than deleting things by hand because nothing gets missed (like a forgotten NAT gateway or Elastic IP still charging money).

## Why state matters

Terraform's state file (`terraform.tfstate`) is its memory. It records which real AWS resource (like `vpc-0abc...`) belongs to which block in my code. Without it, Terraform can't tell that the VPC already exists, so it would try to create a second one, and `destroy` wouldn't know what to delete. That's also why "drift" is a problem: if I delete or change a Terraform-managed resource in the console, the state no longer matches reality, and the next `plan` either fails or wants to recreate things. The fix is `terraform import` if the resource still exists, or `terraform state rm` if it's really gone, but the real lesson is to make every change to these resources through Terraform, not the console.

The state file can also contain sensitive values, so it must never be committed. My `.gitignore` already blocks `.terraform/` and `*.tfstate*`. On a team, state would live in a shared remote backend (like an S3 bucket with locking) so everyone works from the same copy.
