# Terraform AWS Infrastructure Migration

This project documents the process of **adopting a live, full-stack serverless application into Terraform** instead of rebuilding it from scratch.

The goal was to safely migrate real, working infrastructure into Infrastructure as Code (IaC) without downtime, data loss, or accidental resource recreation.

## Architecture

The final infrastructure is a fully serverless, event-driven web application managed 100% by Terraform.

**Frontend:**
* **S3:** Hosts static website assets (HTML/CSS/JS).
* **CloudFront:** Global CDN for caching and SSL termination.
* **Origin Access Control (OAC):** Restricts S3 access so *only* CloudFront can read files (Bucket is private).
* **Route 53 & ACM:** Custom domain management with automatic SSL certificate validation via Terraform `for_each` loops.

**Backend:**
* **AWS Lambda (Python):** Handles API requests for the view counter via Function URL.
* **DynamoDB:** NoSQL database for storing visitor stats.
* **IAM:** Least-privilege roles and inline policies defined explicitly in code.

## What this project covers

### 1. The Migration Strategy (Import vs. Rebuild)
Instead of starting with `terraform apply` on a blank slate, I used the `import` workflow to bring existing resources under management:
* Identified existing resource IDs in the AWS Console.
* Wrote matching `resource` blocks in Terraform.
* Ran `terraform import` to map the real-world infrastructure to the state file.
* Refactored hardcoded values into variables (`var.domain_name`, `var.bucket_name`) for reusability.

### 2. Security Enhancements
Post-migration, I hardened the infrastructure using Terraform:
* **S3 Security:** Removed public bucket access and implemented OAC.
* **IAM Scoping:** Replaced broad permissions with specific `dynamodb:GetItem` and `dynamodb:PutItem` actions.
* **Encryption:** Enforced HTTPS via ACM certificates and CloudFront redirection.

### 3. Solved Engineering Challenges
* **DNS & Certificate Validation:** Implemented dynamic `for_each` loops to handle ACM DNS validation records automatically.
* **State Management:** Resolved "split-brain" DNS issues where the Registrar and Hosted Zone were out of sync during the import process.
* **Explicit Dependencies:** Modeled implicit console dependencies (like Lambda permissions) into explicit Terraform resource links.

## Project Structure

```text
├── Infra/               # Terraform Infrastructure Code
│   ├── cloudfront.tf    # CDN & Origin Access Control
│   ├── domain.tf        # Route53 & ACM Certificate logic
│   ├── s3.tf            # Static hosting & Bucket policies
│   ├── lambda.tf        # Python backend resource & Function URL
│   ├── dynamodb.tf      # State storage
│   ├── iam.tf           # Roles & Policies
│   └── providers.tf     # AWS Provider config
├── lambda/              # Backend Application Code
│   └── main.py          # Python logic for view counter
├── site/                # Frontend Assets
│   └── index.html       # Static website entry point
└── README.md
