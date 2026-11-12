# Agent handoff — `BE-S2/S3`

| Field | Content |
|-------|---------|
| Task | BE-S2/S3 / Dashboard + Orders screens / module |
| Approved scope | Custom header + info cards; extract shared widgets; second screen reuses them |
| Paths | `lib/core/ui/widgets/app_header.dart`, `app_info_card.dart`, `features/dashboard/`, `features/orders/`, `test/screens_reuse_test.dart` |
| Decisions | Shared UI under `lib/core/ui/widgets` |
| Reuse | `AppHeader`, `AppInfoCard` |
| Done | Both screens compose shared widgets; reuse test written |
| Verified | `flutter test test/screens_reuse_test.dart` PASS; `flutter analyze lib` clean |
| Next | Verifier: confirm no duplicate AppBar/Card implementations in feature folders |
| Blockers | none |

Receiving agent: do not re-scan entire `lib/` unless contradiction found.
