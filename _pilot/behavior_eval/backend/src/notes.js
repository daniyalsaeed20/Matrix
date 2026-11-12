import { requireNonEmptyString } from './validate.js';

export function createNote(payload) {
  const title = requireNonEmptyString(payload?.title, 'title');
  if (!title.ok) return title;
  return {
    ok: true,
    status: 201,
    note: { id: 'n1', title: title.value },
  };
}
