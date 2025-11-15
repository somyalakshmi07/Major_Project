# Environment Variables Documentation

This document lists all environment variables required for the E-Commerce Microservices application.

## Auth Service

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ConnectionStrings__PostgreSQL` | PostgreSQL connection string | `Host=localhost;Port=5432;Database=AuthDb;Username=postgres;Password=postgres` | Yes |
| `Jwt__SecretKey` | JWT secret key (min 32 characters) | `your-super-secret-key-that-is-at-least-32-characters-long` | Yes |
| `Jwt__Issuer` | JWT issuer | `ECommerceMicroservices` | No |
| `Jwt__Audience` | JWT audience | `ECommerceMicroservices` | No |
| `Jwt__ExpiryMinutes` | JWT token expiry in minutes | `60` | No |
| `ASPNETCORE_ENVIRONMENT` | Environment (Development/Production) | `Development` | No |

## Catalog Service

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ConnectionStrings__MongoDB` | MongoDB connection string | `mongodb://localhost:27017` | Yes |
| `MongoDB__DatabaseName` | MongoDB database name | `CatalogDb` | Yes |
| `Jwt__SecretKey` | JWT secret key (must match Auth Service) | `your-super-secret-key-that-is-at-least-32-characters-long` | Yes |
| `Jwt__Issuer` | JWT issuer | `ECommerceMicroservices` | No |
| `Jwt__Audience` | JWT audience | `ECommerceMicroservices` | No |
| `AuthService__Url` | Auth Service URL for token validation | `http://localhost:5001` | No |
| `ASPNETCORE_ENVIRONMENT` | Environment (Development/Production) | `Development` | No |

## Cart Service

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ConnectionStrings__MongoDB` | MongoDB connection string | `mongodb://localhost:27017` | Yes |
| `ConnectionStrings__Redis` | Redis connection string | `localhost:6379` | Yes |
| `MongoDB__DatabaseName` | MongoDB database name | `CartDb` | Yes |
| `Jwt__SecretKey` | JWT secret key (must match Auth Service) | `your-super-secret-key-that-is-at-least-32-characters-long` | Yes |
| `Jwt__Issuer` | JWT issuer | `ECommerceMicroservices` | No |
| `Jwt__Audience` | JWT audience | `ECommerceMicroservices` | No |
| `ASPNETCORE_ENVIRONMENT` | Environment (Development/Production) | `Development` | No |

## Order Service

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `ConnectionStrings__SQLServer` | SQL Server connection string | `Server=localhost,1433;Database=OrderDb;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True;` | Yes |
| `Jwt__SecretKey` | JWT secret key (must match Auth Service) | `your-super-secret-key-that-is-at-least-32-characters-long` | Yes |
| `Jwt__Issuer` | JWT issuer | `ECommerceMicroservices` | No |
| `Jwt__Audience` | JWT audience | `ECommerceMicroservices` | No |
| `ASPNETCORE_ENVIRONMENT` | Environment (Development/Production) | `Development` | No |

## Payment Service

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `OrderService__Url` | Order Service URL for updating order status | `http://localhost:5004` | Yes |
| `Payment__SuccessRate` | Payment success rate (0.0-1.0) | `0.85` | No |
| `ASPNETCORE_ENVIRONMENT` | Environment (Development/Production) | `Development` | No |

## Frontend

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `AUTH_SERVICE_URL` | Auth Service API URL | `http://localhost:5001/api` | Yes |
| `CATALOG_SERVICE_URL` | Catalog Service API URL | `http://localhost:5002/api` | Yes |
| `CART_SERVICE_URL` | Cart Service API URL | `http://localhost:5003/api` | Yes |
| `ORDER_SERVICE_URL` | Order Service API URL | `http://localhost:5004/api` | Yes |
| `PAYMENT_SERVICE_URL` | Payment Service API URL | `http://localhost:5005/api` | Yes |

## Kubernetes Configuration

For Kubernetes deployments, these environment variables are configured via ConfigMaps and Secrets:

### ConfigMaps

- `auth-service-config`: PostgreSQL connection string
- `catalog-service-config`: MongoDB connection string
- `cart-service-config`: MongoDB and Redis connection strings
- `order-service-config`: SQL Server connection string
- `payment-service-config`: Order Service URL

### Secrets

All services require a secret named `{service-name}-secrets` containing:
- `jwt-secret-key`: JWT secret key (must be the same across all services)

### Example Kubernetes Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: auth-service-secrets
type: Opaque
stringData:
  jwt-secret-key: "your-production-secret-key-minimum-32-characters"
```

## Docker Compose

When using docker-compose, environment variables are set in the `docker-compose.yml` file. The services automatically connect to the database containers using service names.

## Production Recommendations

1. **JWT Secret Key**: Use a strong, randomly generated secret key (minimum 32 characters) in production
2. **Database Passwords**: Use strong, unique passwords for all databases
3. **Connection Strings**: Use managed database services (Azure Database, etc.) instead of containers in production
4. **Environment**: Set `ASPNETCORE_ENVIRONMENT=Production` in production
5. **Secrets Management**: Use Azure Key Vault or Kubernetes Secrets for sensitive data
6. **HTTPS**: Configure HTTPS for all services in production

