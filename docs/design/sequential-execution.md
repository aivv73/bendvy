# Sequential ordinary execution

Historical design of the generalized executor removed by the
[fast baseline amendment](../SPEC.md#fast-sequential-baseline-user-amendment-2026-11-02).
This document describes the previous implementation. Use the
[current execution API](../reference/execution-api.md) for supported modules.

The 2026-10-31 user decision replaces the execution mechanism while preserving
modern ECS behavior. [SPEC](../SPEC.md#sequential-execution-user-amendment-2026-10-31-utc)
defines the contract. Historical experiments do not qualify a changed executor.

## One abstract effect, one sequential implementation

A body quantifies an effect constructor `F:Type -> Type`, its framework-supplied
operations, its abstract scope, and its declared capabilities. It returns
`F(H & (Local & Completion))`. Effect operations provide `pure`, `bind`, and
`map`. They do not provide an interpreter, an unwrap, a raw allocator, or a way
to replace the framework's representation. Capabilities use the same `F`.

The framework instantiates `F` as one sequential state function. Its actual
invocation state owns the allocator and reservation authority. The system entry
interprets that function once with the real state. No task tree, execution
policy, branch driver, or second executor is needed. User bodies can compose
operations without seeing the allocator or manually splitting their World.

The framework performs namespace, registration, and declared-access admission
before entering the run clock. Admission refusal returns the incoming World and
system without invoking the body. An executed body error retains writes, Local,
captures, readers, and commands. Both successful and failed executions update
the cursor. App lifecycle maintenance follows execution, never admission refusal.

## Reservation keeps actual authority

A declared spawn capability returns an effect containing the command buffer and
actual bundle or admission result. Its implementation captures the closed
permission supplied by the framework. Reservation validates namespace, registered
system identity, and structural permission against the actual invocation owner.
A denied request returns useful owners without advancing the allocator.

Query rows use the same enclosing `F`. A row temporarily owns its selected
payload, while the framework sequences reservation state internally. Gameplay
receives neither a complete scope beside an extracted component nor a
caller-selectable allocator callback.

Declarations receive the framework's closed composition operations for their
abstract `F`. They bind those operations into their row callbacks at construction.
The dictionary is not a runtime affine row argument. This lets a row compose a
dynamic sequence of operations using the same closed witness, while keeping `F`
abstract and its interpreter unavailable to gameplay.

A public state-function alias is insufficient confinement. If gameplay can run
an effect with a fake reservation handler, it can recover the genuine command
buffer containing a forged spawn entry. An abstract permit alone does not stop
that handler from ignoring its argument. Keeping `F` abstract and exposing only
composition operations closes that path. Raw trusted constructors do not replace
the ordinary capability boundary.

## Direct storage and ordered scheduling

The ordinary schedule executes admitted systems in its selected dependency order.
Conditions, error handling, and synchronization remain explicit transitions.
The [condition contract](execution-conditions.md) relates these transitions to
the pinned Bevy executor.
A dependency provides completion and visibility even when the predecessor returns
an error. Commands apply at required dependency boundaries and the final boundary
unless explicitly suppressed.

At a publication boundary, known pending systems apply in the compiled
topological order, including when automatic boundaries have been suppressed.
The schedule retains that order when it builds the graph. Each selected ID
routes to its actual command owner. Unknown pending IDs remain available for
retry in their original order and multiplicity; they cannot trigger publication.

Queries traverse actual persistent columns sequentially. They thread one output
owner through rows. They do not prepare a second indexed owner tree or perform a
storage cut and rejoin cycle for concurrent invocation. Common lookup and ownership
helpers remain only when an ordinary consumer needs them.

Point access still describes the complete component layout to evaluate bound
selection before reading or modifying its selected column. That description
constructs cached rows and views for all families on each point access. Removing
parallel preparation does not establish cheap point lookup or eliminate this
repeated work. This remains a known limitation of the sequential query path.

## Shared fixes retained in the simpler structure

The migration keeps changes that enforce ordinary ECS behavior or remove
unnecessary work independently of concurrent execution. It does not infer a
measured speedup from these structural changes.

| Retained change | Why sequential execution still needs it |
| --- | --- |
| Actual Compilation, schema and permission admission before clock entry | Sequential access still needs the declared authority. A refused system must retain its original World, owner and cursor. |
| Separate invocation administration and detached lifecycle view | Returning a user scope must not replace the authoritative journal or allocator. |
| Full tick and prior-cursor representation | Sequential Added/Changed selection must preserve absent stamps, low ticks and epochs. |
| One effectful column-edit implementation with a pure identity specialization | Both APIs retain the same payload, stamp and refusal behavior without two copies of storage mutation. |
| One validated column shape per row traversal | Row updates preserve the shape; rescanning the whole column for each row is unnecessary. The reusable shape contains no affine payload owners. |
| Direct default traversal of all matched rows | An already selected row does not need another generated target list and repeated membership search. Explicit targets still require their own validation. |
| Closed effect composition in declarations and bodies | Recursive command authoring composes operations without exposing allocator state or consuming a runtime dictionary repeatedly. |
| Retained compiled dependency graph | Construction and configuration build the graph; ordinary updates reuse it. Changing final publication alone does not rebuild dependency metadata. |
| Direct full-resource association | Resource capabilities retain the exact equality with the complete resource layout. Removing the obsolete representation selector removes specialization of an unused branch. Concrete consumers must still qualify against the unchanged compiler limits. |
| Restore the retained Compilation | Restoring a registered owner uses its actual selected interpreter and checks its support and access metadata. Rebuilding through a different default provider can refuse a valid retained owner. The same Compilation is returned on success and refusal. |
| One opaque retained binding | The actual Compilation and owner stay together behind a common existential carrier. This keeps application builders and scheduler continuations from expanding every system's complete state. The original seven-system linked example emits native C with the stock compiler after this change. Runtime qualification is separate. |

The invocation admits one system identity, represented by an optional identity
rather than a list of parallel issuers. Dependency order and deferred visibility
reuse the existing plan and executor. Neither requires physical owner partitions.

Events, lifecycle notices, relations, lifetime cleanup, machines, feature
provisioning, passive inspection, and save/restore retain their current semantic
contracts. Save refuses nonempty structural pending work before projection.
Restore honors saved allocator and clock floors.

## Migration and verification

Migrate actual consumers with changed signatures. Remove superseded execution
implementations, exports, policies, and entry points together. Descriptive example
names identify their behavior. Compatibility aliases do not replace migration.

Existing exact proofs retain their original approved subjects. Record any removed
or changed subject explicitly. Finite observations do not establish a new theorem.
Verify actual ordinary entries, affected ownership and authority controls, and
feature consumers through existing runners on their required backends. An older
published game dependency cannot qualify this changed core. Publication remains
frozen until explicitly lifted.
