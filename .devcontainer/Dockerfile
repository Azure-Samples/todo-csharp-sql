ARG VARIANT=bullseye
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

WORKDIR /extensions
RUN curl -fsSLo azure-dev.vsix https://aka.ms/azure-dev/vsix