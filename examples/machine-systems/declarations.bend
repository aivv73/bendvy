import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-resource-policy.bend as Policy
import ./payloads.bend as P
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product

type Key is Data:
  Mode{}
type Mode is Data:
  Waiting{}
  Running{}
def same(left:Mode,right:Mode) -> Bool:
  match left right:
    case Waiting{} Waiting{}:True{}
    case Running{} Running{}:True{}
    case _ _:False{}
def layout(-S:Data) -> Layout.Layout:Machine.leaf(S,Key,Mode,"mode")
def payload_proof(~S:Data) -> {Layout.payload(layout(S),Layout.AtLeaf{}) == State.Cell<S,Key,Mode> : Type}:{==}
def view_proof(~S:Data) -> {Layout.view(layout(S),Layout.AtLeaf{}) == State.View<S,Key,Mode> : Data}:{==}
def root_layout(-S:Data) -> Layout.Layout:Layout.LayoutPair{layout(S),Layout.EmptyLayout{}}
def Resources(~S:Data) -> Type:Layout.resources(~S,layout(S))
def FullResources(~S:Data) -> Type:Layout.resources(~S,root_layout(S))
def actor_layout(~S:Data) -> Layout.Layout:Layout.LayoutLeaf{P.Actor<S,Mode>,Mode,P.actor(~S,~Mode),"actor-state",Policy.Ordinary{}}
def peer_layout(~S:Data) -> Layout.Layout:Layout.LayoutLeaf{P.PeerActor<S,Mode>,Mode,P.peer(~S,~Mode),"peer-state",Policy.Ordinary{}}
def component_layout(~S:Data) -> Layout.Layout:Layout.LayoutPair{actor_layout(~S),peer_layout(~S)}
def LeftStore(~S:Data) -> Type:Layout.columns(~S,actor_layout(~S))
def RightStore(~S:Data) -> Type:Layout.columns(~S,peer_layout(~S))
def Store(~S:Data) -> Type:Layout.columns(~S,component_layout(~S))
def read_ops(~S:Data,Permit:Data,F:Type -> Type,H:Type) -> Type:Machine.Read<S,Key,Mode,H>
def read_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Store(~S),~FullResources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Store(~S),~FullResources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Store(~S),~FullResources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Store(~S),~FullResources(~S),~H,~B),~q:Build.Query(~S,~Store(~S),~Store(~S),~FullResources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~FullResources(~S),~H,~B),book:B) -> B & read_ops(~S)(Permit,F,H):
  Machine.select_read(~S,~Key,~Mode,~Store(~S),~FullResources(~S),~H,~B,~root_layout(S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~view_proof(~S),~rr,book)
def read(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~FullResources(~S),~Permit,~F,~H,~B),book:B) -> B & read_ops(~S)(Permit,F,H):
  builder(read_ops(~S),read_selection(~S,~Permit,~F,~H,~B),book)
def request_ops(~S:Data,Permit:Data,F:Type -> Type,H:Type) -> Type:Machine.Write<S,Key,Mode,H>
def request_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Store(~S),~FullResources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Store(~S),~FullResources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Store(~S),~FullResources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Store(~S),~FullResources(~S),~H,~B),~q:Build.Query(~S,~Store(~S),~Store(~S),~FullResources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~FullResources(~S),~H,~B),book:B) -> B & request_ops(~S)(Permit,F,H):
  Machine.select_write(~S,~Key,~Mode,~Store(~S),~FullResources(~S),~H,~B,~root_layout(S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~payload_proof(~S),~view_proof(~S),~same,~rw,book)
def request(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~FullResources(~S),~Permit,~F,~H,~B),book:B) -> B & request_ops(~S)(Permit,F,H):
  builder(request_ops(~S),request_selection(~S,~Permit,~F,~H,~B),book)
def apply_ops(~S:Data,Permit:Data,F:Type -> Type,H:Type) -> Type:Machine.Apply<S,Key,Mode,H>
def apply_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Store(~S),~FullResources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Store(~S),~FullResources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Store(~S),~FullResources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Store(~S),~FullResources(~S),~H,~B),~q:Build.Query(~S,~Store(~S),~Store(~S),~FullResources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~Store(~S),~Store(~S),~FullResources(~S),~H,~B),book:B) -> B & apply_ops(~S)(Permit,F,H):
  Machine.select_apply(~S,~Key,~Mode,~Store(~S),~FullResources(~S),~H,~B,~root_layout(S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~payload_proof(~S),~view_proof(~S),~same,~rw,book)
def apply(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~FullResources(~S),~Permit,~F,~H,~B),book:B) -> B & apply_ops(~S)(Permit,F,H):
  builder(apply_ops(~S),apply_selection(~S,~Permit,~F,~H,~B),book)
