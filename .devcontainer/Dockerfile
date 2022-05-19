ARG VARIANT=16-bullseye
FROM mcr.microsoft.com/vscode/devcontainers/javascript-node:0-${VARIANT}

WORKDIR /extensions
RUN curl -fsSLo azure-dev.vsix https://aka.ms/azure-dev/vsix \
    && npm install -g npm