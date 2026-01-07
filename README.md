# Terraform AWS Infrastructure Migration

This project documents my process of **adopting an existing AWS application into Terraform** instead of rebuilding it from scratch.

The goal is to safely migrate real, working infrastructure into Infrastructure as Code (IaC) without downtime or duplicate resources.

---

## What this project covers

- Imported an existing AWS Lambda function into Terraform state
- Imported the existing IAM execution role used by the Lambda
- Rewired the Lambda to reference the imported role via Terraform
- Validated that no resources were recreated or destroyed
- Set up Terraform to manage future changes safely

This work focuses on **migration and state management**, not greenfield infrastructure.

---

## Why this matters

Most Terraform tutorials start with:
> “Create a new VPC / Lambda / S3 bucket”

In real environments, infrastructure already exists.

This project focuses on:
- Terraform state
- `terraform import`
- avoiding duplicate resources
- not breaking production systems

---

## Current status

- Core AWS Lambda + IAM role successfully adopted into Terraform
- Terraform configuration validated and version-controlled
- Sensitive files (state, artifacts) excluded from Git

---

## Next steps

- Import and manage IAM policies
- Migrate S3 static site resources
- Introduce Terraform-driven CI/CD

---

## Notes

This repo represents an **in-progress migration**, not a finished platform.
