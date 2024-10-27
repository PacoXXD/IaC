# Running a Cronos Node

## Prerequisites
- Terraform installed
- Proper configuration in `terraform.tfvars`

## Steps to Run

1. Navigate to the Cronos node directory:
```bash
cd Cronos-node-TF
```

2. Initialize Terraform:
```bash
terraform init
```

3. Configure your deployment:
   - Open `terraform.tfvars`
   - Modify the variables according to your requirements
   - Save the changes

4. Deploy the node:
```bash
terraform apply
```

## Note
Make sure to review and adjust the variables in `terraform.tfvars` before running the deployment to match your specific configuration needs.
