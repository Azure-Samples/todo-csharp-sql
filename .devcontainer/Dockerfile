# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.205.2/containers/codespaces-linux/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/universal:1-focal
USER root
RUN az extension add --source https://azuresdkreleasepreview.blob.core.windows.net/azd/preview/0.0.1-beta/azure_dev-0.0.1b0-py3-none-any.whl -y --system
USER codespace