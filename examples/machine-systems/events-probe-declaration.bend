import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./declarations.bend as D
import ./events.bend as Body
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-machine-events.bend as Events

def selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~q:Build.Query(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Body.Ops(~S)(Permit,F,H):
  Events.select(~S,~D.Key,~D.Mode,~D.Store(~S),~D.Resources(~S),~H,~B,~D.layout(S),~Layout.AtLeaf{},~{==},~{==},~D.payload_proof(~S),~D.view_proof(~S),~rw,book)
def declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Body.Ops(~S)(Permit,F,H):builder(Body.Ops(~S),selection(~S,~Permit,~F,~H,~B),book)
