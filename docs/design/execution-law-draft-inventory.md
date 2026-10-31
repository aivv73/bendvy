# Execution law inventory

This inventory distinguishes approved statements from drafts and retired subjects.
It does not extend approval or proof coverage to the sequential migration.

## Approved statements

The five approved statements in `test-fixtures/execution-laws` remain frozen.
Their exact source bindings and limits remain in that fixture's `SUBJECTS.json`.

The separately approved `pending_returns_actual_application` remains unchanged in
[its isolated proof](../../test-fixtures/execution-save-laws/pending-approved/PROOF.bend),
with [the exact source binding](../../test-fixtures/execution-save-laws/pending-approved/SUBJECTS.json).
It covers the supplied pending Boolean branch returning the actual application.
It does not prove pending detection, serialization or arbitrary projectors.

## Remaining declarations

These eight files contain 30 declarations, including the approved pending statement
and 29 drafts. A declaration is not approval or proof. This table does not claim
that every draft has passed a source check against the migrating implementation.

| Source | Declarations | Scope and limits |
| --- | ---: | --- |
| [Reservation materialization](../../test-fixtures/execution-reservation/LAWS.bend) | 4 | Specific foreign namespace, malformed leaf, old generation and consumed allocator refusals. No successful arbitrary publication or reservation provenance theorem. |
| [Relations](../../test-fixtures/execution-relation-laws/LAWS.bend) | 7 | Specific foreign owner and Reader refusals, protected-write policy and body-error reassembly. No arbitrary graph-edit or registration theorem. |
| [Relation context](../../test-fixtures/execution-relation-context-laws/LAWS.bend) | 1 | Namespace inequality preserves the supplied actual World and binding. No successful publication or maintenance theorem. |
| [Save gate and recipe](../../test-fixtures/execution-save-laws/LAWS.bend) | 4 | One approved pending equation and three drafts. No general pending-detection, codec or schema theorem. |
| [Save schema](../../test-fixtures/execution-save-laws/SCHEMA.bend) | 2 | Specific readiness and supplied schema-error branches. No successful export or ordering theorem. |
| [Restore helpers](../../test-fixtures/execution-save-laws/RESTORE.bend) | 3 | Pending receiver refusal and empty publication/clear branches. No nonempty restore, remapping, graph reconstruction or stream-preservation theorem. |
| [Machine state and streams](../../examples/machine-systems/laws/LAWS.bend) | 8 | Exact state/stream helper equations. These drafts retain eight proof TODOs and are not completed proofs. |
| [Stopped machine completion](../../examples/machine-systems/laws/PENDING.bend) | 1 | The supplied Stopped result retains its actual application. It does not prove that execution selects Stopped. |

The five approved execution statements are outside this count.

## Retired subjects

The sequential migration retires two unapproved reservation-service declarations
and thirteen unapproved lifecycle declarations. Their exact previous source is
preserved in the migration evidence outside the production tree and in Git at
`431266bac456c5e3cf2f2bbf97d512ae1e7f5a65`.
The old reservation service depended on the removed Task/Issuer boundary.
The lifecycle statements depended on the old IO/Scope wrappers and owner pairs.
They were not silently rewritten to name different subjects.

The GH82 affine-subject planning note is also retired. Its six proposed subjects
named the removed scatter/rejoin and preparation mechanisms; they were never
approved laws. The exact note remains in the migration evidence and Git at the
same revision. It does not define successor sequential proof obligations.

One additional unapproved machine draft, `final_off_retains_actual_state`, named
the former `Deferred.finish` callback/result shape. It is retired rather than
rewritten to the new ordered, trace-bearing subject. Its exact source remains in
the migration evidence and the same Git revision. The actual final-off consumer
in `examples/machine-systems/pending-boundaries.bend` remains required.

Retiring those statements does not retire their behavioral obligations.
The sequential executor must preserve actual returned owners, refuse foreign
Readers and commands, maintain history once after Finished, and avoid that
maintenance after Stopped or Invalid. Body errors preserve completed writes and
commands. These obligations require ordinary consumer evidence; the retired
drafts never established whole-run coverage.

No new law or proof is approved by this inventory. Any successor statement needs
its own exact approval and source binding.

## Bevy correspondence

Behavioral references use Bevy `ad678262ce53b5d142fe49ee5e08caff6f00ab60`.
[Commands](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/commands/mod.rs),
[tracker maintenance](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs)
and [single-threaded execution](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs)
explain the intended behavior. Exact affine owner return, namespace refusal and
typed authority are Bend requirements. Bevy source does not prove those laws.
