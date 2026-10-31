import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./declarations.bend as D
import ./actor.bend as Actor
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout

# Full ordinary World component route, reusing the same narrow typed-state
# operations and payload-preserving updater as the Root consumer.
def selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Actor.Ops(~S)(Permit,F,H):
  Actor.selected(~S,~Permit,~F,~H,~B,cw(D.component_layout(~S),Layout.InLeft{Layout.AtLeaf{}},{==},{==},book))
def declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Actor.Ops(~S)(Permit,F,H):
  builder(Actor.Ops(~S),selection(~S,~Permit,~F,~H,~B),book)
