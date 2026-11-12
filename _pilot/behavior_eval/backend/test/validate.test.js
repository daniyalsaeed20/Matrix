import test from 'node:test';
import assert from 'node:assert/strict';
import { requireApiKey, requireNonEmptyString } from '../src/validate.js';

test('requireApiKey rejects missing key', () => {
  const r = requireApiKey({});
  assert.equal(r.ok, false);
  assert.equal(r.status, 401);
});

test('requireApiKey accepts expected key', () => {
  const r = requireApiKey({ 'x-api-key': 'eval-secret' });
  assert.equal(r.ok, true);
});

test('requireNonEmptyString trims', () => {
  const r = requireNonEmptyString('  hi  ', 'title');
  assert.equal(r.ok, true);
  assert.equal(r.value, 'hi');
});
