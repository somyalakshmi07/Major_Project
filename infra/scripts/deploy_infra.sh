#!/bin/bash
# Infrastructure Deployment Script
# Purpose: Deploy all Azure resources using Bicep templates

set -e

# Configuration - UPDATE THESE VALUES
PROJECT_PREFIX="ecom"
LOCATION="eastus"
SUBSCRIPTION_ID=""  # Set your subscription ID
AKS_NODE_COUNT=2
AKS_VM_SIZE="Standard_B2s"
DEPLOYMENT_NAME="ecommerce-infra-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Azure Infrastructure Deployment ===${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"
command -v az >/dev/null 2>&1 || { echo -e "${RED}Azure CLI not found. Please install it.${NC}" >&2; exit 1; }
command -v bicep >/dev/null 2>&1 || { echo -e "${YELLOW}Bicep not found. Installing...${NC}"; az bicep install; }

# Login check
echo -e "${YELLOW}Checking Azure login...${NC}"
az account show >/dev/null 2>&1 || { echo -e "${RED}Not logged in. Running az login...${NC}"; az login; }

# Set subscription
if [ -n "$SUBSCRIPTION_ID" ]; then
    echo -e "${YELLOW}Setting subscription...${NC}"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

CURRENT_SUB=$(az account show --query id -o tsv)
echo -e "${GREEN}Using subscription: $CURRENT_SUB${NC}"

# Confirm deployment
echo ""
echo -e "${YELLOW}Deployment Configuration:${NC}"
echo "  Project Prefix: $PROJECT_PREFIX"
echo "  Location: $LOCATION"
echo "  AKS Node Count: $AKS_NODE_COUNT"
echo "  AKS VM Size: $AKS_VM_SIZE"
echo ""
read -p "Continue with deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Create parameters file
echo -e "${YELLOW}Creating parameters file...${NC}"
cat > ../bicep/params.json <<EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "projectPrefix": {
      "value": "$PROJECT_PREFIX"
    },
    "location": {
      "value": "$LOCATION"
    },
    "aksNodeCount": {
      "value": $AKS_NODE_COUNT
    },
    "aksVmSize": {
      "value": "$AKS_VM_SIZE"
    },
    "sqlDatabaseSku": {
      "value": "Basic"
    },
    "postgresSku": {
      "value": "Standard_B1ms"
    },
    "cosmosDbThroughput": {
      "value": 400
    },
    "enableAppService": {
      "value": true
    }
  }
}
EOF

# Deploy infrastructure
echo -e "${YELLOW}Deploying infrastructure...${NC}"
echo "This may take 15-20 minutes..."
echo ""

az deployment sub create \
  --location "$LOCATION" \
  --name "$DEPLOYMENT_NAME" \
  --template-file ../bicep/main.bicep \
  --parameters @../bicep/params.json

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== Deployment Successful ===${NC}"
    echo ""
    echo -e "${YELLOW}Getting deployment outputs...${NC}"
    
    # Get outputs
    RESOURCE_GROUP=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query "properties.outputs.resourceGroupName.value" -o tsv)
    ACR_NAME=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query "properties.outputs.acrName.value" -o tsv)
    AKS_NAME=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query "properties.outputs.aksName.value" -o tsv)
    KEY_VAULT_NAME=$(az deployment sub show --name "$DEPLOYMENT_NAME" --query "properties.outputs.keyVaultName.value" -o tsv)
    
    echo ""
    echo -e "${GREEN}Deployment Outputs:${NC}"
    echo "  Resource Group: $RESOURCE_GROUP"
    echo "  ACR Name: $ACR_NAME"
    echo "  AKS Name: $AKS_NAME"
    echo "  Key Vault: $KEY_VAULT_NAME"
    echo ""
    
    # Configure kubectl
    echo -e "${YELLOW}Configuring kubectl...${NC}"
    az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_NAME" --overwrite-existing
    
    echo ""
    echo -e "${GREEN}=== Next Steps ===${NC}"
    echo "1. Create Azure DevOps service connections (see setup-service-connections.sh)"
    echo "2. Push code to Azure Repos"
    echo "3. Run CI/CD pipelines"
    echo "4. Verify deployment: ./verify_deploy.sh"
    echo ""
else
    echo -e "${RED}Deployment failed. Check the error messages above.${NC}"
    exit 1
fi

