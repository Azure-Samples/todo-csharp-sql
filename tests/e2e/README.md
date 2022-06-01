# Test Setup

## Install Playwright VS Code Extension

https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright

## Install Playwright NPM Package

### Using VS Code
1. Hit F1
1. Choose "Install Playwright"

### Using npm

```
npm i -g playwright
npm i -D @playwright/test
```

## Run Tests

Tests will first try to read `REACT_APP_WEB_BASE_URL` environment variable and if not set it will try to get that value from the current environment .env file.


You can manually set with:

```
REACT_APP_WEB_BASE_URL=https://...your web uri
```

Run this from the `test` folder of each project:

`npx playwright test --headed`

## Debug Tests

Set this env var to enable tracing:

```
DEBUG=pw:api
```

Debug scripts with: https://playwright.dev/docs/next/debug and https://playwright.dev/docs/next/trace-viewer


To open playwright inspector:

```
PWDEBUG=1