// Pilote Chrome via le DevTools Protocol. Aucune dependance : Node >= 22 a un
// client WebSocket integre, donc ni playwright ni puppeteer ne sont necessaires.
//
//   node cdp.js eval  "<js>"            evalue du JS dans la page, affiche le retour
//   node cdp.js shot  <fichier.png>     capture l'onglet
//   node cdp.js goto  <url>             navigue et attend le chargement
//   node cdp.js size  <l> <h>           impose une taille de viewport (emulation)
//
// Variable d'env PORT_CDP pour changer le port de debug (defaut 9333).
const fs = require('fs'), http = require('http');
const PORT = Number(process.env.PORT_CDP || 9333);

const get = p => new Promise((res, rej) =>
  http.get({ host: '127.0.0.1', port: PORT, path: p }, r => {
    let d = ''; r.on('data', c => d += c); r.on('end', () => res(JSON.parse(d)));
  }).on('error', rej));
const sleep = ms => new Promise(r => setTimeout(r, ms));

(async () => {
  const [cmd, a, b] = process.argv.slice(2);
  const target = (await get('/json/list')).find(t => t.type === 'page');
  if (!target) { throw new Error('aucun onglet : Chrome est-il lance avec --remote-debugging-port=' + PORT + ' ?'); }

  const ws = new WebSocket(target.webSocketDebuggerUrl);
  let id = 0; const pending = new Map();
  ws.onmessage = e => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
  };
  await new Promise(r => ws.onopen = r);
  const send = (method, params = {}) => new Promise(r => {
    const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params }));
  });

  await send('Page.enable'); await send('Runtime.enable');

  if (cmd === 'goto') {
    await send('Page.navigate', { url: a });
    await sleep(2500); // laisse passer le splash screen et la tentative RPC
    console.log('loaded ' + a);
  } else if (cmd === 'size') {
    await send('Emulation.setDeviceMetricsOverride',
      { width: Number(a), height: Number(b), deviceScaleFactor: 2, mobile: true });
    console.log('viewport ' + a + 'x' + b);
  } else if (cmd === 'eval') {
    const r = await send('Runtime.evaluate', { expression: a, returnByValue: true, awaitPromise: true });
    if (r.result.exceptionDetails) { console.error('EXCEPTION', JSON.stringify(r.result.exceptionDetails)); process.exitCode = 1; }
    else { console.log(JSON.stringify(r.result.result.value)); }
  } else if (cmd === 'shot') {
    const s = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(a, Buffer.from(s.result.data, 'base64'));
    console.log('wrote ' + a);
  } else {
    console.error('commandes : goto | size | eval | shot'); process.exitCode = 1;
  }
  ws.close();
  process.exit(process.exitCode || 0);
})().catch(e => { console.error('FAIL', e.message); process.exit(1); });
