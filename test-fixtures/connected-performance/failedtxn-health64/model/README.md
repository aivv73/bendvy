# FailedTxn Health64 independent model

```sh
python3 test-fixtures/connected-performance/failedtxn-health64/model/seal_gold.py --output /tmp/failedtxn-health-gold-fresh
```

The output directory must not exist. The operation model now derives the captured-clock baseline at `30f24c770f5c06f95e6cf30d579cf28aa733d3cd`. Original operation-model origins and qualified transport hashes remain historical fields in `SOURCE-BASIS.json`; `currentBaseline` pins the repaired model and its clock/reader source basis. The common-record and TS transition models remain byte-identical. The sealer generates the complete two-world canonical stream independently, verifies its equality with the additive observer's canonical transport, and retains all fields. Large outputs remain outside the repository. No subject output is an oracle input.

Each fresh world retains 965 records, 3,608,414 scalar cells, 193 callbacks, 129 publications, 256 boundaries, 385 phases and 256 actual actors. Full Vitals, Armor, Tracked and Ledger payload fields remain in ordered observations. The baseline reader callback still rolls back body writes and discards staged commands/events on failure. Failure skips stream commit and after-success ingestion, while the independent Registry cursor records its actual captured entry tick on every executed outcome. The retained Local capture and preparation's reader-position activation survive failure.

Local execution, registered reader execution and explicit command application each capture one tick. Writes reuse the innermost captured tick; nested execution restores the outer scope without rewinding administrative time. The finite workload stays below the low-word wrap, so the model stores integer ticks with an explicit range assertion and renders the complete epoch-zero clock, stamp and optional cursor. It makes no wrap qualification claim. Seed and each command batch share their captured tick, and the dispose Registry records its own entry tick.

This is finite method correctness evidence, without comparative timing, RSS, batching or precision qualification.

The sealer also accepts `--count 256` or `--count 1024`, with `--iterations 64`; defaults remain64. This recovery qualifies only the existing64 role. TS actor-map bounds derive from the actual seed record plus192 authored reservation results; all965 records remain. The unchanged64 common-cell count/fold and TS output hash remain assertions. Historical Bend canonical hashes describe the earlier clock contract and cannot qualify the repaired baseline. New complete Bend hashes are frozen from independent generation before consumer execution.
