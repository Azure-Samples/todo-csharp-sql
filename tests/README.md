# Test Setup

## Install Playwright 

### VS Code Extension

https://marketplace.visualstudio.com/items?itemName=ms-playwright.playwright

### NPM Package

#### Using VS Code
1. Hit F1
1. Choose "Install Playwright"

#### Using npm

```
npm i -g playwright
npm i -D @playwright/test
```

## Run Tests

The included smoke test will hit the ToDo app web endpoint, create and delete an item.

The endpoint it hits will be discovered in this order:

1. Value of `REACT_APP_WEB_BASE_URL` environment variable
1. Value of `REACT_APP_WEB_BASE_URL` found in default .azure environment
1. Defaults to `https://localhost:3000`


To run the tests:

1. CD to /tests
1. Run `npm i`
1. Run `npx playwright test --headed`

## Debug Tests

Set this env var to enable tracing:

```
DEBUG=pw:api
```

Debug scripts with: https://playwright.dev/docs/next/debug and https://playwright.dev/docs/next/trace-viewer


To open playwright inspector:

```
PWDEBUG=1
```