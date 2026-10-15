const { chromium } = require(process.env.TEMP + '/furu-browser/node_modules/playwright');

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
  });
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto('http://127.0.0.1:8000');
  await page.waitForTimeout(4500);
  await page.screenshot({ path: 'docs/validation/landing-recreation-390.png' });
  console.log(JSON.stringify({ errors, size: await page.viewportSize() }));
  await browser.close();
})();
