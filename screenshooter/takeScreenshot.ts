import chromium from "chrome-aws-lambda";

export const takeScreenshot = async (url: string) => {
  const browser = await chromium.puppeteer.launch({
    args: chromium.args,
    defaultViewport: chromium.defaultViewport,
    executablePath: await chromium.executablePath,
    headless: chromium.headless,
    ignoreHTTPSErrors: true,
  });
  try {
    const page = await browser.newPage();
    page.setViewport({ height: 720, width: 1280 });
    await page.goto(url, {
      waitUntil: "networkidle2",
    });
    const screenshot = await page.screenshot({ type: "jpeg" });
    await browser.close();
    return Buffer.from(screenshot as Buffer).toString("base64");
  } catch (e) {
    await browser.close();
    throw e;
  }
};
