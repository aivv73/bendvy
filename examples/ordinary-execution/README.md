> Verification policy (2026-10-27): formal proofs use approved Bend laws.
> Temporary Python and JavaScript verification helpers are permitted if they are
> deleted after use. Permanent non-law tests do not replace Bend laws. The retired
> models, reference tests, golden outputs, and check scripts remain historical.
> Their receipts stay outside the source tree. Finite observations and approved
> helper laws do not prove the whole ECS. New laws need specific user approval
> before proof.

# Replacement execution consumer

This application exercises the new ordinary `execution-app` declaration,
registration and repeated-run entry. It currently runs one system sequentially.
It supplies no handwritten World execution adapter.

`declarations.bend` declares a position component and counter resource through
library product paths. Position and label columns own separate chunk trees.
The resource product owns a counter and secret separately. Every payload and
system Local contains an affine Array token. `body.bend` receives an abstract
scope and the declared component/resource capabilities, never World storage.

The application runs the same scenario in two nominal schemas. Sixteen actual
reserved handles become live. Position membership occupies physical slots 0 and
15, and label membership occupies physical slot 1. Both columns grow beyond their
initial leaf. The system increments the first live handle's position by one and
the counter by ten per run.
Run two returns a body error after both writes. Runs one and three succeed.
The actual retained system is then submitted to another World created from the
advanced factory; admission refuses before invoking its body.

The complete output includes both position tokens/values, an absent position,
the untouched label, counter and secret tokens, live and registration counts,
retained Local token/run count, and the returned foreign World's observations.
This distinguishes retained partial mutation from rollback and distinguishes
refusal from another body invocation.

The existing declaration controls now use the F-indexed Program API. The compiler accepts
`controls/metadata-preserved.bend` and `controls/layout-positive.bend`. It rejects
`controls/forged-program.bend` for supplying a concrete Scope getter for abstract
`H`, and `controls/discard-metadata.bend` for consuming the affine Book twice.
It rejects `controls/same-payload-wrong-key.bend` at the layout key and origin
equality, and `controls/invalid-layout-route.bend` at the route-validity proof.
The access-kind, cross-schema handle and affine Local duplication controls also
reject their intended misuse. The remaining controls retain their historical
scope; migrating their surrounding signatures is not acceptance evidence.

Raw schema provisioning is a trusted boundary, as with the existing component
family bindings. The explicit
`execution-projection.trusted_affine` token does not prove that an owner-returning
projector is pure. Every current affine projector requests exclusive access;
read-only describes the gameplay grant and does not authorize a shared runtime
alias. Component projections conservatively stamp the selected row because an
affine projector can replace its owner. A genuine shared detached Data view and
final lifecycle semantics remain separate replacement-executor work.

This example does not establish native concurrency, universal owner preservation
or shared-read purity.

Ordinary registration now accepts `execution-builder.Program` instead of a raw
capability/catalog pair. The declaration is polymorphic over both its hidden
Permit index, scope and affine metadata accumulator. The ordinary declaration
receives no Permit token; the framework specialization supplies the Application's
declaration identity. The body is polymorphic over an opaque effect constructor
F and receives only pure/bind/map operations. Application execution returns its
actual result directly; printing remains the outer IO boundary.
Builder grant primitives return the
updated accumulator together with their capability, so retaining a generated
grant while discarding its recorded access requires reusing the consumed old
accumulator. The current metadata controls check that reuse and reject a getter
for the concrete scope. The raw declaration constructor is an internal lowering
shape and is rejected at the ordinary App entry.

Component and resource grants now accept closed layout routes. Actual slot types
include the key from that same layout. The builder requires type equality between
the World storage and the layout-derived owner tree, and a proof that the route
exists in a collision-free layout. Caller-supplied callback lenses and independent
identity keys are absent from these grant primitives. Same-payload key relabeling,
duplicate layouts, and invalid routes have separate type controls. The query
primitive still requires migration to this layout boundary before claiming the
complete ordinary declaration layer has that property. Raw access lowering
remains explicit trusted library setup rather than a public Program grant.

Run the existing entry directly from the repository root with stock
Bend 2.0.37 and project clang 19:

```sh
bend examples/ordinary-execution/main.bend -o /tmp/ordinary-execution.js
node /tmp/ordinary-execution.js
bend examples/ordinary-execution/main.bend -o /tmp/ordinary-execution.c
clang-19 -std=c11 -O3 /tmp/ordinary-execution.c -lpthread -lm -o /tmp/ordinary-execution
/tmp/ordinary-execution --threads 1 --gpu off
```

These commands run the ordinary application and print its observations. They
are finite execution receipts, not semantic laws. The retired `check.sh` and
`expected.stdout` belonged to the historical verification contract; earlier
receipts retain that original scope.

The sequential-migration receipt matched an independently derived expectation on
JavaScript and native CPU: two lines totaling 7,610 bytes. The derivation preserves
the original Git oracle except for the three physical offsets changed by the
modern layout initializer. It never derives expected data from observed output.
The original-oracle mismatch and the source-derived comparison remain distinct
records. This is a bounded rendered-projection result, not whole-core acceptance;
the lifecycle journal is not rendered.

The observation enumerates every physical slot and lifecycle stamp in both columns,
allocator slots/free/order/progress, registrations, clock/scopes, queue and event
counts, resource owners, system metadata/cursor, Local and the refused foreign
World. Empty queues and Unit events have no omitted payload observations.
The delivered entry prints three one-step movements and three ten-step counter
increments, including the second run's error, plus unchanged sparse membership
and the foreign World's refused invocation, for both nominal schemas.
