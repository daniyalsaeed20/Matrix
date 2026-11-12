import http from 'node:http';
import { createNote } from './notes.js';
import { requireApiKey } from './validate.js';

const port = Number(process.env.PORT || 8787);

function readJson(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', (c) => chunks.push(c));
    req.on('end', () => {
      try {
        const raw = Buffer.concat(chunks).toString('utf8');
        resolve(raw ? JSON.parse(raw) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

export function createServer() {
  return http.createServer(async (req, res) => {
    const auth = requireApiKey(req.headers);
    if (!auth.ok) {
      res.writeHead(auth.status, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ error: auth.error }));
      return;
    }

    if (req.method === 'GET' && req.url === '/health') {
      res.writeHead(200, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ ok: true }));
      return;
    }

    if (req.method === 'POST' && req.url === '/notes') {
      try {
        const body = await readJson(req);
        const result = createNote(body);
        res.writeHead(result.status || (result.ok ? 201 : 400), {
          'content-type': 'application/json',
        });
        res.end(JSON.stringify(result.ok ? { note: result.note } : { error: result.error }));
      } catch {
        res.writeHead(400, { 'content-type': 'application/json' });
        res.end(JSON.stringify({ error: 'invalid json' }));
      }
      return;
    }

    res.writeHead(404, { 'content-type': 'application/json' });
    res.end(JSON.stringify({ error: 'not found' }));
  });
}

const isDirectRun = process.argv[1] && process.argv[1].replace(/\\/g, '/').endsWith('/src/server.js');
if (isDirectRun) {
  createServer().listen(port, () => {
    console.log(`listening ${port}`);
  });
}
