# Sequential execution API

The [sequential execution amendment](../SPEC.md#sequential-execution-user-amendment-2026-10-31-utc)
defines the ordinary contract. The [execution design](../design/sequential-execution.md)
describes its ownership and effect boundary. This reference covers the migrated
single-system and schedule interfaces. Integrated consumer qualification remains
in progress; module source checks do not establish whole-engine acceptance.

## Application construction and repeated runs

[`world-io`](../../src/ecs/world-io.bend) supplies host namespace allocation.
[`world`](../../src/ecs/world.bend) also exposes explicit factory-based creation.
Creation refusal returns the incoming resource owner. Raw constructors and
caller-selected namespace construction are trusted integration operations.

[`execution-app.define`](../../src/ecs/execution-app.bend) consumes the World,
system name, and Local. It returns `Built{application}` or
`BuildRefused{world,local}`. The application retains the registered system and
actual World. `define_framework` accepts the framework declaration form.

`execution-app.run` consumes an application and returns its next application
paired with `Status`. `Ran{completion}` contains `Success` or `BodyError`;
`AdmissionRefused` contains no body completion. These operations return ordinary
values. Host IO remains outside this pure execution interface.

The [ordinary application](../../examples/ordinary-execution/application.bend)
retains the returned application across repeated runs and a foreign-World
refusal. Its [body](../../examples/ordinary-execution/body.bend) retains affine
Local state and writes before returning a body error.

## Declarations and body capabilities

[`execution-builder.Program`](../../src/ecs/execution-builder.bend) selects
declared capabilities. Its capability family has kind
`Data -> (Type -> Type) -> Type -> Type`, indexed by permit, effect, and scope.
Declarations receive the abstract effect constructor and its closed composition
operations. They can bind those operations into effectful row callbacks.
The framework declaration form also receives closed reservation provisioning.

[`execution-system.Body`](../../src/ecs/execution-system.bend) receives abstract
`Permit`, `F`, and `H`, framework composition operations, declared capabilities,
the actual scope, and Local. It returns `F(H & (Local & Completion))`.
`Completion` has `Success{output}` and `BodyError{error,output}` constructors.

[`execution-effects`](../../src/ecs/execution-effects.bend) exposes `pure`,
`bind`, and `map`. Only `F` is a template parameter to these helpers. Result
types are ordinary erased arguments, including arbitrary affine Type owners.
For example, `Effects.pure(~F,Result,effects,value)` lifts an existing result.
The dictionary contains no interpreter or allocator access.

Ordinary `execution-system.run` checks namespace, registration, and supported
compilation before clock entry. Refusal retains the incoming World and owner.
Execution retains returned writes, Local, captures, readers, and commands,
including body errors. The system cursor advances after an executed return.

## Commands and query rows

[`execution-command-permission`](../../src/ecs/execution-command-permission.bend)
provides declaration-bound structural commands.
`spawn_field` returns `Q -> Bundle -> F(Q & SpawnAdmission)`.
`SpawnQueued` contains the actual reserved handle; `SpawnRejected` retains the
actual bundle and reason. Gameplay does not receive a reservation interpreter.
The [reservation contract](../design/reservation-production-api.md) defines
Pending visibility, publication, and cancellation.

[`execution-query`](../../src/ecs/execution-query.bend) separates selection from
execution. `AllRows` selects admitted rows and `Where` adds a lifecycle filter.
`SequentialOutputEach` exposes the effectful paired-column traversal through
`each_sequential_output`. Its operation consumes the scope and output owner and
returns both with the query report inside the same `F`.

Row callbacks close over composition operations for that fixed enclosing `F`.
They return the actual writable payload and output owner. Traversal threads one
output through rows, refreshes returned views, and retains write stamps and row
errors. Invalid targets or incompatible layouts retain the supplied owners.

The [shared chunk traversal](../../src/ecs/chunk-query.bend) implements both
pure and effectful paired rows. The pure entry specializes that traversal with
the identity effect. It does not split or merge the output owner.

## Registration and lifecycle

[`execution-system-registration`](../../src/ecs/execution-system-registration.bend)
contains registration and owner metadata helpers. `define_with_compilation`
retains the actual Compilation alongside the registration result. Construction
witnesses are trusted framework provisioning, not a theorem that arbitrary raw
caps match a manually constructed runtime Compilation.

[`execution-retained-system`](../../src/ecs/execution-retained-system.bend)
keeps the actual Compilation and owner in one existential carrier. Use `pack`
and `unpack` with their explicit erased types. `map_owner` observes or changes
the owner while retaining that same Compilation. The consuming `owner` projection
is for terminal observations that discard the Compilation. Scheduling does not
recompile a retained system or reconstruct its authority from a witness.

Bare system execution does not rotate lifecycle history. A single-system App
maintains after an executed result, including a body error; admission refusal
does not maintain. Scheduled completion and deferred publication follow the
[maintenance contract](../design/execution-lifecycle-maintenance-boundaries.md).

## Scheduled applications

The scheduled path retains the actual whole World and system owners. Individual
systems still receive only their declared abstract capabilities. Their declaration
uses full-World column and resource types with the selected layout routes; the
framework does not manufacture cut-owner types for invocation.

| Module | Responsibility |
| --- | --- |
| [`dependency-registration`](../../src/ecs/dependency-registration.bend) | One affine registry, shared product composition, scalar registration-ID dispatch and condition registry. |
| [`execution-registry`](../../src/ecs/execution-registry.bend) | Derives deferred-system IDs from actual command registrations and combines their facts with the common registry. |
| [`execution-generalized-system-leaf`](../../src/ecs/execution-generalized-system-leaf.bend) | Ordinary retained Compilation and system owner, schema admission and fixed-deny invocation. |
| [`execution-generalized-command-leaf`](../../src/ecs/execution-generalized-command-leaf.bend) | Retained command owner, actual permission checks, pending detection and publication. |
| [`execution-condition-registry`](../../src/ecs/execution-condition-registry.bend) | Read-only condition admission and the same common registry composition. |
| [`execution-schedule`](../../src/ecs/execution-schedule.bend) | Retained schedule state, ordered invocation, returned reports and deferred settings. |
| [`execution-generalized-root-application`](../../src/ecs/execution-generalized-root-application.bend) | Builds the application from actual registrations and conditions, validates dependencies and bindings, and maintains lifecycle once after Finished. |

With the application module imported as `General`, `General.build` consumes
registry facts, the condition registry, handler, dependency
edges and condition bindings. The resulting schedule retains those actual owners.
`General.run` returns the next schedule and report directly. Host printing remains
an outer IO operation. There is no execution-policy or fork parameter.

Deferred settings control automatic dependency publication, ignored publication
edges, explicit synchronization and final application. Required synchronization
runs before the dependent condition. Returned body errors retain completion and
pending commands before handler selection. Stopped and Invalid retain returned
owners and pending work without final publication or lifecycle maintenance.

`Schedule.create` builds the deferred graph once. `Schedule.configure` rebuilds
it when graph settings change while retaining the actual state and pending IDs.
Ordinary runs reuse that graph. `Schedule.set_final_apply` changes only final
publication and retains the existing compiled graph. Raw constructors remain
trusted; reconstructing settings manually must preserve their compiled metadata.
The retained metadata also includes publication order from the compiled plan.
At each boundary, known pending IDs are deduplicated and applied in that order.
Unknown IDs retain their original relative order and multiplicity in the pending
suffix. A boundary with no known pending IDs does not invoke publication.

`General.run_bound` and its observed form check the actual relation Context
before any schedule action. Refusal returns the bound owners and pending state
with `ContextRefused`; the observed form returns no fabricated boundary events.
The [relation-failure completion adapter](../../src/ecs/execution-relation-failure-root-completion.bend)
composes lifecycle maintenance with Finished-only failure-stream retention.
These changed entries still need integrated consumer qualification; their old
receipts do not qualify the new source.

Retained system restoration uses `SysLife.restore_with_compilation` with the
actual held Compilation. It returns that artifact on success and refusal and
preserves the namespace, registration-ID, collision, support and access checks.
The basic convenience entry compiles once and delegates to the same restoration
path; it does not replace the selected interpreter of a retained application.

The [core map](core-map.md) describes component, resource, event, relation,
machine, inspection, recovery, and persistence facilities. Source-bound
observations and approved laws retain their exact subjects and limits. They do
not establish successful execution of every changed consumer.
