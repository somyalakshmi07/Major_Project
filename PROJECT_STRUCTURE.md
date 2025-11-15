# E-Commerce Microservices - Complete Project Structure

## Azure Repos Organization

Create the following repositories in Azure DevOps:

1. **auth-service** - IdentityServer + PostgreSQL microservice
2. **catalog-service** - Product catalog with MongoDB
3. **cart-service** - Shopping cart with Redis + MongoDB
4. **order-service** - Order management with SQL Server
5. **payment-service** - Payment processing simulator
6. **frontend** - React application
7. **infrastructure** - Bicep templates and deployment scripts

## Directory Structure

```
ecommerce-microservices/
├── infra/                          # Infrastructure as Code
│   ├── bicep/
│   │   ├── main.bicep
│   │   ├── modules/
│   │   │   ├── aks.bicep
│   │   │   ├── acr.bicep
│   │   │   ├── keyvault.bicep
│   │   │   ├── databases.bicep
│   │   │   ├── servicebus.bicep
│   │   │   └── monitoring.bicep
│   │   └── params.json
│   ├── scripts/
│   │   ├── deploy_infra.sh
│   │   ├── deploy_infra.ps1
│   │   └── setup-service-connections.sh
│   └── README.md
├── auth-service/
│   ├── src/
│   │   ├── AuthService.Domain/
│   │   ├── AuthService.Application/
│   │   ├── AuthService.Infrastructure/
│   │   └── AuthService.API/
│   ├── tests/
│   │   └── AuthService.Tests/
│   ├── k8s/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   └── ingress.yaml
│   ├── helm/
│   │   └── auth-service/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   ├── Dockerfile
│   ├── .dockerignore
│   └── README.md
├── catalog-service/
│   ├── src/
│   │   ├── CatalogService.Domain/
│   │   ├── CatalogService.Application/
│   │   ├── CatalogService.Infrastructure/
│   │   └── CatalogService.API/
│   ├── tests/
│   ├── k8s/
│   ├── helm/
│   ├── Dockerfile
│   └── README.md
├── cart-service/
├── order-service/
├── payment-service/
├── frontend/
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── .env.example
│   └── README.md
├── azure-pipelines/
│   ├── auth-ci.yml
│   ├── auth-cd.yml
│   ├── catalog-ci.yml
│   ├── catalog-cd.yml
│   ├── cart-ci.yml
│   ├── cart-cd.yml
│   ├── order-ci.yml
│   ├── order-cd.yml
│   ├── payment-ci.yml
│   ├── payment-cd.yml
│   ├── frontend-ci.yml
│   └── frontend-cd.yml
├── docker-compose.yml
├── docker-compose.override.yml
├── verify_deploy.sh
├── verify_deploy.ps1
├── postman_collection.json
├── demo_script.txt
├── RUNBOOK.md
└── README.md
```

