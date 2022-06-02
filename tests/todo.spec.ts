import { test, expect } from "@playwright/test";
import { config } from "dotenv";
import { readFileSync } from "fs";
import { join } from "path";
import { v4 as uuidv4 } from "uuid";

test("Create and delete item test", async ({ page }) => {
  let webUri = process.env.REACT_APP_WEB_BASE_URL;

  // If run locally, then use process.env, followed by .azure env, followed by http://localhost:300
  // If CI, then require the env var to be set

  if (!webUri && !process.env.CI) {
    // No webUri env var set, only try to get from disk if not in CI
    let environment = process.env.AZURE_ENV_NAME;
    if (!environment) {
      // Couldn't find env, let's try to load from .azure folder
      let configFile;
      try {
        configFile = JSON.parse(
          readFileSync(join("../", ".azure", "config.json"), "utf-8")
        );
        environment = configFile["defaultEnvironment"];

        if (environment) {
          let envPath = join("../", ".azure", environment, ".env");

          console.log("Loading env from: " + envPath);

          config({ path: envPath });
          webUri = process.env.REACT_APP_WEB_BASE_URL;
        }
      } catch (err) {
        console.log("Unable to load default environment: " + err);
      }
    }
  }

  if (!webUri) {
    webUri = "http://localhost:3000";
  }

  console.log("Using Web URI: " + webUri);

  await page.goto(webUri);

  await expect(page.locator("text=My List").toBeVisible();

  const guid = uuidv4();
  console.log("Creating item with text: " + guid);

  await page.locator('[placeholder="Add an item"]').click();

  await page.locator('[placeholder="Add an item"]').fill(guid);

  await page.locator('[placeholder="Add an item"]').press("Enter");

  await Promise.all([
    page.locator("text=" + guid).click(),
    page.waitForSelector("text=" + guid, { state: "visible" }),
  ])
  
  await page.locator('button[role="menuitem"]:has-text("Delete")').click();

  await expect(page.locator("text=" + guid).toBeHidden();
});
