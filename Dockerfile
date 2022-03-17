

# https://hub.docker.com/r/microsoft/dotnet
FROM mcr.microsoft.com/dotnet/sdk:6.0

# Install production dependencies.
# Copy csproj and restore as distinct layers.
WORKDIR /app
COPY *.csproj .

# Copy local code to the container image.
COPY . .
RUN dotnet restore

# Build a release artifact.
RUN dotnet publish -c Release -o /app




# Run the web service on container startup.
CMD ["dotnet", "out/HelloWorldAspNetCore.dll"]
