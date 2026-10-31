import Base
import ../../src/ecs/execution-effects.bend as Effects
import ./payloads.bend as P
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-policy.bend as Policy
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/owner-product.bend as Product
def left_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Counter,String,P.counter,"counter",Policy.Ordinary{}}
def LeftStore(~S:Data) -> Type:Unit
def LeftResource(~S:Data) -> Type:Layout.resources(~S,left_layout())
def right_layout() -> Layout.Layout:Layout.LayoutLeaf{P.Score,String,P.score,"score",Policy.Ordinary{}}
def resources_layout() -> Layout.Layout:Layout.LayoutPair{left_layout(),right_layout()}
def RightStore(~S:Data) -> Type:Unit
def RightResource(~S:Data) -> Type:Layout.resources(~S,right_layout())
def components_layout() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def Store(~S:Data) -> Type:Product.Owner<Unit,Unit>
def Resources(~S:Data) -> Type:Product.Owner<LeftResource(~S),RightResource(~S)>
def LeftOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:A.ResourceWrites(~P.Counter,~String)(H)
def left_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Store(~S),~Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):
  Build.basic_resource_write(~S,~Store(~S),~Resources(~S),~H,~B,~resources_layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~rw,book)
def left(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):
  builder(LeftOps(~S),left_selection(~S,~Permit,~F,~H,~B),book)
def RightOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:A.ResourceWrites(~P.Score,~String)(H)
def right_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Store(~S),~Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Store(~S),~Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Store(~S),~Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Store(~S),~Resources(~S),~H,~B),~query:Build.Query(~S,~Store(~S),~Store(~S),~Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~Resources(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):
  Build.basic_resource_write(~S,~Store(~S),~Resources(~S),~H,~B,~resources_layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==},~rw,book)
def right(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):
  builder(RightOps(~S),right_selection(~S,~Permit,~F,~H,~B),book)
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{Unit{},Unit{}}
def resources(~S:Data) -> Resources(~S):Product.Owner{Layout.ResourceSlot{Layout.initialize(left_layout(),Layout.AtLeaf{},P.Counter{ALeaf{301},0}),Layout.unknown_stamp()},Layout.ResourceSlot{Layout.initialize(right_layout(),Layout.AtLeaf{},P.Score{ALeaf{401},0}),Layout.unknown_stamp()}}
