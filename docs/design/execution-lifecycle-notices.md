# Lifecycle notices in sequential execution

This contract retains lifecycle behavior while replacing the execution mechanism.
It does not claim that the migration or its integrated qualification is complete.
The previous partition and Prepared-carrier design remains in
[the historical revision](https://github.com/dearlordylord/bendvy/blob/431266bac456c5e3cf2f2bbf97d512ae1e7f5a65/docs/design/execution-lifecycle-notices.md).

## Owners and snapshots

World owns an affine `Notice.Journal<S>` separately from its user events.
The journal retains per-channel sequence numbers, maintenance generations,
dropped-through floors and reader registrations. Administration owns the actual
journal during invocation. Scope receives a reusable detached view. Reassembly
takes the actual journal from Administration, never from a returned Scope view.

Sequential invocation captures a fresh view after preceding deferred publication.
Readers may share a view but retain independent affine reader tokens and cursors.
Reader registration and retirement operate on the actual World outside running
scopes. The view does not grant component mutation or entity allocation.

## Typed family authority

A removed/despawned capability retains the schema, full selected layout origin
and canonical stream key. A key/name inventory alone cannot distinguish two
families with the same key but different origins.

The declaration retains actual whole-World columns independently of its local
physical component requirements. A metadata-only reader can therefore have
`C = Unit` while retaining authority for a lifecycle family in the whole World.
The family witness derives from the full layout, selected route, layout equality
and grant-valid evidence. It must not be reconstructed from an erased catalog
or an unchecked phantom relabeling constructor.

One declaration can combine multiple family readers with component, resource
and query capabilities. Lifecycle access contributes read-only snapshot metadata
but does not add a physical column extraction requirement. The same declaration
and owner retain the actual whole-World identity throughout definition and use.

## Ordinary admission

Canonical registry dispatch retains the actual Compilation and exact system
owner. It validates schema requirements, whole-World namespace, registration and
command permissions before body entry. Owning whole columns does not make a
declaration valid for every schema.

Refusal returns the incoming World and actual system owner without changing the
body's cursor. An invoked body retains its returned Local, writes and commands
even when it returns an error. Conditions own separate cursors and never consume
the body's reader position.

Invocation uses the admitted owner's full tick and prior cursor. A deferred
publication boundary before invocation must be visible in its lifecycle snapshot.
The journal itself remains authoritative in Administration.

Raw construction helpers and adapters that accept caller-provided admission facts
remain trusted integration boundaries. Their existence does not establish
ordinary authority confinement. Gameplay receives neither these adapters nor an
effect interpreter through its capability dictionary.

## Publication and maintenance

Structural publication records removals and despawns in the lifecycle journal
without changing the meaning of user event streams. Foreign namespaces, stale
handles and invalid family routes must refuse before mutating the actual owner.

Reader progress, retention and lag remain independent of physical column access.
Skipping a body must not fabricate a read. Error handling must preserve the
contract of the invoked reader instead of applying a generic rollback policy.

Application maintenance runs once after Finished, including a continued body
error that still produces Finished. It does not run after Stopped or Invalid.
Deferred edge visibility, explicit synchronization, final application and final
application suppression remain separate scheduling decisions. See
[maintenance boundaries](execution-lifecycle-maintenance-boundaries.md) and
[execution conditions](execution-conditions.md).

## Evidence and proof limits

The historical full-WC, foreign-Scope and lifecycle observations remain bound to
their original sources. They do not qualify this sequential implementation.
Changed ordinary entries need actual positive and intended-negative source
controls, genuine-World refusal observations and affected lifecycle consumers.

The thirteen retired lifecycle law drafts were unapproved. Their complete source
is preserved in migration evidence and Git. Removing their old subjects does not
remove the behavioral requirements above or prove successor statements. The
separately approved execution and pending-save statements remain unchanged.
See [the law inventory](execution-law-draft-inventory.md).
