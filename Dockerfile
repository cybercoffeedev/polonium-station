FROM debian:bookworm-slim AS build
ENV dotnet_ver=9.0

RUN apt update && \
    apt install -y wget unzip && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt update && \
    apt install -y dotnet-sdk-${dotnet_ver} && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /polonium
COPY . .
RUN dotnet build Content.Packaging -c Release -f net${dotnet_ver} && \
    dotnet run --project Content.Packaging server --hybrid-acz --platform linux-x64 && \
    unzip -d release/server release/SS14.Server_linux-x64.zip

FROM debian:bookworm-slim AS server
ENV dotnet_ver=9.0

RUN apt update && \
    apt install -y wget && \
    wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt update && \
    apt install -y dotnet-runtime-${dotnet_ver} && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /polonium/release/server /ss14-server
WORKDIR /ss14-server
RUN chmod +x ./Robust.Server

EXPOSE 1212
CMD ["./Robust.Server"]
