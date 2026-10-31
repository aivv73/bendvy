# Deferred commands in ordinary sequential applications

[main.bend](main.bend) runs the five visibility scenarios in
[visibility.bend](visibility.bend). Each scenario updates the same application
twice. The command author removes a component, inserts an affine `Token` with
value `71`, and returns a handled body error after enqueueing. The returned
system keeps its command buffer. Enqueueing does not change World membership or
component values until a deferred application boundary runs.

The scenarios select these boundaries:

- `auto` inserts a deferred boundary before the dependent reader's
  condition. The condition and reader see the inserted value in the same update.
- `ignored` suppresses that dependency boundary. Final application remains
  enabled, so the first condition sees the old value and skips the reader.
- `explicit` disables automatic boundaries and places an explicit boundary
  before the reader. The reader sees the commands in the same update.
- `disabled` disables automatic boundaries and keeps final application.
- `finaloff` suppresses the dependency boundary and final application.
  Both updates retain their queued commands and skip the reader.

Each system owns its buffer. Publication follows the compiled sequential order
and preserves each buffer's local enqueue order.
The observer reads the returned World, component owners and caches, system
cursors, command queues, and displaced-owner receipts. The current five-line,
3,642-byte output matches on JavaScript and native execution. The expectation
comes from the historical full observation and the changed source ordering;
the final-disabled unapplied-ID field was corrected from the scheduler source
after an initial comparison failed. This is a finite application result.

[ordinary.bend](ordinary.bend) separately exercises final application, retained
queues, empty queues, and serial execution. [foreign.bend](foreign.bend) retains
queued commands across a foreign-World refusal, then restores the original
World for application. [invalid.bend](invalid.bend) rejects unknown or duplicate
explicit boundaries, conditioned explicit boundaries, and unknown ignored
edges before running the application.

The [query command example](../query-systems/commands.bend) authors insert,
remove, and despawn commands from sequential query callbacks with an owned
buffer. Its final receipts include the incoming affine payload refused after a
preceding despawn, as well as the owners returned by successful commands.

```sh
bend examples/command-systems/main.bend -o /tmp/bendvy-command-visibility.js
node /tmp/bendvy-command-visibility.js
```

## Generalized-root spawn application

[generalized-root.bend](generalized-root.bend) runs one retained command author
beside a resource-query peer through the generalized Root. The author owns a
heterogeneous spawn bundle containing an affine Array with value `901`.

The application keeps its original schema-created Context in a Bound value.
It first attempts an update with the Context of a second, genuinely created
World of the same nominal schema. Root refuses before execution. The returned
application still has an empty queue, an unrun author, and clock `0:0`.
The program then deliberately restores its original Context to that same
returned application.

The first admitted update authors Spawn21 and returns a body error. Its error
handler escalates. The Stopped result retains the actual queued bundle and
author cursor `0:3`; it does not apply the command. The next update enables
final application and produces a Spawned21 receipt. The final update exercises
a condition error while the peer still runs. Terminal observation reads the
actual spawned Array and its cached view, both `901`, and the peer's retained
capture `200`. Intermediate command snapshots preserve each node's inspected
or prepared state, evidence, permits and provenance.

Run the ordinary application with Bend's JavaScript output:

```sh
bend examples/command-systems/generalized-root.bend -o /tmp/bendvy-commands.js
node /tmp/bendvy-commands.js
```

This is a finite application observation. It does not prove generic affine
preservation, native concurrency, or all exceptional exits. The default bound
entry uses lifecycle maintenance only. Framework callers that also maintain
protected relation streams can supply their closed whole-update callback to
`Root.run_bound_with_completion`; the same context preflight precedes it.
