import Base
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-system.bend as Sys
import ../../../src/ecs/execution-effects.bend as Effects
import ../../../src/ecs/world.bend as W
type Schema is Data:
  Schema{}
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def declaration(~WC:Type,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC,~Unit,~Unit,~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):
  (book,Unit{})
def program(~WC:Type,~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema>),~H:Type,~B:Type,~builder:Build.Builder(~Schema,~WC,~Unit,~Unit,~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):
  Build.framework_program(~Schema,~WC,~Unit,~Unit,~Ops,~declaration(~WC),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~cap:Unit,owner:H,local:Unit) -> F(H & (Unit & Sys.Completion<String,Unit>)):
  Effects.pure(~F,(H & (Unit & Sys.Completion<String,Unit>)),effects,(owner,(local,Sys.Success{Unit{}})))
def Owner(~WC:Type) -> Type:Sys.Owner<Schema,WC,Unit,Unit,Unit,Ops,Unit,String,Unit,program(~WC),body>
