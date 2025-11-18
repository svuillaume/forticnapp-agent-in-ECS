# Lacework Azure Agentless Scanning Deployment - AWLS

This guide explains how to deploy Lacework Azure Agentless Scanning using Terraform. It includes all prerequisites, deployment steps, Terraform configurations, and FAQs in a single document.

---

## Prerequisites and Recommendations

Before you start, ensure you complete the following steps:

1. **Create a New Service Principal and Assign Permissions**  
   You must create a service principal in Azure and assign the necessary permissions. Follow the official instructions provided by Lacework:  
   [Service Principal Setup](https://github.com/lacework/terraform-azure-agentless-scanning/tree/main/service_principal)

2. **Decide Whether You Need a NAT Gateway (NAT-GW)**  
   Determine if your environment requires a NAT Gateway. This depends on your network egress requirements and how tightly controlled outbound traffic is. If your environment restricts outbound traffic, a NAT-GW may be necessary.

3. **Pick the correct Integration**
   https://github.com/lacework/terraform-azure-agentless-scanning/tree/main/examples
   
---

## AWLS Deployment steps

The recommended deployment flow involves a preflight check followed by Terraform initialization, validation, planning, and applying the configuration.

### Step 1: Preflight Check
Perform preflight checks to ensure your environment is ready. If all checks pass (return **TRUE**), you can proceed.

```
https://github.com/lacework/terraform-azure-agentless-scanning/tree/main/preflight_check
```

**Note: the preflight must be successful to go next steps**

### Step 2: Initialize Terraform
Run the following command to initialize Terraform and download required providers (i.e: Tenant Integration in a single Region):

```bash
terraform {
  required_version = ">= 0.13"

  required_providers {
    lacework = {
      source = "lacework/lacework"
    }
  }
}
```

```bash
module "lacework_azure_agentless_scanning_single_tenant" {
  source                         = "lacework/agentless-scanning/azure"
  global                         = true
  create_log_analytics_workspace = true
  integration_level               = "tenant"
  # tags                          = { "KEY" : "VALUE" }
  tenant_id                       = "XXXXXXX"
}
```

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

## FAQ

### Common Question
Do you usually update the existing `main.tf` created for Azure Config + Audit Log, or keep a separate file?

**Answer:**  
Both patterns technically work. However, the recommended and simpler approach is to **update the original `main.tf` created for the Azure Config + Audit Log integration**. This keeps everything in a single Terraform module structure and avoids unnecessary fragmentation.
