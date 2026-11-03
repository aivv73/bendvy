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
retaining the first error and the final actual owners.

Ordinary component/captured queries, whole/field resource systems and resource
Local systems select preserving completion instead. Performed writes, authored
commands and Data events survive a returned body error; the original error
remains and failed outputs are discarded. Commands still require an explicit
barrier. Inverse journals are still built during execution. Linked-cleanup and
owned-event completion remain outside this port.
Historical qualification of the removed executor does not qualify those
remaining requirements on this core.

[`ordinary-lifetime-scope`](../../src/ecs/ordinary-lifetime-scope.bend) also retains
authored spawn/cleanup commands on returned body errors. The original error remains
and failed outputs are discarded; the next explicit barrier applies the retained
commands in order. Direct transaction helpers retain rollback.

[`ordinary-reader-system`](../../src/ecs/ordinary-reader-system.bend) retains
performed writes, reservations, authored commands and events after a returned body
error. Its failure result retains the original error and affine callback output.
Reader acknowledgement and the after-success hook still run only on success.

This completion boundary follows Bevy's
[single-threaded executor](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L132-L166),
which passes the live World to a system, handles its returned error, and retains
that system for later deferred application. It does not restore a World snapshot
when the body returns an error.

The baseline already includes epoch-aware change ticks, declared read/write
capabilities and save refusal before projection when structural work is pending.
See [`change-tick`](../../src/ecs/change-tick.bend),
[`ordinary-system`](../../src/ecs/ordinary-system.bend), and
[`snapshot`](../../src/ecs/snapshot.bend). Source identity alone does not establish
runtime correctness or performance; use source-bound execution evidence.
