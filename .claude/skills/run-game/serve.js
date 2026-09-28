// Sert la racine du repo en HTTP. Aucune dependance : le projet n'a pas de
// node_modules installe et le jeu n'a pas d'etape de build.
// Usage : node serve.js [racine] [port]
const http = require('http'), fs = require('fs'), path = require('path');

const ROOT = path.resolve(process.argv[2] || process.cwd());
const PORT = Number(process.argv[3] || 8731);
const TYPES = {
  '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript',
  '.json': 'application/json', '.svg': 'image/svg+xml', '.png': 'image/png',
  '.jpg': 'image/jpeg', '.mp3': 'audio/mpeg', '.ogg': 'audio/ogg',
  '.woff2': 'font/woff2', '.woff': 'font/woff', '.ttf': 'font/ttf',
  '.eot': 'application/vnd.ms-fontobject'
};

http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/play/index.html';
  const f = path.join(ROOT, p);
  // On sert depuis la racine du repo, pas depuis play/ : all.min.css pointe
  // ses polices vers ../webfonts/, qui est au niveau du repo.
  if (!f.startsWith(ROOT) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) {
    res.writeHead(404); return res.end('not found');
  }
  res.writeHead(200, { 'Content-Type': TYPES[path.extname(f)] || 'application/octet-stream' });
  fs.createReadStream(f).pipe(res);
}).listen(PORT, () => console.log('serving ' + ROOT + ' on http://127.0.0.1:' + PORT));
