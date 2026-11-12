export function requireApiKey(headers, expected = 'eval-secret') {
  const key = headers['x-api-key'];
  if (!key || key !== expected) {
    return { ok: false, status: 401, error: 'unauthorized' };
  }
  return { ok: true };
}

export function requireNonEmptyString(value, field) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    return { ok: false, status: 400, error: `${field} required` };
  }
  return { ok: true, value: value.trim() };
}
