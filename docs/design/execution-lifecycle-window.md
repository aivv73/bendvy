> Historical verification record (2026-10-27). The then-new models, reference tests, golden outputs, and check scripts were retired at the user's direction. References to those checks describe historical work, not current acceptance. Current verification follows [agent workflow](../agent-workflow.md). Approved helper laws do not prove the whole ECS.

# Captured execution window

Each admitted system receives its previous execution cursor and its current
execution tick in its owned `State.Scope`. The cursor is `Maybe<Tick>` because
`None` means never executed and tick zero is a valid timestamp.

The sequential system entry takes the previous cursor from the actual system
owner before entering the run. Conditions are system owners too and receive
their own previous cursor. Neither reads a cursor from another body or condition.
The owner advances to the captured current tick after every normal body return,
including a returned error. Admission refusal leaves its cursor unchanged.

Access adapters and query adapters preserve both values while moving affine
storage. Each selected system receives its own admitted window before execution.
Query traversal uses that single captured write tick throughout the invocation.

The sequential migration must preserve full tick epoch and low values, absent
stamps, legitimate zero ticks, and dormant cursors. Two-schema authority,
retained-error, refusal, and lifecycle consumers require source-bound checks on
the changed implementation. No new law or universal owner-preservation claim is
introduced here.

## Query filters

Added and Changed filters select rows by the written family of the closed query
pair. Both filters use the
actual system cursor and captured execution tick. The filter runs against the
row's stamp before its callback writes; refused rows keep their payload, cached
view, stamps and output channel. This adds no raw lens, metadata callback or
caller-supplied cursor to gameplay. Read-family and compound filters are not
provided by this entry.

The eligibility check runs in the same physical leaf traversal that owns the
component payload and stamp arrays. Sequential traversal threads one output
owner through the selected rows and retains unselected payloads and metadata.

The [lifecycle filter consumer](../../examples/lifecycle-systems/filters.bend)
exercises two nominal schemas, affine Array payloads, legitimate zero seed ticks,
and refusal against a genuine second World. Historical backend observations
remain bound to their original source. They do not qualify the changed traversal.
