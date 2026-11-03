# Named application consumer

`main.bend` exercises named schedules in two nominal schemas with debug disabled
and enabled. It retains the actual App between runs, including Local state,
resource values, replaced plans, skipped systems and returned errors.

The `independent-oracle-v1` files and `reference.mjs` describe the historical
fail-fast bevy-ts behavior. Preserve them as that comparison's source-bound
observations. They are not the expected current error-continuation behavior.

For the current schedule contract, each `failed:planned` result in the original
oracle has `ran` equal to `["Shared","Reader"]` and `barrier` equal to `true`.
All other fields and records remain unchanged. There is one such result per
schema/debug scene. The `Reader` operation in this scenario reads the Counter;
it does not change its value. The explicit barrier follows it. The final result
retains the original `planned` error.

This scenario covers continuation after one returned error. First-error
precedence across multiple failures requires separate evidence; these finite
observations do not establish that property universally. Transactional body
rollback remains independent of schedule continuation.
