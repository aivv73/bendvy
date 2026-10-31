import ../../../src/ecs/execution-effects.bend as Effects
import Base
import ../declarations.bend as D
import ../payloads.bend as P
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-access.bend as Access
import ../../../src/ecs/execution-projection.bend as Projection
import ../../../src/ecs/ordinary-schema.bend as Schema

type Nominal is Data:
  Nominal{}
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Access.ResourceWrite<H,P.Counter,String>
def discarded(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,original:B,result:B & Ops(Permit,F,H)) -> B & Ops(Permit,F,H):
  match result:
    case (_,caps):(original,caps)
def selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~component_read:Build.ComponentRead(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~component_write:Build.ComponentWrite(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~resource_read:Build.ResourceRead(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~resource_write:Build.ResourceWrite(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),~query:Build.Query(~Nominal,~D.Store(~Nominal),~D.Store(~Nominal),~D.Resources(~Nominal),~F,~H,~B),~lifecycle:Build.Lifecycle(~Nominal,~D.Store(~Nominal),~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B),book:B) -> B & Ops(Permit,F,H):
  discarded(~Permit,~F,~H,~B,book,Build.basic_resource_write(~Nominal,~D.Store(~Nominal),~D.Resources(~Nominal),~H,~B,~D.resource_layout(),~D.first_route(),~{==},~{==},~resource_write,book))
def declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Nominal,~D.Store(~Nominal),~D.Store(~Nominal),~D.Resources(~Nominal),~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):
  builder(Ops,selection(~Permit,~F,~H,~B),book)
