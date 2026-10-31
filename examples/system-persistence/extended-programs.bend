import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./extended-declarations.bend as Schema
import ../machine-systems/declarations.bend as Modes
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-machine-state.bend as Cell
import ../../src/ecs/execution-machine-access.bend as Machine
import ../../src/ecs/execution-relation-store.bend as Graph
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-retained-system.bend as Held
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/world.bend as W
import ../../src/ecs/machine.bend as M
import ../../src/ecs/change-tick.bend as Tick

def Columns(~S:Data) -> Type:Layout.columns(~S,Schema.components(~S))
def LeftColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Schema.components(~S),Layout.InLeft{Layout.AtLeaf{}}))
def RightColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Schema.components(~S),Layout.InRight{Layout.AtLeaf{}}))
def LeftLayout(~S:Data) -> Layout.Layout:Layout.subtree(Schema.resource_layout(~S),Layout.InLeft{Layout.AtLeaf{}})
def RightLayout(~S:Data) -> Layout.Layout:Layout.subtree(Schema.resource_layout(~S),Layout.InRight{Layout.AtLeaf{}})
def LeftResource(~S:Data) -> Type:Layout.resources(~S,LeftLayout(~S))
def RightResource(~S:Data) -> Type:Layout.resources(~S,RightLayout(~S))
type Local is Type:Local{capture:Array<U32>,runs:U32}
def LeftOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Access.ResourceRead<H,Graph.View<S,Schema.hierarchy(~S)>>
def RightOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Access.ResourceWrite<H,Cell.Cell<S,Modes.Key,Modes.Mode>,Cell.View<S,Modes.Key,Modes.Mode>>
def GuardOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Machine.Read<S,Modes.Key,Modes.Mode,H>
def left_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~q:Build.Query(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~F,~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):Build.basic_resource_read(~S,~Columns(~S),~Schema.Resources(~S),~H,~B,~Schema.resource_layout(~S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~rr,book)
def right_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~q:Build.Query(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~F,~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):Build.basic_resource_write(~S,~Columns(~S),~Schema.Resources(~S),~H,~B,~Schema.resource_layout(~S),~Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}},~{==},~{==},~rw,book)
def guard_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Columns(~S),~Schema.Resources(~S),~H,~B),~q:Build.Query(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~F,~H,~B),~life:Build.Lifecycle(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~H,~B),book:B) -> B & GuardOps(~S,Permit,F,H):Machine.select_read(~S,~Modes.Key,~Modes.Mode,~Columns(~S),~Schema.Resources(~S),~H,~B,~Schema.resource_layout(~S),~Layout.InRight{Layout.InLeft{Layout.AtLeaf{}}},~{==},~{==},~{==},~rr,book)
def left_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):builder(LeftOps(~S),left_selection(~S,~Permit,~F,~H,~B),book)
def right_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):builder(RightOps(~S),right_selection(~S,~Permit,~F,~H,~B),book)
def guard_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & GuardOps(~S,Permit,F,H):builder(GuardOps(~S),guard_selection(~S,~Permit,~F,~H,~B),book)
def left_returned(~S:Data,~H:Type,local:Local,result:H & Graph.View<S,Schema.hierarchy(~S)>) -> H & (Local & Sys.Completion<String,String>):
  match local result:
    case Local{capture,runs}, (scope,_):(scope,(Local{capture,U32.add(runs,1)},Sys.BodyError{"retained-handler","graph-read"}))
def left_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:LeftOps(~S,Permit,F,H),scope:H,local:Local) -> F(H & (Local & Sys.Completion<String,String>)):Effects.pure(~F,H & (Local & Sys.Completion<String,String>),effects,left_returned(~S,~H,local,Access.resource_read_field(~H,~Graph.View<S,Schema.hierarchy(~S)>,caps)(scope)))
def applied(~S:Data,+tick:Tick.Tick,result:Cell.Cell<S,Modes.Key,Modes.Mode> & Unit) -> Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>:
  match result:
    case (cell,_):Cell.projected(S,Modes.Key,Modes.Mode,Cell.apply(~S,~Modes.Key,~Modes.Mode,~Modes.same,cell,tick))
def transition_at(~S:Data,+tick:Tick.Tick,cell:Cell.Cell<S,Modes.Key,Modes.Mode>) -> Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>:applied(~S,tick,Cell.queued_at(~S,~Modes.Key,~Modes.Mode,~Modes.same,M.Set{Modes.Running{},True{}},tick,cell))
def transition(~S:Data,tick:Tick.Tick,cell:Cell.Cell<S,Modes.Key,Modes.Mode>) -> Cell.Cell<S,Modes.Key,Modes.Mode> & Cell.View<S,Modes.Key,Modes.Mode>:transition_at(~S,tick,cell)
def right_returned(~S:Data,~H:Type,local:Local,result:H & Cell.View<S,Modes.Key,Modes.Mode>) -> H & (Local & Sys.Completion<String,String>):
  match local result:
    case Local{capture,runs}, (scope,Cell.View{_,_,revision,_,_,intent}):(scope,(Local{capture,U32.add(runs,1)},Sys.Success{"revision=" ++ Nat.show(revision) ++ "/transition=" ++ Bool.show(Cell.run_transition(Modes.Mode,intent))}))
def right_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:RightOps(~S,Permit,F,H),scope:H,local:Local) -> F(H & (Local & Sys.Completion<String,String>)):Effects.pure(~F,H & (Local & Sys.Completion<String,String>),effects,right_returned(~S,~H,local,Access.resource_own_at_field(~H,~Cell.Cell<S,Modes.Key,Modes.Mode>,~Cell.View<S,Modes.Key,Modes.Mode>,Cell.View<S,Modes.Key,Modes.Mode>,caps)(transition(~S),scope)))
def guarded(~S:Data,~H:Type,local:Local,result:H & Cell.View<S,Modes.Key,Modes.Mode>) -> H & (Local & Sys.Completion<String,Bool>):
  match local result:
    case Local{capture,runs}, (scope,view):(scope,(Local{capture,U32.add(runs,1)},Sys.Success{Cell.matches(~S,~Modes.Key,~Modes.Mode,~Modes.same,Modes.Waiting{},view)}))
def guard_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:GuardOps(~S,Permit,F,H),scope:H,local:Local) -> F(H & (Local & Sys.Completion<String,Bool>)):Effects.pure(~F,H & (Local & Sys.Completion<String,Bool>),effects,guarded(~S,~H,local,Machine.read_field(~S,~Modes.Key,~Modes.Mode,~H,caps)(scope)))
def left_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):
  Build.framework_program(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~LeftOps(~S),~left_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def LeftCompilation(~S:Data) -> Type:Decl.Compilation<S,Columns(~S),Columns(~S),Schema.Resources(~S),LeftOps(~S)>
def left_construction(~S:Data) -> LeftCompilation(~S):Build.compile_framework(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~LeftOps(~S),~left_program(~S))
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Schema.Resources(~S),Unit,LeftOps(~S),Local,String,String,left_program(~S),left_body(~S)>
def Left(~S:Data) -> Type:Held.CompiledBinding<LeftCompilation(~S),LeftOwner(~S)>
def right_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):
  Build.framework_program(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~RightOps(~S),~right_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def RightCompilation(~S:Data) -> Type:Decl.Compilation<S,Columns(~S),Columns(~S),Schema.Resources(~S),RightOps(~S)>
def right_construction(~S:Data) -> RightCompilation(~S):Build.compile_framework(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~RightOps(~S),~right_program(~S))
def RightOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Schema.Resources(~S),Unit,RightOps(~S),Local,String,String,right_program(~S),right_body(~S)>
def Right(~S:Data) -> Type:Held.CompiledBinding<RightCompilation(~S),RightOwner(~S)>
def guard_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & GuardOps(~S,Permit,F,H):
  Build.framework_program(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~GuardOps(~S),~guard_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def GuardCompilation(~S:Data) -> Type:Decl.Compilation<S,Columns(~S),Columns(~S),Schema.Resources(~S),GuardOps(~S)>
def guard_construction(~S:Data) -> GuardCompilation(~S):Build.compile_framework(~S,~Columns(~S),~Columns(~S),~Schema.Resources(~S),~GuardOps(~S),~guard_program(~S))
def GuardOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Schema.Resources(~S),Unit,GuardOps(~S),Local,String,Bool,guard_program(~S),guard_body(~S)>
def Guard(~S:Data) -> Type:Held.CompiledBinding<GuardCompilation(~S),GuardOwner(~S)>
