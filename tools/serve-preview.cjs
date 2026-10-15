// Serve the compiled Flutter app for the VS Code Mobile Preview extension.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../build/web');
const types = {'.html':'text/html', '.js':'application/javascript', '.json':'application/json', '.wasm':'application/wasm', '.png':'image/png', '.jpg':'image/jpeg', '.ttf':'font/ttf', '.css':'text/css'};
const port = Number(process.env.PORT || 8080);
http.createServer((req, res) => {
  let filename;
  try { filename = path.resolve(root, '.' + decodeURIComponent(new URL(req.url, 'http://localhost').pathname)); }
  catch { res.writeHead(400).end(); return; }
  if (!filename.startsWith(root + path.sep) && filename !== root) { res.writeHead(403).end(); return; }
  if (filename === root || filename.endsWith(path.sep)) filename = path.join(filename, 'index.html');
  fs.readFile(filename, (error, data) => {
    if (error) { res.writeHead(404).end('Not found'); return; }
    res.writeHead(200, {'Content-Type': types[path.extname(filename)] || 'application/octet-stream', 'Cache-Control':'no-cache'});
    res.end(data);
  });
}).listen(port, '127.0.0.1', () => console.log(`FurU preview: http://localhost:${port}`));
