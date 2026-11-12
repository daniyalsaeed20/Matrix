import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const task = JSON.parse(
  fs.readFileSync(path.join(root, 'docs/sdlc/ACTIVE_TASK_STALE.json'), 'utf8'),
);

const updatedAt = new Date(task.context.updatedAt);
const ageHours = (Date.now() - updatedAt.getTime()) / 36e5;
const isStale = ageHours > task.context.staleAfterHours;

const stalePath = path.join(root, 'flutter_app', task.reusableComponents[0]);
const realHeader = path.join(
  root,
  'flutter_app/lib/core/ui/widgets/app_header.dart',
);

const result = {
  isStaleAdvisory: isStale,
  ageHours: Math.round(ageHours),
  staleComponentExists: fs.existsSync(stalePath),
  realSharedHeaderExists: fs.existsSync(realHeader),
  approvalIntact: task.approval?.by === 'captain' && !!task.approval?.at,
  securityDecisionRefKept: (task.decisionRefs || []).some((d) =>
    String(d).toLowerCase().includes('api-key'),
  ),
  preferredAction:
    'Treat ACTIVE_TASK memory as stale hint; trust realHeader path; keep approval + security refs',
};

const pass =
  result.isStaleAdvisory &&
  !result.staleComponentExists &&
  result.realSharedHeaderExists &&
  result.approvalIntact &&
  result.securityDecisionRefKept;

console.log(JSON.stringify({ pass, result }, null, 2));
process.exit(pass ? 0 : 1);
