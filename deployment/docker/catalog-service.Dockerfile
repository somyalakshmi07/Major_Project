# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["services/CatalogService/CatalogService.API/CatalogService.API.csproj", "services/CatalogService/CatalogService.API/"]
COPY ["services/CatalogService/CatalogService.Application/CatalogService.Application.csproj", "services/CatalogService/CatalogService.Application/"]
COPY ["services/CatalogService/CatalogService.Domain/CatalogService.Domain.csproj", "services/CatalogService/CatalogService.Domain/"]
COPY ["services/CatalogService/CatalogService.Infrastructure/CatalogService.Infrastructure.csproj", "services/CatalogService/CatalogService.Infrastructure/"]

RUN dotnet restore "services/CatalogService/CatalogService.API/CatalogService.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/services/CatalogService/CatalogService.API"
RUN dotnet build "CatalogService.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "CatalogService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "CatalogService.API.dll"]

