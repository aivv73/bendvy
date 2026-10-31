# Lifecycle consumers

The examples use the common sequential executor. System bodies retain writes,
reader progress and affine captures when they return a handled error. Admission
refusal preserves the actual owner without executing its body or advancing its
cursor. See [execution semantics](../../docs/design/sequential-execution.md).

| Entry | Behavior |
| --- | --- |
| `main.bend` | Filter scenarios followed by removal and despawn notices. |
| `history.bend` | Existing zero cursor, tick wrap, dormant stamps and errors after writes. |
| `scheduled.bend` | Added/Changed filters, deferred publication and retained command queues when final publication is disabled. |
| `notice-scenario.bend` | Fast and dormant readers, input/output removal, despawn, continued reader error and actual foreign-World transfer. |
| `retained-foreign.bend` | The same retained command owner first refuses a genuine foreign World, then retries its original World with its queue, token and cursor preserved. |

Emit a selected entry with the official Bend 2.0.37 compiler. Development source
checks use Bend 2.0.39. Generated artifacts belong outside the repository.

```bash
bend examples/lifecycle-systems/notice-scenario.bend -o /tmp/notice.js
node /tmp/notice.js
bend examples/lifecycle-systems/notice-scenario.bend -o /tmp/notice.c
clang-19 -std=c11 -O3 /tmp/notice.c -lpthread -lm -o /tmp/notice.native
/tmp/notice.native --threads 1 --gpu off
```

The migrated notice entry produced matching complete 9,045-byte JS and native
observations, including all rendered World owners, queues and reader histories.
The source-derived literal was authored after output had been observed. It is
finite evidence, not an independent pre-output oracle or a universal proof.
Its artifacts precede the later ordinary-erasure correction in the shared state
kernel; final integrated qualification remains pending. History and scheduled
source checks pass; that does not qualify their current runtime behavior.

Historical backend artifacts and earlier receipts are preserved in Git at
`431266bac456c5e3cf2f2bbf97d512ae1e7f5a65` under
`examples/parallel-lifecycle`. They are not current acceptance commands.
