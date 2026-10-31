# Python patterns (adapted from ECC python-patterns)

For **m4trix-python** when captain approved Python. Keep explanations practical (Flutter-first captain).

## Essentials

- Readable > clever; type-hint public functions
- Specific exceptions; chain with `from e`; no bare `except`
- `with` for files/resources
- No mutable default args
- Dataclasses / clear models for data
- `pytest` for critical logic
- Secrets via env; validate required env at startup
- Prefer `pathlib.Path`, f-strings, `isinstance` / `is None`

## Layout hint

```text
src/pkg/ ...
tests/
pyproject.toml or requirements.txt
```
