import { test, expect } from "@playwright/test";
import { config } from "dotenv";
import { readFileSync } from "fs";
import { join } from "path";
import { v4 as uuidv4 } from "uuid";

test("Create and delete item test", async ({ page }) => {
  // If user or CI has set the REACT_APP_WEB_BASE_URL, then use it. Otherwise, get it from the defaultEnvironment .env file

  let webUri = process.env.REACT_APP_WEB_BASE_URL;

  // If run locally, then use process.env, followed by .azure env, followed by http://localhost:300
  // If CI, then require the env var to be set

  if (!webUri && !process.env.CI) {
    // No env var set, only try to get from disk if not in CI
    let environment = process.env.AZURE_ENV_NAME;
    if (!environment) {
      let configFile;
      try {
        configFile = JSON.parse(
          readFileSync(join(".azure", "config.json"), "utf-8")
        );
        environment = configFile["defaultEnvironment"];
      } catch (err) {
        // Unable to load default environment
        console.error(err);
      }
    }

    expect(environment).toBeDefined();
    let envPath = join(".azure", environment, ".env");

    console.log("Loading env from: " + envPath);

    config({ path: envPath });
    webUri = process.env.REACT_APP_WEB_BASE_URL || "http://localhost:3000";
  }

  expect(
    webUri,
    "you need to set the REACT_APP_WEB_BASE_URL in shell or in .azure environment"
  ).toBeDefined();

  console.log("Using web URI: " + webUri);

  await page.goto(webUri);

  await page.waitForSelector("text=My List", { state: "visible" });

  const guid = uuidv4();
  console.log(guid);

  // Click [placeholder="Add an item"]
  await page.locator('[placeholder="Add an item"]').click();

  // Fill [placeholder="Add an item"]
  await page.locator('[placeholder="Add an item"]').fill(guid);

  // Press Enter
  await page.locator('[placeholder="Add an item"]').press("Enter");

  // Click text=foobar
  await page.waitForSelector("text=" + guid, { state: "visible" });

  await page.locator("text=" + guid).click();

  // Click button[role="menuitem"]:has-text("Delete")
  await page.locator('button[role="menuitem"]:has-text("Delete")').click();

  await page.waitForSelector("text=" + guid, { state: "detached" });
});
