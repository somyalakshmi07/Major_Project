# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["services/CartService/CartService.API/CartService.API.csproj", "services/CartService/CartService.API/"]
COPY ["services/CartService/CartService.Application/CartService.Application.csproj", "services/CartService/CartService.Application/"]
COPY ["services/CartService/CartService.Domain/CartService.Domain.csproj", "services/CartService/CartService.Domain/"]
COPY ["services/CartService/CartService.Infrastructure/CartService.Infrastructure.csproj", "services/CartService/CartService.Infrastructure/"]

RUN dotnet restore "services/CartService/CartService.API/CartService.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/services/CartService/CartService.API"
RUN dotnet build "CartService.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "CartService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "CartService.API.dll"]

