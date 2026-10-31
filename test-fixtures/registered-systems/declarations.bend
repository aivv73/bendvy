import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-composer-layout.bend as Layout
import ./payloads.bend as P
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/capabilities.bend as Cap
def inserted(~S:Data,~T:Type,result:Col.SwapOutcome<S,T>) -> Col.Column<S,T>:
  match result:
    case Col.Accepted{column,_}:column
    case Col.Rejected{column,_}:column
def left_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Position,String,P.position,"position",Policy.Ordinary{}}
def left_resource_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Counter,String,P.counter,"counter",Policy.Ordinary{}}
def LeftStore(~S:Data) -> Type:Layout.columns(~S,left_layout())
def LeftResource(~S:Data) -> Type:Layout.resources(~S,left_resource_layout())
def LeftOps(~S:Data,Permit:Data,F:Type -> Type) -> Type -> Type:D.Combined(~A.ComponentWrites(~S,~P.Position,~String),~A.ResourceWrites(~P.Counter,~String))
def right_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Health,String,P.health,"health",Policy.Ordinary{}}
def right_resource_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Score,String,P.score,"score",Policy.Ordinary{}}
def RightStore(~S:Data) -> Type:Layout.columns(~S,right_layout())
def RightResource(~S:Data) -> Type:Layout.resources(~S,right_resource_layout())
def RightOps(~S:Data,Permit:Data,F:Type -> Type) -> Type -> Type:D.Combined(~A.ComponentWrites(~S,~P.Health,~String),~A.ResourceWrites(~P.Score,~String))
def components_layout() -> Layout.Layout:Layout.LayoutPair{left_layout(),right_layout()}
def resources_layout() -> Layout.Layout:Layout.LayoutPair{left_resource_layout(),right_resource_layout()}
def Store(~S:Data) -> Type:Product.Owner<LeftStore(~S),RightStore(~S)>
def Resources(~S:Data) -> Type:Product.Owner<LeftResource(~S),RightResource(~S)>
def left_combined(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,component:A.ComponentWrite<S,H,P.Position,String>,result:B & A.ResourceWrite<H,P.Counter,String>) -> B & LeftOps(~S,Permit,F)(H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def left_component_granted(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),result:B & A.ComponentWrite<S,H,P.Position,String>) -> B & LeftOps(~S,Permit,F)(H):
  match result:
    case (book,component):left_combined(~S,~Permit,~F,~H,~B,component,Build.basic_resource_write(~S,~Store(~S),~Resources(~S),~H,~B,~resources_layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~resource_write,book))
def left_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Store(~S),~Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,F)(H):
  left_component_granted(~S,~Permit,~F,~H,~B,~resource_write,component_write(components_layout(),Layout.InLeft{Layout.AtLeaf{}},{==},{==},book))
def left(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(~S,Permit,F)(H):
  builder(LeftOps(~S),left_selection(~S,~Permit,~F,~H,~B),book)
def left_store(~S:Data) -> LeftStore(~S):
  Layout.ColumnSlot{inserted(~S,~Layout.Viewed<P.Position,String>,Col.swap(~S,~Layout.Viewed<P.Position,String>,inserted(~S,~Layout.Viewed<P.Position,String>,Col.swap(~S,~Layout.Viewed<P.Position,String>,Col.ensure(~S,~Layout.Viewed<P.Position,String>,Col.empty(~S,~Layout.Viewed<P.Position,String>),31),0,Some{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Position{ALeaf{101},10})})),16,Some{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Position{ALeaf{118},70})}))}
def left_resources(~S:Data) -> LeftResource(~S):Layout.ResourceSlot{Layout.initialize(left_resource_layout(),Layout.AtLeaf{},P.Counter{ALeaf{301},0}),Layout.unknown_stamp()}
def right_combined(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,component:A.ComponentWrite<S,H,P.Health,String>,result:B & A.ResourceWrite<H,P.Score,String>) -> B & RightOps(~S,Permit,F)(H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def right_component_granted(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),result:B & A.ComponentWrite<S,H,P.Health,String>) -> B & RightOps(~S,Permit,F)(H):
  match result:
    case (book,component):right_combined(~S,~Permit,~F,~H,~B,component,Build.basic_resource_write(~S,~Store(~S),~Resources(~S),~H,~B,~resources_layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==},~resource_write,book))
def right_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~component_read:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~component_write:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~resource_read:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~resource_write:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Store(~S),~Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,F)(H):
  right_component_granted(~S,~Permit,~F,~H,~B,~resource_write,component_write(components_layout(),Layout.InRight{Layout.AtLeaf{}},{==},{==},book))
def right(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(~S,Permit,F)(H):
  builder(RightOps(~S),right_selection(~S,~Permit,~F,~H,~B),book)
def right_store(~S:Data) -> RightStore(~S):
  Layout.ColumnSlot{inserted(~S,~Layout.Viewed<P.Health,String>,Col.swap(~S,~Layout.Viewed<P.Health,String>,inserted(~S,~Layout.Viewed<P.Health,String>,Col.swap(~S,~Layout.Viewed<P.Health,String>,Col.ensure(~S,~Layout.Viewed<P.Health,String>,Col.empty(~S,~Layout.Viewed<P.Health,String>),31),0,Some{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Health{ALeaf{201},10})})),8,Some{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Health{ALeaf{210},80})}))}
def right_resources(~S:Data) -> RightResource(~S):Layout.ResourceSlot{Layout.initialize(right_resource_layout(),Layout.AtLeaf{},P.Score{ALeaf{401},0}),Layout.unknown_stamp()}
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{left_store(~S),right_store(~S)}
def resources(~S:Data) -> Resources(~S):Product.Owner{left_resources(~S),right_resources(~S)}
