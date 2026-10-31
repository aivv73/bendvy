# Captured execution owners

`execution-capture` binds closed callback code to an actual affine context. Each invocation consumes that context and retains the context returned by the callback. `Capture.Local<State,Capture>` keeps Local and capture owners together.

The sequential bodies use opaque `F` and closed declaration `Effects<F>`. The framework supplies the effects implementation. Declarations retain exact resource routes and full component/resource layouts; bodies retain their original capture and error helpers.

## Ordinary scheduled application

[scheduled.bend](scheduled.bend) retains one World across three runs for each of two nominal schemas. Its nodes contain the actual declaration compilation and `Sys.Owner`. The registry dispatches one system at a time in authored left/right/other order. Both component stores are `Unit`; this consumer exercises resource ownership.

The left and other systems write Counter. The right system writes Score. Each resource and Local owns an Array, and each system retains its capture. Both Counter writers return `BodyError` on their second run after updating their resource and capture. The handler continues with the returned owners.

The migrated entry passed the development source check and stock Bend 2.0.37 JavaScript/native execution. Both complete two-line outputs matched the independently derived 1,138-byte expectation. Counter is 60 and Score 9; Local/capture observations are `501:3/201:6,601:3/202:axxx,801:3/203:6`; cursors are 7/8/9, World time 9 and handler errors 2. Evidence and exact artifact/source pins are retained in `/tmp/bendvy-sequential-return-evidence/captured-scheduled-runtime/RESULT.md`. This finite rendered observation does not cover unprinted World fields or establish whole-engine acceptance or performance.

From the repository root, using the qualified stock compiler:

```bash
BEND=/tmp/gh78-normal-examples-tool/extracted/bend/bin/bend
"$BEND" examples/captured-systems/scheduled.bend -o /tmp/captured-scheduled.js
node /tmp/captured-scheduled.js
"$BEND" examples/captured-systems/scheduled.bend -o /tmp/captured-scheduled.c
clang -std=c11 -O3 /tmp/captured-scheduled.c -lpthread -lm -o /tmp/captured-scheduled
/tmp/captured-scheduled --threads 1 --gpu off
```

## Condition and lifecycle application

[guarded.bend](guarded.bend) retains both Counter writers, the Score writer and a captured condition. Explicit dependencies place both Counter writers before the Score condition. The first condition call disables Score; its second call returns an error after updating its capture. Later condition calls permit Score.

[guarded-nodes.bend](guarded-nodes.bend) uses full-World generalized resource writers. Unsupported or unchanged resource edits return `BodyError` while preserving the actual scope, Local and capture. The final retained-carrier and resource-kernel entry passes source checking and stock Bend 2.0.37 JavaScript/native execution. Both complete 1,706-byte outputs match the unchanged independently source-derived expectation. Final source re-emission produces byte-identical JS/C artifacts to those executed; the final core/source guard passes. The initial cleanup refusal remains recorded separately; restoration uses the actual retained compilation and all existing lifecycle checks. Evidence is in `/tmp/bendvy-sequential-return-evidence/captured-guarded-current-runtime/RESULT.md`.

The scenario retains all five runs: after the third run it retires the actual Score owner, invokes the schedule while that registration is absent, restores the owner, then invokes the schedule again. Its adapter carries the actual compilation through existing `execution-system-lifecycle` retirement/restoration checks. Identity, cursor and Local are retained across refusals and restoration. Final retirement and release return the actual Local and identity. There is no admission-cache or prepared-permit reconstruction.

The full observation includes World resources and cached views, registrations, clock, allocator, events, pending commands, Local/capture owners, cursors, handler and released identity. Historical values are preserved as evidence, rather than claimed as a new runtime result.

## Other consumers and controls

[capture-owner.bend](capture-owner.bend) invokes two unlike captured callbacks twice. [lifecycle.bend](lifecycle.bend) exercises the raw owner lifecycle, including refusal in another World and preservation of identity, cursor, Local and capture. Its migrated source check is separate from retained-node runtime acceptance.

[main.bend](main.bend) sequences Independent A/B then Guarded A/B. The two complete entries have separate sequential runtime receipts; the combined aggregate has not been rerun. `report-probe.bend` checks report formatting; it cannot establish owner lifecycle behavior.

Existing controls retain their intended boundaries: undeclared resource, write through read, abstract scope escape, cross-schema owner use, duplicate capture and duplicate Local. Historical diagnostics apply only to their recorded source; they do not qualify the current aggregate.

Historical parallel execution, worker observations and prior receipts are recorded in the [pinned predecessor README](https://github.com/dearlordylord/bendvy/blob/431266bac/examples/parallel-captures/README.md). They are not current APIs or sequential runtime evidence. Production golden files and `check.sh` were retired at the user's direction; this migration introduces no replacement law or test collection.
