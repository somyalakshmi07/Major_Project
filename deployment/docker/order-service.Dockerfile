# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["services/OrderService/OrderService.API/OrderService.API.csproj", "services/OrderService/OrderService.API/"]
COPY ["services/OrderService/OrderService.Application/OrderService.Application.csproj", "services/OrderService/OrderService.Application/"]
COPY ["services/OrderService/OrderService.Domain/OrderService.Domain.csproj", "services/OrderService/OrderService.Domain/"]
COPY ["services/OrderService/OrderService.Infrastructure/OrderService.Infrastructure.csproj", "services/OrderService/OrderService.Infrastructure/"]

RUN dotnet restore "services/OrderService/OrderService.API/OrderService.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/services/OrderService/OrderService.API"
RUN dotnet build "OrderService.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "OrderService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "OrderService.API.dll"]

