# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["services/PaymentService/PaymentService.API/PaymentService.API.csproj", "services/PaymentService/PaymentService.API/"]
COPY ["services/PaymentService/PaymentService.Application/PaymentService.Application.csproj", "services/PaymentService/PaymentService.Application/"]
COPY ["services/PaymentService/PaymentService.Domain/PaymentService.Domain.csproj", "services/PaymentService/PaymentService.Domain/"]
COPY ["services/PaymentService/PaymentService.Infrastructure/PaymentService.Infrastructure.csproj", "services/PaymentService/PaymentService.Infrastructure/"]

RUN dotnet restore "services/PaymentService/PaymentService.API/PaymentService.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/services/PaymentService/PaymentService.API"
RUN dotnet build "PaymentService.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "PaymentService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "PaymentService.API.dll"]

