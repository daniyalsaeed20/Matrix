# ECC Cherry-pick Origins

Adapted excerpts for the **m4tr!x** Cursor Org Kit.  
Upstream project: [affaan-m/ECC](https://github.com/affaan-m/ECC) (MIT License).

## Policy

- **No full ECC install** into Cursor projects.
- **No ECC hooks** in m4tr!x v1.
- Keep only stack-relevant, token-light adaptations under this folder.
- Agents/skills reference these files; they are not always-applied rules.

## Sources adapted

| Local file | Upstream (approx) |
|------------|-------------------|
| `flutter-patterns.md` | `skills/dart-flutter-patterns/SKILL.md` |
| `flutter-review-checklist.md` | `skills/flutter-dart-code-review` / `agents/flutter-reviewer.md` ideas |
| `python-patterns.md` | `skills/python-patterns/SKILL.md` |
| `security-checklist.md` | `rules/common/security.md` |
| `tdd-verify.md` | `skills/tdd-workflow` / verification-loop ideas (condensed) |
| `deployment-checklist.md` | `skills/deployment-patterns/SKILL.md` |
| `karpathy-principles.md` | [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT) — principles merged into `04-code-craft.mdc`; this file is on-demand reference only |
| `context-engineering.md` | [jasontang-ai/Context-Engineering](https://github.com/jasontang-ai/Context-Engineering) (MIT; Copyright davidkimai) — progressive context / prune / task memory ideas merged into `03-token-discipline.mdc` + ACTIVE_TASK/HANDOFF; do not vendor the course |
| `egm.md` | [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (Apache-2.0) — Elephant/Goldfish planning review mapped to pipelines + `egm-review` skill; do not install the upstream plugin |

## Attribution

Copyright and license remain with ECC contributors under MIT.  
Karpathy-inspired guidelines: MIT via multica-ai/andrej-karpathy-skills (derived from Andrej Karpathy’s public observations).  
Context-engineering handbook ideas: MIT via jasontang-ai/Context-Engineering (davidkimai).  
m4tr!x adaptations are organizational wrappers for Cursor Pro / Flutter-first workflows. Do not vendor full upstream repos.
