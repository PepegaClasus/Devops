

# https://hub.docker.com/r/microsoft/dotnet
FROM mcr.microsoft.com/dotnet/sdk:6.0

# Install production dependencies.
# Copy csproj and restore as distinct layers.
WORKDIR /app
COPY *.csproj .

# Copy local code to the container image.
COPY . .

# Build a release artifact.
RUN dotnet publish -c Release -o out --no-restore

# Make sure the app binds to port 8080
ENV ASPNETCORE_URLS http://*:8080

# Run the web service on container startup.
CMD ["dotnet", "out/HelloWorldAspNetCore.dll"]
