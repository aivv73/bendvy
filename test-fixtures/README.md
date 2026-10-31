# ECS fixtures and preserved source

Current replacement fixtures and historical runtime fixtures have different source
contracts. Historical runtime imports deliberately do not resolve against the
replacement core. They are not current compilation targets or replacement
acceptance evidence. See [historical replay](HISTORICAL.md) before running them.

| Fixtures | Source contract |
| --- | --- |
| execution-* | Current replacement implementation, including the five approved helper laws and separate unapproved law drafts; each directory retains its own approval status |
| actor-lookup-boundaries, chunk-column, common, component-read-custody, dependency-schedules, registered-systems | Retained semantic fixtures; the sequential migration is pending validation |
| diagnostic-refusals | Preserved diagnostic text consumed by scripts/test-retro-controls.py; no Bend runtime import |
| connected-performance, ordinary-app, public-clock-events, public-clock-system, public-inspect, public-save-pending, public-schedule-readers, public-schedules, public-scopes, query-composition, query-pair-v1 | Historical runtime cohorts; use their original source checkout |
| public-nested-provision, public-schema-fragments | Original provisioning/benchmark cohorts; preserved with historical replay, not replacement qualification |

The five approved execution helper laws remain byte-for-byte unchanged. Other law
directories do not inherit their approval. Original benchmark models, expected
outputs, capability controls and diagnostic evidence remain preserved; they do not
assert compatibility with ordinary execution after its transactional API removal.

The unapproved Task-reservation draft and mixed lifecycle draft are retired from
the active fixture tree. Their complete original equations and source hashes are
preserved in the migration's inert archive; no approval or proof transfers from
them. Other semantic law collections retain their original approval status.

`examples/check.sh` is the existing example discovery entry. Validation during the
sequential migration is bounded to named consumer entries; it does not establish
that every fixture compiles or runs. Import availability alone does not establish
an execution result.
