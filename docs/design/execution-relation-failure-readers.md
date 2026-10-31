# Protected relation failure readers

The closed declaration produces an opaque failure-read capability and its read
footprint. The capability accepts abstract H and the retained affine Reader,
then returns H and a channel reading. It exposes neither the graph owner nor a
payload transform.

Selection requires the complete schema, route, grant validity, descriptor,
payload, view and protected-policy evidence. The resource equality binds the
local resource owner to that complete layout. No type is recovered from a policy
tag, key string or entity index. ReadOnly access uses the actual Store's Data
snapshot, including its graph, failure channel, sequence and reader counter.
The provider captures the actual scope tick without exposing the writable slot.

## Reader ownership

Trusted setup registers a Reader from the actual canonical Store. Registration
preserves graph, stamp, failure sequence and channel, advances its independent
reader counter and refreshes the snapshot. A refused interpreted relation
operation refreshes the snapshot from the returned Store while preserving its
graph stamp and complete refusal receipt.

The Reader stays in affine Local. Invocation advances its cursor before calling
the body and retains the returned cursor on BodyError. Conditions run first.
A false condition cannot invoke that body or advance its Reader. Foreign-reader
refusal must return the actual Reader and scope unchanged.

Delivered messages retain complete original operations, handle namespaces,
indices and generations, descriptor and error fields. The channel sequence and
returned Reader cursor are distinct observations. The API assigns no per-message
sequence IDs.

## Finished retention

The schema-bound retention catalogue carries closed typed callbacks and a
deduplicated route manifest. Admission checks coverage of every actual protected
relation leaf. It refuses incomplete coverage. Each callback separately needs
actual payload, view and policy evidence.

The owned completion hook composes lifecycle maintenance and failure-channel
rotation once after overall Finished, including when finalApply is false.
Stopped and Invalid retain their actual returned state and pending work.
Retention does not advance the World clock or any Reader, and preserves graph,
graph cache, resource stamp, failure sequence and reader allocator.

Two completed updates at one administrative tick still rotate twice. The shared
channel uses the same sequence-based two-generation policy as machine streams.
Pinned Bevy supplies
[reader semantics](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/message_cursor.rs)
and [generation maintenance](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/message/messages.rs).
Affine Local ownership and explicit refusal inventories are Bendvy contracts.

## Qualification scope

Existing [relation consumers](../../examples/relation-systems) retain real Schema
provisioning, original Context admission, actual registered command and reader
owners, handled body errors, final-publication suppression and successive
Finished retention. The two-reader scenario retains independent readers of the
same family and distinct affine Sessions. Sequential invocation must preserve
both complete delivered message lists and independent cursors.

The [historical observations](https://github.com/dearlordylord/bendvy/blob/431266bac456c5e3cf2f2bbf97d512ae1e7f5a65/docs/design/execution-relation-failure-readers.md)
record finite pre-migration outputs. They do not qualify the changed source.
Integrated checks of the migrated readers and completion wiring remain pending.
No new mathematical law or proof is claimed.
