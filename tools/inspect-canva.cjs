const { chromium } = require(process.env.TEMP + '/furu-browser/node_modules/playwright');
const fs = require('node:fs');
(async () => {
  const browser = await chromium.connectOverCDP('http://127.0.0.1:9222');
  const page = browser.contexts()[0].pages().find(p => p.url().includes('DAHU85AwgH0'));
  fs.mkdirSync('assets/brand', { recursive: true });
  const images = await page.locator('img').evaluateAll(es => es.map(e => e.currentSrc));
  for (const [id, name] of [['4dff6949-5bec-449c-9570-e333c82a0f94', 'furyou-logo.png'], ['9bd8c2fc-a9b2-42ed-997e-24fbab4ec4df', 'whelps-logo.png'], ['80f7647b-2e38-4547-936c-4101bbe7cca0', 'reference-cat.jpg']]) {
    const url = images.find(s => s.includes(id));
    const response = await page.request.get(url);
    if (!response.ok()) throw new Error(`Asset download failed: ${name}`);
    fs.writeFileSync('assets/brand/' + name, await response.body());
  }
  for (let n = 1; n <= 14; n++) {
    if (n > 1) await page.getByRole('button', { name: `${n - 1} / 14`, exact: true }).click();
    const field = page.getByRole('spinbutton', { name: 'Go to page' });
    await field.fill(String(n));
    await field.press('Enter');
    await page.getByRole('button', { name: `${n} / 14`, exact: true }).waitFor();
    await page.waitForTimeout(500);
    console.log(`PAGE ${n}\n${await page.getByRole('main', {name:'Canvas', exact:true}).innerText()}`);
    await page.screenshot({ path: `docs/validation/canva-page-${n}.png` });
  }
  await page.getByRole('button', { name: '14 / 14', exact: true }).click();
  await page.getByRole('spinbutton', { name: 'Go to page' }).fill('1');
  await page.getByRole('spinbutton', { name: 'Go to page' }).press('Enter');
  await browser.close();
})();
