> Historical verification record (2026-10-27). The then-new models, reference tests, golden outputs, and check scripts were retired at the user's direction. References to those checks describe historical work, not current acceptance. Current verification follows [agent workflow](../agent-workflow.md). Approved helper laws do not prove the whole ECS.

# Deferred command ownership

The GH86 modules retain actual affine command payloads separately from gameplay
storage. Closed command-system registration and publication adapters are
implemented, including ordinary scheduler barriers and final-application settings.
Explicit structural despawn and query command authoring are implemented. Removal
notices, worker evidence and full issue acceptance remain pending.

`execution-command-buffer.bend` owns one component family's pending inserts and
removes, and explicitly granted entity despawns. Its removed-owner type is derived
from the complete schema: optional raw owners at leaves and products at branches. Enqueue transfers an incoming `Type` payload into the queue. It cannot
change storage. Publication checks the handle's namespace, generation and live
allocator slot, then applies commands in that buffer's enqueue order. Successful
commands return displaced or removed owners in receipts. Refused commands return
the incoming owner. Receipts remain owned by the buffer until taken.

`execution-command-local.bend` places the buffer beside the system's user local
owner. Its body adapter hides both the gameplay scope `H` and queue `Q`. Gameplay
gets typed insert/remove methods; it cannot inspect the concrete queue or supply
a World callback. The existing `Sys.Owner` returns this local on a body error or
admission refusal. `execution-command-system.bend` wraps that system in a
distinct `Owner` indexed by its complete schema and command route. Registration
binds the canonical concrete queue and command capability before provisioning
query grants. Runtime grants are monomorphic in that queue; the public command
body still receives a hidden `Q` and returns its actual owner.
The retained command leaf binds the full World layout to the same schema and
derives its deferred system ID from the actual registration. Registry composition
retains the actual command owners alongside ordinary owners.

A declaration requests entity commands through a second abstract affine book `K`,
separate from the physical scope Builder book `B`. The closed entity grant
advances `K` and returns the typed despawn capability together. The adapter derives
permission from that same returned book and persists it beside the actual queue
and user local. Family-only command capabilities have no despawn method. This
permission inventory does not claim physical ownership of unrelated scope data.
Raw constructors remain trusted administrative provisioning; constructor secrecy
is not an authority guarantee. Admission, invocation and publication validate
the persisted permission against the owner's same closed program, without World
projection. A mismatched cache refuses before the affected body or clock advance.

The publisher initializes the schema's cached Data view only for an admitted
insert. Removal unwraps a displaced owner without refreshing it. An absent
component outside the column's capacity is removed successfully without growing
storage. Capacity-refused insertions retain their raw incoming owners. A despawn requires
the actual owner's entity permission and a current live handle. The whole-World
publisher removes all component families without refreshing them, returns each
raw affine owner in the receipt, then releases the cleared allocator slot. Repeated
stale-handle commands produce refusal receipts. Removal notices remain a separate
publication-boundary integration.

`execution-command-lifecycle.bend` retires, restores and rebinds the same
program-indexed command owner. It validates the persisted permission before
metadata changes, retains the actual local queue and receipts, and returns the
actual detached owner on refusal. Rebuilding a Schedule can legitimately produce
empty admitted history beside a retained queue; its exact pending query still
reports that queue. The lifecycle consumer checks this case, metadata/cursor
preservation and registration-exhaustion refusal with actual affine payloads.

Publication receives the actual complete World. The allocator and administrative
state remain outside the gameplay scope, so a body cannot apply structural
commands directly or duplicate allocator ownership.

## Synchronization behavior

The reference is Bevy commit
[`ad678262ce53b5d142fe49ee5e08caff6f00ab60`](https://github.com/bevyengine/bevy/tree/ad678262ce53b5d142fe49ee5e08caff6f00ab60).
Its [single threaded executor](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs)
marks a system's deferred state as unapplied after a handled body error. Default
final application then publishes that state. Skipped systems do not newly author
commands. This does not establish equivalent behavior for a handler that panics.

`execution-deferred-plan.bend` follows the reference's
[automatic synchronization pass](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/auto_insert_apply_deferred.rs).
It accepts an already validated flattened DAG in topological order and derives
edge boundaries from synchronization distances. An ignored edge carries pending
synchronization forward; an exclusive target overrides edge suppression.
Unconditional explicit barriers can be reused. Disabling automatic insertion
returns no inserted boundaries; final application is a separate executor setting.
The closed registry derives `hasDeferred` from its actual command owners.
It checks eligible IDs and the actual World registration before inspecting
pending queues, so a foreign or unselected retained queue does not advance the
publication clock. The scheduler accumulates admitted, unapplied IDs across
groups until a synchronization boundary; a body error still counts as admitted.
This history can include commandless systems and is not a queue inventory.
`Schedule.pending` inspects all actual closed command owners without projecting
storage, checking World applicability or applying anything. It returns the actual
scheduled owner and exact nonempty-queue status, including retained foreign
queues omitted from the current admitted history.

Publication uses the compiled topological order of known pending systems.
Registration-product grouping cannot change that order when automatic boundaries
are suppressed or edges are ignored. Unknown pending IDs remain retained for
retry and cannot trigger a publication clock advance by themselves.

The [historical verification record](https://github.com/dearlordylord/bendvy/blob/431266bac456c5e3cf2f2bbf97d512ae1e7f5a65/docs/design/execution-command-ownership.md)
describes earlier planner, reference and backend observations. Those receipts do
not qualify the changed sequential source. Existing consumers retain the
handled-error, receipt, synchronization, suppression and pending-state scenarios
for integrated qualification. No new mathematical law is approved or proved by
this migration.
