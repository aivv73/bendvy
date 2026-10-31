# Registered affine queries

`main.bend` registers and runs query systems for two nominal schemas. A separate
error scenario observes the state immediately after a handled row error. The
query traverses the selected rows in order and returns the actual component
owners, system Local, and completion.

The declaration selects two component leaves through the closed layout Builder.
Their slot types carry the component keys. The library derives access metadata,
checks the complete storage and selected pair types, and rejoins the returned
owners. Gameplay invokes the resulting query capability without supplying a
storage lens or rebuilding the World.

The input projector returns a reusable `U32` view and its actual owner. The row
body receives that view and one affine output owner. Both component families
contain nested Array tokens. Live matching rows occupy physical slots 0 and 16;
unmatched, absent, and nonlive rows exercise selection and preservation.

The first execution succeeds. The second retains its writes and reports the row
error. A third execution follows for the normal scenarios. Observers include
physical slots, owner projections, cached values, lifecycle stamps, resources,
allocator state, registration metadata, system cursors, Local, and the complete
lifecycle journal. The foreign-World scenario retains the refused owner and
incoming World.

## Deferred commands from query rows

`commands.bend` exercises registered command systems with final deferred
application enabled or suppressed. `output-declaration.bend` uses an ordinary
output query. One output buffer passes through the rows from left to right;
there is no split/merge requirement or query execution policy.

The row callback updates its actual component owner and authors insert, remove,
and despawn commands through declared capabilities. The handled row error keeps
the commands authored before it. Suppressed application returns the pending
buffer; application returns displaced owners and refusal receipts.

The existing authority controls cover nominal-schema mismatch, wrong layout
keys, undeclared capabilities, wrong Data-view types, affine copying, and scope
escape. Their intended rejection reasons remain distinct from execution policy.

The ordinary `main.bend` passed its source check and executed successfully on
JavaScript and native with byte-identical complete output. This establishes
backend parity; it is not an independent semantic oracle. The command entry also
passed source checking and JavaScript/native execution with complete matching
outputs after shared framework specialization repairs. Its earlier template-depth
diagnostics are retained in the migration evidence.
Historical
parallel-worker observations belong to their original source and artifacts;
they do not qualify this implementation. Approved Bend helper proofs retain
their explicitly recorded subjects and do not prove the whole ECS.
