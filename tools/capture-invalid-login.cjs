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
  await page.waitForTimeout(3000);
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());

  const email = page.getByRole('textbox', { name: 'Email address', exact: true });
  const password = page.getByRole('textbox', { name: 'Password', exact: true });
  await email.fill('wrong');
  await password.fill('bad');
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  await page.waitForTimeout(250);
  await page.screenshot({ path: 'docs/validation/landing-invalid-fields.png' });

  await email.fill('wrong@example.com');
  await password.fill('wrongpass');
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  await page.waitForTimeout(250);
  await page.screenshot({ path: 'docs/validation/landing-invalid-login-loading.png' });
  await page.waitForTimeout(1700);
  await page.screenshot({ path: 'docs/validation/landing-invalid-login-restored.png' });
  console.log(JSON.stringify({ errors }));
  await browser.close();
})();
