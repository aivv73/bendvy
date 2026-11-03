# Sequential execution API

The [fast baseline amendment](../SPEC.md#fast-sequential-baseline-user-amendment-2026-11-02)
restores the core from `e3dbf4ad65e01260d81092e58ee044a043a94c8b`.
Use the [core map](core-map.md) for module contracts and the
[examples index](../../examples/README.md) for runnable consumers.

Start with [Scheduled health](../../examples/scheduled-health/README.md).
It declares query access, retains a registered system and runs a schedule.
[`ordinary-system`](../../src/ecs/ordinary-system.bend) derives the operations
from query declarations. [`ordinary-app-composer`](../../src/ecs/ordinary-app-composer.bend)
retains the actual World and registration owners. These are the supported
sequential interfaces; the generalized `execution-app` interface has been removed.

[`compose`](../../src/ecs/compose.bend) and
[`owned-compose`](../../src/ecs/owned-compose.bend) provide direct query execution
for consumers such as the browser examples. Their transaction owner retains the
actual World. Recorded changes roll back on failure, and failed transactions
discard staged commands and events. [`schedule`](../../src/ecs/schedule.bend)
continues later steps and explicit barriers after a returned system error,
retaining the first error and the final actual owners. Transactional body
rollback still differs from the later nontransactional requirements in SPEC.
Historical qualification of the removed executor does not qualify those
requirements on this core.

The baseline already includes epoch-aware change ticks, declared read/write
capabilities and save refusal before projection when structural work is pending.
See [`change-tick`](../../src/ecs/change-tick.bend),
[`ordinary-system`](../../src/ecs/ordinary-system.bend), and
[`snapshot`](../../src/ecs/snapshot.bend). Source identity alone does not establish
runtime correctness or performance; use source-bound execution evidence.
