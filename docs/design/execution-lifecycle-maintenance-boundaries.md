# Lifecycle maintenance and actual owners

The [sequential migration](sequential-execution.md) retains lifecycle maintenance
as an application boundary. These requirements do not establish acceptance of
the changed executor. Historical observations qualify their recorded source only.

## Maintenance follows a completed update

A bare system invocation returns its actual owners without rotating lifecycle
history. A single-system App maintains after an executed result, including a
returned body error. Admission refusal retains the World and system without
maintenance or cursor advancement.

A scheduled App maintains once after Finished and after its selected final
deferred-command policy. This includes an empty Finished update and errors
handled with Continue. Stopped and Invalid retain their returned state without
rotation. Suppressed final application can rotate notices but cannot publish
pending commands or manufacture removal notices.

The pinned Bevy source runs the default schedule before clearing trackers in
[`SubApp::update`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159).
Its single-threaded executor passes returned body failures to the handler while
retaining the same mutable World in
[`single_threaded.rs`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L137-L163).
The absence of transactional rollback is inferred from that control flow.
Bend's explicit refusal outcomes and returned affine owners are adaptations.

## Owners and reader progress survive returned errors

Invocation returns the actual component and resource owners, Local, captures,
readers, and commands. A body error retains performed writes and reader progress.
Each reader yield advances its own token immediately. A disabled body does not
consume that body's reader. Conditions retain separate owners and cursors.

Administration owns the authoritative lifecycle journal. Scope contains a
detached view, which cannot replace that journal during reassembly. Foreign
reader refusal preserves the incoming reader and scope. Registration, retirement,
and lag handling retain their namespace and identity checks.

These requirements concern ordinary returned outcomes. They do not promise
cleanup after fatal host termination or prove arbitrary raw-constructor safety.

## Proof status remains exact

The five approved execution helper laws retain their original subjects and
limits. The separately approved `pending_returns_actual_application` law remains
in [pending-approved](../../test-fixtures/execution-save-laws/pending-approved/LAWS.bend).
It proves the actual save gate's True branch, not lifecycle maintenance.

The unapproved collection at the
[recorded source revision](https://github.com/dearlordylord/bendvy/blob/431266bac456c5e3cf2f2bbf97d512ae1e7f5a65/test-fixtures/execution-lifecycle-laws/LAWS.bend)
binds superseded interfaces. Its complete bytes and semantic obligations are
preserved outside production; its statements and evidence do not transfer to
the new implementation. No replacement equation or proof is implied here.

Current verification follows [agent workflow](../agent-workflow.md). Actual
ordinary consumers and affected authority controls must reach the changed
boundaries before acceptance. New exact laws still require their own approval.
