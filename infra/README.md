# Infrastructure as Code

## Overview

This directory contains Bicep templates and deployment scripts to provision all Azure resources required for the e-commerce microservices platform.

## Resources Provisioned

- Resource Group
- Azure Container Registry (ACR)
- AKS Cluster (with system node pool)
- App Service Plan (alternative hosting)
- Azure SQL Server + Database
- Azure Database for PostgreSQL Flexible Server
- Azure Cosmos DB (MongoDB API)
- Azure Cache for Redis
- Azure Service Bus
- Azure Key Vault
- Application Insights
- Log Analytics Workspace
- Budget and Alert Rules

## Prerequisites

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription <YOUR_SUBSCRIPTION_ID>

# Install Bicep (if not installed)
az bicep install
```

## Deployment

### Quick Deploy

```bash
cd scripts
./deploy_infra.sh
```

### Manual Steps

1. **Review Parameters**: Edit `bicep/params.json` and set:
   - `projectPrefix`: Unique prefix for resources (3-5 chars)
   - `location`: Azure region (e.g., `eastus`)
   - `aksNodeCount`: Number of nodes (default: 2 for student)
   - `aksVmSize`: VM size (default: `Standard_B2s`)

2. **Deploy Infrastructure**:
   ```bash
   az deployment sub create \
     --location <LOCATION> \
     --template-file bicep/main.bicep \
     --parameters @bicep/params.json
   ```

3. **Create Service Connections** (Manual in Azure DevOps):
   - Go to Project Settings → Service Connections
   - Create Azure Resource Manager connection
   - Create Docker Registry connection (ACR)
   - Create Kubernetes connection (AKS)

## Cost Optimization for Students

- AKS: Use `Standard_B2s` (2 vCPU, 4GB RAM) - ~$30/month for 2 nodes
- App Service: Use `B1` tier - ~$13/month
- Cosmos DB: Use serverless mode
- SQL Database: Use Basic tier
- PostgreSQL: Use Burstable tier

**Estimated Monthly Cost**: $50-80/month (with student discounts)

## Post-Deployment

After deployment, run:

```bash
# Get outputs
az deployment sub show --name <DEPLOYMENT_NAME> --query properties.outputs

# Configure kubectl
az aks get-credentials --resource-group <RG_NAME> --name <AKS_NAME>

# Verify
kubectl get nodes
```

## Cleanup

To remove all resources:

```bash
az group delete --name <RESOURCE_GROUP_NAME> --yes --no-wait
```

