FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY LangRaceDotnet.csproj .
RUN dotnet restore LangRaceDotnet.csproj

COPY . .
RUN dotnet publish LangRaceDotnet.csproj -c Release -o /app/out

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

COPY --from=build /app/out .

EXPOSE 8084
ENTRYPOINT ["dotnet", "LangRaceDotnet.dll"]
