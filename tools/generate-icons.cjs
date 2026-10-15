// Reproducible vector-drawn provisional FurU launcher mark.
const {chromium} = require(process.env.TEMP + '/furu-browser/node_modules/playwright');
const fs = require('node:fs');
(async () => {
 const browser = await chromium.launch({headless:true, executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 const page = await browser.newPage();
 async function icon(filename,size) {
   const png = await page.evaluate(size => {
     const canvas = document.createElement('canvas'); canvas.width=canvas.height=size;
     const c = canvas.getContext('2d'); c.scale(size/512,size/512);
     c.fillStyle='#234B3E'; c.fillRect(0,0,512,512); c.fillStyle='#F8F7F2';
     for(const [x,y,rx,ry,a] of [[145,214,32,43,-.45],[212,159,32,44,-.18],[292,159,32,44,.18],[361,214,32,43,.45]]) {c.beginPath();c.ellipse(x,y,rx,ry,a,0,Math.PI*2);c.fill();}
     c.beginPath();c.moveTo(256,230);c.bezierCurveTo(211,230,178,286,166,317);c.bezierCurveTo(141,374,215,385,256,360);c.bezierCurveTo(297,385,371,374,346,317);c.bezierCurveTo(334,286,301,230,256,230);c.fill();
     return canvas.toDataURL('image/png').split(',')[1];
   },size);
   fs.writeFileSync(filename,Buffer.from(png,'base64'));
 }
 for(const [density,size] of [['mdpi',48],['hdpi',72],['xhdpi',96],['xxhdpi',144],['xxxhdpi',192]]) await icon(`android/app/src/main/res/mipmap-${density}/ic_launcher.png`,size);
 const ios=JSON.parse(fs.readFileSync('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json','utf8'));
 for(const item of ios.images) await icon('ios/Runner/Assets.xcassets/AppIcon.appiconset/'+item.filename,Math.round(parseFloat(item.size)*parseFloat(item.scale)));
 for(const size of [192,512]) {await icon(`web/icons/Icon-${size}.png`,size);await icon(`web/icons/Icon-maskable-${size}.png`,size);}
 await icon('web/favicon.png',64);
 await browser.close();
})();
