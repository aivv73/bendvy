# Retained conditions and returned errors

The [sequential design](sequential-execution.md) retains condition owners and
their actual Compilations. A condition has its own Local, captures, readers, and
cursor. Evaluating a condition does not consume the guarded body's reader or
advance that body's cursor.

Ordinary admission checks the actual namespace, registration, schema, recipe,
and read-only condition declaration before invocation. Admission refusal returns
the actual World and condition owner without body or clock entry. Construction
witnesses remain trusted framework provisioning; this document does not prove
coherence of arbitrary manually constructed bindings.

An evaluated false condition skips the body. A returned condition error retains
the evaluated condition's state and passes the error to the configured handler.
Disabled, condition-error, body-error, and admission-refusal observations remain
distinct. Stopping through the handler retains returned state and pending work.

## Ordering and deferred visibility

Dependencies order completion independently of predecessor success. A handled
body error retains writes and does not erase completion. A continuing handler
allows eligible dependent work to proceed.

Conditions observe the World when reached. Required deferred publication occurs
before dependent conditions or bodies that need that visibility. Explicit
synchronization and final-application suppression remain separate policies.
Completion ordering alone does not promise publication at every boundary.

The unchanged [dependency plan](../../src/ecs/dependency-plan.bend) and
[generic executor](../../src/ecs/dependency-executor.bend) define readiness,
returned-error handling, and condition outcomes. The changed ordinary adapters
must preserve those rules together with actual owners and command barriers.

## Pinned Bevy behavior

The reference is Bevy
[`ad678262ce53b5d142fe49ee5e08caff6f00ab60`](https://github.com/bevyengine/bevy/tree/ad678262ce53b5d142fe49ee5e08caff6f00ab60).
The comparison concerns the following behavior, not identical result APIs or
a general affine-owner theorem.

| Contract | Bevy source and behavior |
| --- | --- |
| Completion orders dependent work. | The [single-threaded executor](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L125-L163) handles a returned body failure and continues when the handler returns. |
| Conditions use the available World. | [Condition dispatch](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L82-L116) evaluates system conditions against the current World and caches evaluated set conditions within the run. |
| A failed condition skips its body. | [Condition evaluation](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/executor/single_threaded.rs#L239-L274) reports a returned failure to the handler and yields false. |
| Ordering and publication have distinct rules. | [`before` and `after`](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/schedule/config.rs#L368-L405) document automatic ApplyDeferred insertion and its exceptions. |

The body-error path continues with the same mutable World. The absence of
transactional rollback is inferred from that source control flow. No comparison
here promises continuation after process termination or an escaping handler.

## Evidence and proof limits

Historical condition consumers and reference receipts remain at their
[recorded source revision](https://github.com/dearlordylord/bendvy/blob/431266bac456c5e3cf2f2bbf97d512ae1e7f5a65/docs/design/execution-condition-io.md).
Their JavaScript and native results retain their original source scope. They do
not qualify the changed sequential adapters.

The five approved execution helper laws retain their exact Data and local-helper
subjects. They do not establish whole-run affine owner preservation or deferred
publication. Current ordinary condition, error, and visibility consumers remain
required by [agent workflow](../agent-workflow.md).
