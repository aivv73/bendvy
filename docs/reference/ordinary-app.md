# Register and run an ordinary application

Use the [execution API guide](execution-api.md) for the current declaration-bound
application API and [system composition](../../examples/system-composition/README.md)
for feature assembly. The application retains its actual system, resource, Local,
capture, reader, and command owners across updates.

The [sequential execution contract](../SPEC.md#sequential-execution-user-amendment-2026-10-31-utc)
defines ordering and error behavior. A returned body error retains performed
writes and authored commands. Admission refusal executes no body and preserves
its incoming owners. Dependencies provide completion and visibility. Deferred
commands apply at the selected synchronization boundaries.

The historical transactional App walkthrough has been removed. Its removed
modules are not a compatibility API. Existing explicit recovery capabilities
remain governed by their live consumers and separate contracts.
