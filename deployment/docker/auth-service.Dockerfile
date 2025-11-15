# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["services/AuthService/AuthService.API/AuthService.API.csproj", "services/AuthService/AuthService.API/"]
COPY ["services/AuthService/AuthService.Application/AuthService.Application.csproj", "services/AuthService/AuthService.Application/"]
COPY ["services/AuthService/AuthService.Domain/AuthService.Domain.csproj", "services/AuthService/AuthService.Domain/"]
COPY ["services/AuthService/AuthService.Infrastructure/AuthService.Infrastructure.csproj", "services/AuthService/AuthService.Infrastructure/"]

RUN dotnet restore "services/AuthService/AuthService.API/AuthService.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/services/AuthService/AuthService.API"
RUN dotnet build "AuthService.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "AuthService.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
EXPOSE 443
ENTRYPOINT ["dotnet", "AuthService.API.dll"]

