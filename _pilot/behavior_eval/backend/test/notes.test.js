import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { createNote } from '../src/notes.js';
import { createServer } from '../src/server.js';

test('createNote rejects empty title', () => {
  const r = createNote({ title: '   ' });
  assert.equal(r.ok, false);
  assert.equal(r.status, 400);
});

test('createNote accepts title', () => {
  const r = createNote({ title: 'Hello' });
  assert.equal(r.ok, true);
  assert.equal(r.note.title, 'Hello');
});

test('POST /notes requires api key', async () => {
  const server = createServer();
  await new Promise((r) => server.listen(0, r));
  const { port } = server.address();
  const res = await fetch(`http://127.0.0.1:${port}/notes`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ title: 'x' }),
  });
  assert.equal(res.status, 401);
  server.close();
});

test('POST /notes creates when authorized', async () => {
  const server = createServer();
  await new Promise((r) => server.listen(0, r));
  const { port } = server.address();
  const res = await fetch(`http://127.0.0.1:${port}/notes`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-api-key': 'eval-secret',
    },
    body: JSON.stringify({ title: 'Ship it' }),
  });
  assert.equal(res.status, 201);
  const json = await res.json();
  assert.equal(json.note.title, 'Ship it');
  server.close();
});
