import Base
import ../../src/ecs/execution-effects.bend as Effects
import ../../src/ecs/world.bend as W
import ./payloads.bend as P
import ./command-row.bend as Row
import ../../src/ecs/execution-command-local.bend as Local
import ./declarations.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-composer-layout.bend as Layout

def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Ops(~S:Data,Permit:Data,F:(Type -> Type),H:Type,O:Type) -> Type:Q.OutputEach<S,H,O,String>
def BuilderOps(~S:Data,~O:Type,Permit:Data,F:(Type -> Type),H:Type) -> Type:Ops(~S,Permit,F,H,O)
def selection(~S:Data,~WC:Type,~mode:Q.Mode,~Permit:Data,~F:(Type -> Type),~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~despawn:O -> W.Handle<S> -> O,~B:Type,~component_read:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~query:Build.Query(~S,~WC,~D.Store(~S),~D.Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~WC,~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,Permit,F,H,O):
  Build.output_query(~S,~WC,~D.Store(~S),~D.Resources(~S),~F,~D.layout(),~route(),~{==},~{==},~{==},~O,~String,~Row.row(~S,~Permit,~F,~O,~Local.insert_field(~O,~S,~P.Output,commands),~Local.remove_field(~O,~S,~P.Output,commands),~despawn),~mode,~H,~B,~query,book)
def declaration(~S:Data,~WC:Type,~mode:Q.Mode,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~despawn:O -> W.Handle<S> -> O,~B:Type,~builder:Build.Builder(~S,~WC,~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Ops(~S,Permit,F,H,O):
  builder(BuilderOps(~S,~O),selection(~S,~WC,~mode,~Permit,~F,~H,~O,~commands,~despawn,~B),book)
