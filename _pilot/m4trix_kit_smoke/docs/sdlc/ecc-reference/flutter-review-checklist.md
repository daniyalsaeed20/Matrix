# Flutter review checklist (adapted from ECC flutter-dart-code-review)

For **m4trix-verifier** / **m4trix-flutter** self-check.

- [ ] Null-safety: no reckless `!`; null paths handled in UI
- [ ] State: immutable; exhaustive handling of loading/error/data
- [ ] State management matches project (BLoC preferred for new; do not force migration)
- [ ] Widgets: class extraction; const; no giant build methods with business logic
- [ ] Navigation: deep links / auth guards correct if GoRouter present
- [ ] Async: mounted checks; no context across gaps
- [ ] Theme: uses design-system tokens/widgets — no rogue colors
- [ ] A11y: semantics / tap targets for new controls; reduced-motion / text scale considered when UI moves or wraps
- [ ] Motion: purposeful only; no decorative list/card entrance spam; prefer delete over polish when purpose is weak (`ui-craft.md`)
- [ ] Layout stress (new/significant UI, proportional): long labels, empty, large numbers, narrow width (`ui-stress.md`)
- [ ] Performance: unnecessary rebuilds avoided; lists use builders when large
- [ ] Security: no secrets; secure storage for tokens
- [ ] Tests cover changed AC or documented manual verification
