# Query consumers

These existing consumers exercise the closed Builder API against actual whole
World owners. They use the common sequential schedule and retain each system's
actual compilation, captured affine locals and cursor.

| Entry | Observable behavior |
| --- | --- |
| `query-observations.bend` | Seven scenarios cover repeated updates, write-before-error, count/single/get, explicit targets, detached source-derived effects, duplicate-target refusal, absent/excluded/foreign/stale/zero/outside handles. The observer renders full columns, caches, stamps, allocator, registrations, clock, lifecycle journal and local command buffers. |
| `query-main.bend` | The baseline scenario from that same consumer. |
| `mixed-owners-main.bend` | An unlike full component layout, Array and String resource owners, same-resource versus other-resource reads, a retained body error, three guarded updates and an additional genuinely activated entity between updates. |
| `unsupported-provider.bend` | A declaration using the default unsupported query provider retains its World and captured local at definition refusal. |
| `output-authority-positive.bend` | Actual affine traversal output and component owners pass through the ordinary query provider. |
| `reject-*.bend` | Existing controls reject owner duplication, nominal schema/origin/shape substitution, writing through read authority and abstract scope escape. Four output controls additionally reject reader traversal, foreign schema and duplicate output/scope owners. A missing import is not a qualified rejection. |

Traversal carries one output owner through one whole-column walk. A row error
retains the returned write and output. Complete target validation precedes the
row body; an invalid target set returns the unused output. Query bounds and
membership rules remain declaration properties. Cached observations are Data;
they do not replace live component authority.

The sequential migration's source checks passed for both observation entries,
the default unsupported provider and the output authority positive. The
existing negative controls reached their intended boundaries. The seven-mode
JavaScript output matched all20,862 expected bytes. Its oracle preserves every
World, report and owner observation from the independent historical32,883-byte
oracle, removing only the deleted backend's preparation and displacement
renderings. Native output also matched the complete same expectation. The
mixed-owner entry matched all seven source-derived lines on both backends.
Final qualification against the integrated shared core and review remain pending.
These are finite observations, not approved universal laws or performance data.

The retired cut/slice/preparation fixtures and historical backend qualification
are available in Git revision431266bac456c5e3cf2f2bbf97d512ae1e7f5a65 under
`test-fixtures/execution-query-partitions`. They are not a second supported
execution path. The obsolete `D.grants` control is retired with that API;
current authority checks use actual whole-column/query boundaries.

The current framework contract is documented in
[sequential execution](../../docs/design/sequential-execution.md).
