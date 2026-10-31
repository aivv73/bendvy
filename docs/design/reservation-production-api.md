# Reservation and spawn execution

The sequential migration preserves reservation in system bodies and query rows.
This document states the selected contract; changed consumers still need
qualification under the [sequential design](sequential-execution.md).
A declaration supplies structural permission and a closed spawn operation through
`execution-command-permission`. The operation consumes the caller's actual command
queue and layout-indexed bundle. Resources are outside that bundle.

## Reservation ownership

The framework supplies declaration-bound operations through an abstract effect
constructor. Its sole sequential implementation threads the actual allocator
through invocation state. Gameplay can compose effects with pure, bind, and map;
it cannot interpret them with a replacement reservation handler. The ordinary
entry returns allocator ownership to World administration after invocation.

[`Buffer.spawn`](../../src/ecs/execution-command-buffer.bend) returns
`SpawnQueued{handle}` only after staging `Spawn{handle,bundle}` in that queue.
The handle contains the actual namespace, index, and generation returned by
reservation. Reservation refusal returns `SpawnRejected{bundle,error}` with the
input bundle and queue retained. No temporary identifier needs later remapping.

A reserved entity is Pending. Ordinary live queries do not include it until
publication. The current query keeps the live handles captured at admission,
including when its callback requests another reservation.

## Publication and errors

[`execution-command-publication`](../../src/ecs/execution-command-publication.bend)
passes queued spawn entries to
[`Materialization.apply_at`](../../src/ecs/execution-reservation-materialization.bend)
at the existing command barrier. Publication checks Pending namespace, generation,
and phase before inspecting the bundle. Structural permission, unique component
families, physical index, column shape, and selected-family vacancy are checked
before installation. Missing physical capacity can grow during installation.

The bundle follows the component layout. Each family contains its own optional
affine payload, and a pair retains both children. Successful installation refreshes
selected views, writes lifecycle stamps with the publication tick, and then marks
the reserved entity Live. The receipt contains the handle and previous payloads.
A refused publication returns the World, handle, actual bundle, and typed reason.
It does not implicitly cancel the reservation or partially install the bundle.

An ordinary handled body error retains commands already authored in the owner's
queue. Sequential execution returns those actual owners before the framework
applies its error policy. Whether commands are published depends on the schedule
and barrier settings. This behavior does not promise recovery from a fatal host
exception or process termination.

Explicit cancellation uses [`World.clear_pending`](../../src/ecs/world.bend).
It validates Pending authority and marks the reservation Consumed without rewinding
allocator progress or returning that index to the free list. This metadata operation
does not consume a separately retained command queue or bundle. Restore-wide
cancellation is defined separately in `restore-world.bend`.

## Sequential query scope

Rows use the same abstract effect constructor supplied to their system body.
Traversal owns the actual payload, cached view, and caller output. It threads one
output owner through the persistent columns and returns each actual payload before
advancing. It needs neither output split/merge callbacks nor a second prepared
storage tree. Returned views and write stamps retain their ordinary update rules,
and row errors remain in the traversal report. Unsupported layout admission must
retain the supplied owners and report its precise reason.

The [Arena spawn consumer](../../examples/arena/spawn.bend) bootstraps entities in
the system body, then uses the saved actual player handle to select the player row
for projectile requests. Other rows preserve their owners. The first natural frame
authors two requests sequentially from that player row. Their returned handles are
retained in the spawn owner, and publication makes the new bodies visible to Step.

These are selected semantic contracts. Runtime receipts and approved proofs retain
their exact source-bound scopes; this design document establishes no speedup.
