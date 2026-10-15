const {chromium} = require(process.env.TEMP + '/furu-browser/node_modules/playwright');
(async () => {
  const browser = await chromium.launch({headless:true, executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
  const page = await browser.newPage({viewport:{width:390,height:844}});
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.goto('http://127.0.0.1:8080');
  await page.waitForTimeout(4000);
  for (const width of [320,390,412]) {
    await page.setViewportSize({width,height:844});
    await page.screenshot({path:`docs/validation/landing-collage-${width}.png`});
  }
  await page.setViewportSize({width:390,height:844});
  await page.evaluate(()=>document.querySelector('flt-semantics-placeholder')?.click());
  await page.getByRole('button',{name:'Get started',exact:true}).click();
  async function fill(label,value) {
    const field = page.getByRole('textbox',{name:label,exact:true});
    await field.click();
    await page.keyboard.press('Control+A');
    await page.keyboard.type(value, {delay:15});
    await page.keyboard.press('Tab');
    await page.waitForTimeout(100);
  }
  await fill('Full name','Animation Test');
  await fill('Email address','motion@example.com');
  await fill('Password','password123');
  await fill('Confirm password','password123');
  await page.getByRole('button',{name:'Create account',exact:true}).click();
  await page.waitForTimeout(300);
  await page.screenshot({path:'docs/validation/auth-gathering.png'});
  await page.waitForTimeout(650);
  await page.screenshot({path:'docs/validation/auth-ring.png'});
  await page.getByRole('tab',{name:'Home',exact:true}).waitFor({timeout:10000});
  console.log(JSON.stringify({errors,createdAccount:true}));
  await browser.close();
})();
