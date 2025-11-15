# E-Commerce Microservices - Production Deployment Guide

## 🎯 Overview

Production-grade e-commerce microservices platform deployed on Azure with full CI/CD, monitoring, and infrastructure as code.

## 📋 Prerequisites

- Azure Subscription (Student subscription with credits)
- Azure CLI installed and configured
- Docker Desktop
- .NET 8.0 SDK
- kubectl
- Helm 3.x
- Azure DevOps organization and project

## 🚀 Quick Start

### 1. Provision Infrastructure

```bash
cd infra/scripts
# Edit deploy_infra.sh and set variables
./deploy_infra.sh
```

Or using PowerShell:
```powershell
cd infra/scripts
.\deploy_infra.ps1
```

**Manual Steps Required:**
- Accept service principal permissions in Azure Portal
- Create Azure DevOps service connections (see `infra/scripts/setup-service-connections.sh`)

### 2. Set Up Azure DevOps

1. Create repositories in Azure DevOps (one per service + frontend + infra)
2. Create variable groups:
   - `devops-vars` - Contains ACR name, AKS name, resource group
   - `secrets-vars` - Contains Key Vault references
3. Create service connections:
   - Azure Resource Manager connection to subscription
   - Docker Registry connection to ACR
   - Kubernetes connection to AKS

### 3. Push Code to Repos

```bash
# For each service
git remote add azure <AZURE_REPO_URL>
git push azure main
```

### 4. Run CI/CD Pipelines

- CI pipelines trigger automatically on push to `main`
- CD pipelines require manual approval (configure in pipeline settings)

### 5. Verify Deployment

```bash
./verify_deploy.sh
# or
.\verify_deploy.ps1
```

## 📁 Repository Structure

Each microservice follows Clean Architecture:
- **Domain**: Entities and interfaces
- **Application**: Use cases, DTOs, services
- **Infrastructure**: Data access, external services
- **API**: Controllers, configuration

## 🔧 Local Development

```bash
docker-compose up -d
```

Access services:
- Frontend: http://localhost:3000
- Auth API: http://localhost:5001
- Catalog API: http://localhost:5002
- Cart API: http://localhost:5003
- Order API: http://localhost:5004
- Payment API: http://localhost:5005

## 🌐 Accessing Deployed Application

After deployment, get endpoints:

```bash
# Get AKS ingress IP
kubectl get ingress -n production

# Or for App Service
az webapp show --name <APP_NAME> --resource-group <RG_NAME> --query defaultHostName
```

## 🔐 Secrets Management

Secrets are stored in Azure Key Vault and accessed via:
- Managed Identity (in Azure)
- Key Vault Provider for Secrets Store CSI Driver (in Kubernetes)

## 📊 Monitoring

- Application Insights: View in Azure Portal
- Log Analytics: Query logs using KQL
- Alerts: Configured for CPU, errors, and budget

## 💰 Cost Management

- Budget alert set at $30/month
- AKS uses Standard_B2s VMs (cost-optimized)
- App Service alternative for lower costs

## 🐛 Troubleshooting

See [RUNBOOK.md](./RUNBOOK.md) for common issues and solutions.

## 📚 Documentation

- [Infrastructure README](./infra/README.md)
- [Service-specific READMEs](./auth-service/README.md, etc.)
- [API Documentation](./API_ENDPOINTS.md)

## 🎬 Demo Script

See [demo_script.txt](./demo_script.txt) for presentation steps.
