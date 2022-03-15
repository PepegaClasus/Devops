FROM mcr.microsoft.com/dotnet/sdk:6.0 
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./HelloWorldAspNetCore/
RUN dotnet restore

# copy everything else and build app
COPY HelloWorldAspNetCore/. ./HelloWorldAspNetCore/
WORKDIR /source/HelloWorldAspNetCore
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "HelloWorldAspNetCore.dll"]
