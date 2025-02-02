# Azure Static Web App with DNS Management

This repository contains Terraform configuration for deploying Azure Static Web Apps with custom domain configuration using Azure DNS. It sets up a complete infrastructure with both development and production environments.

## 🎯 Features

- Automated deployment of Azure Static Web Apps (Free tier)
- Azure DNS zone configuration
- Custom domain setup for both development and production environments
- Automatic DNS validation
- Complete CI/CD pipeline with Azure DevOps
- Separate environments for development and production
- Infrastructure as Code using Terraform

## 🏗️ Resources Created

- Resource Group
- Azure DNS Zone
- Two Static Web Apps:
  - Development environment (dev.yourdomain.com)
  - Production environment (www.yourdomain.com and yourdomain.com)
- DNS Records:
  - CNAME records for development and www
  - A record for apex domain
  - TXT records for domain validation

## 📋 Prerequisites

- Azure Subscription
- Azure DevOps Project
- Terraform (latest version)
- Azure CLI
- Domain name
- Storage Account for Terraform state (see backends.tf)

## 🚀 Getting Started

1. Clone this repository
2. Update `terraform.tfvars` with your values:
   ```hcl
   project_name = "your-project-name"
   domain_name  = "your-domain.com"
   location     = "your-preferred-region"
   ```

3. Update `backends.tf` with your storage account details:
   ```hcl
   terraform {
     backend "azurerm" {
       resource_group_name  = "your-resource-group"
       storage_account_name = "your-storage-account"
       container_name      = "your-container"
       key                 = "your-state-file.tfstate"
     }
   }
   ```

4. Configure Azure DevOps pipeline:
   - Create a service connection to Azure
   - Update the pipeline variables in `azure-pipelines.yaml`
   - Create a new pipeline using the provided YAML file

## 🔧 Pipeline Configuration

The pipeline includes:
- Automatic triggers for main and develop branches
- Terraform initialization
- Configuration validation
- Plan generation
- Apply (only on main branch)

Key variables to configure:
```yaml
variables:
  - name: serviceConnection
    value: "Your-Service-Connection-Name"
  - name: backendRG
    value: "Your-Backend-Resource-Group"
  - name: backendSA
    value: "Your-Backend-Storage-Account"
  - name: backendContainer
    value: "Your-Backend-Container"
  - name: projectName
    value: "Your-Project-Name"
```

## 📝 Custom Domain Setup

After deployment:
1. Get the name servers from the Azure DNS zone outputs
2. Update your domain registrar's nameservers
3. Wait for DNS propagation (automatically handled in the Terraform configuration)
4. Custom domains will be automatically validated and configured

## 🔍 Outputs

The deployment provides several useful outputs:
- Development Static Web App URL
- Production Static Web App URL
- Custom domain names
- DNS zone name servers

View them using:
```bash
terraform output
```

## ⚙️ Configuration Options

Key variables that can be configured in `terraform.tfvars`:
- `project_name` - Used in resource naming
- `location` - Azure region
- `domain_name` - Your custom domain
- `tags` - Resource tags

## 🔒 Security Notes

- The configuration uses Azure's managed certificates for HTTPS
- All resources are created within a single resource group
- DNS validation is handled automatically
- Free tier of Static Web Apps is used by default

## 📊 Cost Considerations

- Azure Static Web Apps Free tier
- Azure DNS zone (~$0.50/month)
- Storage account for Terraform state (minimal cost)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details

## ⚠️ Important Notes

- DNS propagation may take up to 48 hours
- The pipeline includes a 90-second delay for DNS propagation
- Custom domain validation can take up to 30 minutes
- Resource deletion prevention is disabled in the provider configuration

---

For more information about Azure Static Web Apps, visit [Microsoft's official documentation](https://docs.microsoft.com/azure/static-web-apps/).