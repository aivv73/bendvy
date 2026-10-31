# Ordinary linked despawn

Ordinary `Buffer.Despawn` uses shared relation cleanup when the full resource
schema contains protected graph or lifetime-scope resources. Schemas without
either use direct component disposal. Both belong to the same command queue and
sequential schedule. Scope cleanup commands do not replace ordinary despawn.

## Cleanup and retained owners

Each descriptor selects its own behavior. Hierarchy descendants are removed in
postorder. Ordinary incoming sources are unlinked and survive. Every descriptor
removes the departing entity's outgoing relation before component disposal.
Disposal returns the full affine Removed bundle, appends lifecycle notices and
releases the same actual allocator identity.

The outer LinkedDespawn receipt retains the original full handle. Nested
receipts retain removed owners, relation outcomes and scope results. Incomplete
progress retains actual frames and partial inventories.

`AfterDespawn.KeepMembership` needs no fabricated route. ForgetMembership carries
actual proved scope routes. Scope cleanup supplies its selected route; linked
despawn supplies all accepted scope routes. Both forget membership only after an
actual Despawned receipt and use the same cleanup control and engine.

The exact Nat allowance, initial one-unit drive, Complete and zero-owner exits,
and frame order are preserved. Removing template helper layers is a representation
change, not a new cleanup policy or proved algorithm equivalence.

## Provisioning and authority

Admission checks structural permission, the original retained Context, namespace
and full-generation allocator liveness. Before mutation, the framework catalogue
must cover every protected graph and scope leaf. Graph and scope observers check
their actual Store namespaces without changing membership, caches or stamps.

The closed `execution-schema-provisioning.Blueprint` constructs owners and
framework adapters together. Its graph and scope constructors retain exact
payload, view and policy evidence. Composition consumes each affine seed once
and combines dispatch, snapshot, namespace preflight and retention adapters.
Coverage route lists are passive metadata; they do not replace actual owners.

Provisioning consumes the actual Factory, constructs resources with its next
namespace and creates the Schema once. The application retains that Blueprint
index and original Context. The checked entry must validate Context, coverage and
protected Store namespaces before clocks, conditions or publication.

Gameplay permission and framework cleanup authority remain separate. Authored
relation and scope commands use gameplay adapters. Ordinary despawn alone uses
schema cleanup adapters. The same closed Compilation witness supplies command
selection; runtime admission still inspects the actual Compilation and Local.
No runtime policy tag supplies payload evidence or an extra gameplay write grant.
Raw construction remains trusted administration.

After overall Finished, completion composes lifecycle maintenance and the same
Blueprint's failure retention. Stopped and Invalid retain their returned owners
and pending state. Final publication suppression does not suppress Finished
maintenance. Passive inspection returns the same nested receipt owners with
detached Data facts.

## Required consumer behavior

Existing [linked despawn consumers](../../examples/linked-despawn-systems) retain
the real Factory, allocator-issued handles, arbitrary affine component and
session owners, hierarchy and ordinary descriptors, and handled body errors.
Required observations include postorder removed owners, surviving unrelated
owners and caches, cleared graph indexes, full failure messages, repeated-handle
refusal, retained Local, pending payloads across final suppression, and failure
retention across successive updates.

The [historical observations](https://github.com/dearlordylord/bendvy/blob/431266bac456c5e3cf2f2bbf97d512ae1e7f5a65/docs/design/execution-linked-despawn.md)
record earlier finite scenes and source dependencies. They do not qualify the
changed sequential adapters. Integrated linked-despawn qualification remains
pending; those receipts establish neither arbitrary owner shapes nor formal
owner preservation.

Descriptor behavior follows pinned
[Bevy hierarchy semantics](https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/hierarchy.rs).
Affine removed owners, original full handles and partial cleanup inventories are
additional Bendvy ownership contracts. No new law approval or proof is claimed.
