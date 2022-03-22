# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.205.2/containers/codespaces-linux/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal
USER root
RUN az config set extension.index_url=https://azuresdkreleasepreview.blob.core.windows.net/azd/whl/latest/index.json  \
    && az extension add --name azure-dev -y --system && az config unset extension.index_url
USER codespace