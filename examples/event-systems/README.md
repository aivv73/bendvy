# Ordinary event families

`main.bend` runs five sequential schedule updates for Data events and affine
`Array<U32>` events under two nominal schemas. The four cases share the same
publisher, independent fast and slow readers, admin, peer, and registered condition.
The condition skips the slow reader twice. `cases/A-affine-future.bend` keeps the
additional Future-fast reader case.

Each registered system retains its actual Compilation and Local owner in the
common registry. Declarations select capabilities over the complete World shape.
Gameplay bodies compose their existing operations through the framework's
abstract effect. One schedule entry returns the updated owners after each update.
The event-family resource is one canonical slot.

The publisher sends directly into that slot. Its first invocation publishes two
payloads and then returns a handled body error. Both publications remain visible
to later systems in the same update. Event publication does not wait for a
structural command barrier.

The log owns each payload once. Its refresh constructs a Data view while returning
each payload owner to the log. Refresh runs at initialization and writable
operations. Reader capabilities use the cached view and advance their own affine
reader token in Local. A reader receives no payload projector.

The event wrappers use the actual resource grant. A writer returns a publication
ID or the refused payload. The admin returns registration and removal tokens or
retired payload rows. These outcomes retain arbitrary affine Type payloads.
`execution-event-io.bend` allocates real log identities through the World namespace
allocator. The foreign reader comes from a second actual allocation and registration.

The complete trace includes progress before handled errors, resumed execution,
retention lag, retained and future reader creation, removal, foreign-log refusal,
shutdown, publication refusal, reused returned payloads, canonical cache, system
cursors, access metadata, condition count, peer count, and handler capture.

The pinned Bevy behavior references are
[`get_cursor` and `get_cursor_current`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L172-L184),
[`MessageIteratorWithId`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/iterators.rs#L54-L99),
and [`update_drain`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs#L187-L218).
A returned body error does not rewind a reader token. Bend returns retired and
shutdown owners explicitly. This does not establish universal Rust Drop equivalence.

The existing controls cover undeclared reads, writes through read authority,
nominal schema and family mismatches, reader and payload duplication, abstract
scope escape, and an affine payload proposed as a Data view. A parser or missing
symbol failure does not qualify one of those authority refusals.

Use the compiler pinned by the current CI. For an installed Bend executable and
clang 19, the ordinary commands are:

```bash
bend examples/event-systems/main.bend -o /tmp/event-systems.js
node /tmp/event-systems.js
bend examples/event-systems/main.bend -o /tmp/event-systems.c
clang-19 -std=c11 -O3 /tmp/event-systems.c -lpthread -lm -o /tmp/event-systems
/tmp/event-systems --threads 1 --gpu off
```

Source-only checking names the explicit foreign World and event identity
allocation chains. Executable emission checks the complete entry. Finite runtime
observations do not establish a universal proof. Historical execution receipts
belong to their original Git sources and are not evidence for this migration.
