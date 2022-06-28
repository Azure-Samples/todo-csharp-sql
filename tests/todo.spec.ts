import { test, expect } from "@playwright/test";
import { v4 as uuidv4 } from "uuid";

test("Create and delete item test", async ({ page }) => {
  await page.goto("/");

  await expect(page.locator("text=My List").first()).toBeVisible({
    timeout: 120 * 1000,
  });

  const guid = uuidv4();
  console.log("Creating item with text: " + guid);

  await page.locator('[placeholder="Add an item"]').click();

  await page.locator('[placeholder="Add an item"]').fill(guid);

  await page.locator('[placeholder="Add an item"]').press("Enter");

  await page.locator("text=" + guid).click();

  const itemMoreOperation = await page.$('button[role="menuitem"]:has-text("")');

  if(itemMoreOperation){
    await itemMoreOperation.click();
  };

  await page.locator('button[role="menuitem"]:has-text("Delete")').click();

  await expect(page.locator("text=" + guid).first()).toBeHidden();
});
