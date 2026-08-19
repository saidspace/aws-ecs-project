# Threat Composer on AWS ECS Fargate

A containerised deployment of [Threat Composer](https://github.com/awslabs/threat-composer) (Amazon's open-source threat modelling tool) to AWS, built to mirror a real production workload: Docker, ECS Fargate, an Application Load Balancer, Terraform-managed infrastructure, GitHub Actions CI/CD with OIDC (no static AWS keys), and HTTPS on a custom domain via ACM and Route 53.

**Live at:** [https://said-space.com](https://said-space.com)

## Architecture

![Architecture diagram](images/architecture-diagram.png)

## Directory structure

    .
    ├── app/                    # Threat Composer application source
    ├── Dockerfile
    ├── .dockerignore
    ├── infra/                  # Terraform (modular structure)
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── provider.tf
    │   ├── terraform.tfvars
    │   └── modules/
    │       ├── vpc/
    │       ├── ecr/
    │       ├── alb/
    │       ├── ecs/
    │       ├── iam/
    │       └── acm/
    ├── .github/
    │   └── workflows/
    │       └── deploy.yml      # Build → push to ECR → force ECS deployment
    ├── images/                 # README screenshots and diagram
    └── README.md

## Screenshots

The app running live, served over HTTPS via ACM and Route 53:

![App running live on said-space.com](images/dashboard-screenshot.png)

## Reproducing this setup

Prerequisites: an AWS account, a registered domain in Route 53 (registration creates a hosted zone automatically), Terraform, Docker, and the AWS CLI configured.

1. Clone the repo and build the app image locally to confirm it runs:

       docker build -t threat-composer .
       docker run -p 8080:8080 threat-composer

2. Push the image to an ECR repository (create one first, or let the `ecr` module manage it):

       aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-west-2.amazonaws.com
       docker push <account-id>.dkr.ecr.eu-west-2.amazonaws.com/threat-composer:latest

3. Set your domain in `infra/terraform.tfvars`:

       domain_name = "your-domain.com"

4. Initialise and apply the Terraform stack:

       cd infra
       terraform init
       terraform plan
       terraform apply

5. Wait for ACM to validate the certificate via DNS (usually under a few minutes) — `terraform apply` will pause here automatically until it's issued.

6. Visit `https://<your-domain>` to confirm the app is live over HTTPS.

7. For CI/CD: add the GitHub Actions OIDC role ARN (output as `github_actions_role_arn`) to your repo, and pushes to `main` will build, push to ECR, and force a new ECS deployment automatically.

To tear everything down and stop AWS costs:

       cd infra
       terraform destroy

## Notes

A few things worth mentioning that aren't obvious just from looking at the code.

The CI/CD pipeline never runs `terraform apply` — on purpose. It only builds, pushes to ECR, and forces a new ECS deployment. State is stored locally right now, so if CI and a manual apply ever ran at the same time they could clash and corrupt it. Keeping Terraform out of the pipeline for now avoids that risk entirely.

The trickiest bug in this project was a GitHub Actions OIDC failure — every run kept failing at `configure-aws-credentials` with an `AssumeRoleWithWebIdentity` error, even though the trust policy, audience, and permissions all looked correct. Turned out GitHub changed how the OIDC `sub` claim works for repos created after 15 July 2026 — it now appends permanent numeric owner/repo IDs, which broke the older name-only trust policy format. Fixed it by pulling those IDs from the GitHub API and updating the trust policy to match. Along the way I also learned that `AssumeRoleWithWebIdentity` logs to `us-east-1` in CloudTrail regardless of your actual region — after some digging around trying to find the failed auth event, I finally found it there instead of in eu-west-2.

State is local for now rather than remote. Fine for a solo project, but if this were a team setup I'd move to an S3 backend with DynamoDB locking so two people can't apply at once.
