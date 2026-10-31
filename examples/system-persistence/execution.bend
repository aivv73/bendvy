import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./scheduled.bend as Persistence
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ./restore-receipt.bend as Receipt
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-lifecycle-access.bend as Life
import ../../src/ecs/capabilities.bend as Cap

def Columns(~S:Data) -> Type:Layout.columns(~S,Receiver.Components(~S))
type Local is Type:Local{capture:Array<U32>,runs:U32}
type ReaderLocal<-S:Data> is Type:ReaderLocal{capture:Array<U32>,runs:U32,reader:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>,notices:U32}
type Handler is Type:Handler{capture:Array<U32>,handled:U32}
def handle(handler:Handler,_:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{capture,handled}:(Handler{capture,U32.add(handled,1)},Exec.Continue{})
def config_changed(~S:Data,+enabled:Bool,result:Array<U32> & U32) -> Ordinary.Config<S> & Ordinary.ConfigView:
  match result:
    case (limit,+value):(Ordinary.Config{enabled,Array.set(U32,limit,0,U32.add(value,1))},Ordinary.ConfigView{enabled,U32.add(value,1)})
def config_increment(~S:Data,owner:Ordinary.Config<S>) -> Ordinary.Config<S> & Ordinary.ConfigView:
  match owner:
    case Ordinary.Config{enabled,limit}:config_changed(~S,enabled,Array.get(U32,limit,0))
def scratch_changed(~S:Data,result:Array<U32> & U32) -> Ordinary.Scratch<S> & Unit:
  match result:
    case (values,value):(Ordinary.Scratch{Array.set(U32,values,0,U32.add(value,1))},Unit{})
def scratch_increment(~S:Data,owner:Ordinary.Scratch<S>) -> Ordinary.Scratch<S> & Unit:
  match owner:
    case Ordinary.Scratch{values}:scratch_changed(~S,Array.get(U32,values,0))
def LeftOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Access.ResourceWrite<H,Ordinary.Config<S>,Ordinary.ConfigView>
def RightOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Cap.Bundle<Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>>
def left_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~q:Build.Query(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~F,~H,~B),~life:Build.Lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):
  Build.basic_resource_write(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B,~Plan.layout(Ordinary.resources(~S)),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~rw,book)
def right_combined(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,writer:Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,result:B & Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>) -> B & RightOps(~S,Permit,F,H):
  match result:
    case (book,reader):(book,Cap.Bundle{writer,reader})
def right_granted(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~life:Build.Lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~H,~B),result:B & Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>) -> B & RightOps(~S,Permit,F,H):
  match result:
    case (book,writer):right_combined(~S,~Permit,~F,~H,~B,writer,Build.despawn_lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~H,~B,~life,book))
def right_selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B),~q:Build.Query(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~F,~H,~B),~life:Build.Lifecycle(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):
  right_granted(~S,~Permit,~F,~H,~B,~life,Build.basic_resource_write(~S,~Columns(~S),~Receiver.Resources(~S),~H,~B,~Plan.layout(Ordinary.resources(~S)),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==},~rw,book))
def left_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):builder(LeftOps(~S),left_selection(~S,~Permit,~F,~H,~B),book)
def right_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,Receiver.Components(~S)),~Columns(~S),~Receiver.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):builder(RightOps(~S),right_selection(~S,~Permit,~F,~H,~B),book)
def left_returned(~S:Data,~H:Type,local:Local,result:H & Ordinary.ConfigView) -> H & (Local & Sys.Completion<String,String>):
  match local result:
    case Local{capture,runs}, (scope,Ordinary.ConfigView{_,limit}):(scope,(Local{capture,U32.add(runs,1)},Sys.Success{"config/" ++ U32.show(limit)}))
def right_returned(~S:Data,~H:Type,local:ReaderLocal<S>,result:H & Unit) -> H & (ReaderLocal<S> & Sys.Completion<String,String>):
  match local result:
    case ReaderLocal{capture,runs,reader,+notices}, (scope,_):(scope,(ReaderLocal{capture,U32.add(runs,1),reader,notices},Sys.Success{"transient/notices=" ++ U32.show(notices)}))
def left_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:LeftOps(~S,Permit,F,H),scope:H,local:Local) -> F(H & (Local & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (Local & Sys.Completion<String,String>)),effects,left_returned(~S,~H,local,Access.resource_modify_field(~H,~Ordinary.Config<S>,~Ordinary.ConfigView,caps)(config_increment(~S),scope)))
def right_read(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~writer:Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,capture:Array<U32>,runs:U32,notices:U32,result:H & Notice.Reading<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> H & (ReaderLocal<S> & Sys.Completion<String,String>):
  match result:
    case (scope,Notice.Item{reader,_,_}):right_returned(~S,~H,ReaderLocal{capture,runs,reader,U32.add(notices,1)},Access.resource_modify_field(~H,~Ordinary.Scratch<S>,~Unit,writer)(scratch_increment(~S),scope))
    case (scope,Notice.Empty{reader,_}):right_returned(~S,~H,ReaderLocal{capture,runs,reader,notices},Access.resource_modify_field(~H,~Ordinary.Scratch<S>,~Unit,writer)(scratch_increment(~S),scope))
    case (scope,Notice.ReadRefused{reader,_}):(scope,(ReaderLocal{capture,runs,reader,notices},Sys.BodyError{"reader-refused","transient"}))
def right_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:RightOps(~S,Permit,F,H),scope:H,local:ReaderLocal<S>) -> F(H & (ReaderLocal<S> & Sys.Completion<String,String>)):
  match local:
    case ReaderLocal{capture,runs,reader,notices}:Effects.pure(~F,(H & (ReaderLocal<S> & Sys.Completion<String,String>)),effects,right_read(~S,~Permit,~F,~H,~Cap.first(~Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,~Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>,caps),capture,runs,notices,Life.next(~S,~H,~Layout.EmptyLayout{},~Notice.Despawned{},Cap.second(~Access.ResourceWrite<H,Ordinary.Scratch<S>,Unit>,~Life.Next<S,H,Layout.EmptyLayout{},Notice.Despawned{}>,caps),scope,reader)))
def left_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Receiver.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(~S,Permit,F,H):
  Build.framework_program(~S,~Columns(~S),~Columns(~S),~Receiver.Resources(~S),~LeftOps(~S),~left_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def left_compilation(~S:Data) -> Decl.Compilation<S,Columns(~S),Columns(~S),Receiver.Resources(~S),LeftOps(~S)>:Build.compile_framework(~S,~Columns(~S),~Columns(~S),~Receiver.Resources(~S),~LeftOps(~S),~left_program(~S))
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Receiver.Resources(~S),Unit,LeftOps(~S),Local,String,String,left_program(~S),left_body(~S)>
def Left(~S:Data) -> Type:Leaf.Node(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~LeftOps(~S),~Local,~String,~String,~left_program(~S),~left_body(~S))
def left_dispatch(~S:Data) -> Left(~S) -> Receiver.World(~S) -> U32 -> Left(~S) & (Receiver.World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~LeftOps(~S),~Local,~String,~String,~left_program(~S),~left_body(~S),~left_compilation(~S))
def left_facts(~S:Data,node:Left(~S)) -> Registry.Facts<Reg.Registry<Receiver.World(~S),Left(~S),String,String,left_dispatch(~S)>>:Registry.ordinary(~Receiver.World(~S),~Left(~S),~String,~String,~left_dispatch(~S),Leaf.facts(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~LeftOps(~S),~Local,~String,~String,~left_program(~S),~left_body(~S),~left_compilation(~S),node))
def right_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Receiver.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(~S,Permit,F,H):
  Build.framework_program(~S,~Columns(~S),~Columns(~S),~Receiver.Resources(~S),~RightOps(~S),~right_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def right_compilation(~S:Data) -> Decl.Compilation<S,Columns(~S),Columns(~S),Receiver.Resources(~S),RightOps(~S)>:Build.compile_framework(~S,~Columns(~S),~Columns(~S),~Receiver.Resources(~S),~RightOps(~S),~right_program(~S))
def RightOwner(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Receiver.Resources(~S),Unit,RightOps(~S),ReaderLocal<S>,String,String,right_program(~S),right_body(~S)>
def Right(~S:Data) -> Type:Leaf.Node(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~RightOps(~S),~ReaderLocal<S>,~String,~String,~right_program(~S),~right_body(~S))
def right_dispatch(~S:Data) -> Right(~S) -> Receiver.World(~S) -> U32 -> Right(~S) & (Receiver.World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~RightOps(~S),~ReaderLocal<S>,~String,~String,~right_program(~S),~right_body(~S),~right_compilation(~S))
def right_facts(~S:Data,node:Right(~S)) -> Registry.Facts<Reg.Registry<Receiver.World(~S),Right(~S),String,String,right_dispatch(~S)>>:Registry.ordinary(~Receiver.World(~S),~Right(~S),~String,~String,~right_dispatch(~S),Leaf.facts(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~RightOps(~S),~ReaderLocal<S>,~String,~String,~right_program(~S),~right_body(~S),~right_compilation(~S),node))
def Nodes(~S:Data) -> Type:Reg.Product<Left(~S),Right(~S)>
def dispatch(~S:Data) -> Nodes(~S) -> Receiver.World(~S) -> U32 -> Nodes(~S) & (Receiver.World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~Receiver.World(~S),~Left(~S),~Right(~S),~String,~String,~left_dispatch(~S),~right_dispatch(~S))
def Application(~S:Data) -> Type:Persistence.Application(~S,~Nodes(~S),~Unit,~Handler)
def pending_nodes(~S:Data) -> List<&2,U32> -> Receiver.World(~S) -> Nodes(~S) -> Receiver.World(~S) & (Nodes(~S) & Bool):Retention.pending_pair(~Receiver.World(~S),~Left(~S),~Right(~S),~Retention.pending_none(~Receiver.World(~S),~Left(~S)),~Retention.pending_none(~Receiver.World(~S),~Right(~S)))
def publish(~S:Data,ids:List<&2,U32>,world:Receiver.World(~S),nodes:Nodes(~S)) -> Receiver.World(~S) & (Nodes(~S) & List<&2,U32>):
  (world,(nodes,ids))
def build(~S:Data,world:Receiver.World(~S),leftOwner:Left(~S),rightOwner:Right(~S),handler:Handler) -> Application(~S):
  General.build(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~Nodes(~S),~Unit,~Handler,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~Receiver.World(~S),~String,~Bool),~(key=>True{}),world,Registry.paired(~Receiver.World(~S),~Left(~S),~Right(~S),~String,~String,~left_dispatch(~S),~right_dispatch(~S),left_facts(~S,leftOwner),right_facts(~S,rightOwner)),Reg.empty_conditions(~Receiver.World(~S),~String),handler,[],[])
def run(~S:Data,app:Application(~S)) -> Application(~S) & App.Report<String,String>:
  General.run(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~Nodes(~S),~Unit,~Handler,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~Receiver.World(~S),~String,~Bool),~handle,~publish(~S),app)
def save(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,app:Application(~S)) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):Persistence.save(~S,~Nodes(~S),~Unit,~Handler,~pending_nodes(~S),schema,app)
def restore(~S:Data,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,app:Application(~S)) -> Application(~S) & Receipt.Receipt<S>:Persistence.restore(~S,~Nodes(~S),~Unit,~Handler,~pending_nodes(~S),schema,input,app)
def restored_status(status:Receipt.Status) -> Bool:
  match status:
    case Receipt.Restored{}:True{}
    case _:False{}
def status(~S:Data,receipt:Receipt.Receipt<S>) -> Receipt.Receipt<S> & Bool:
  match receipt:
    case Receipt.Receipt{state,input,removed,rows,mapping,publications,previous,remaining,+status}:(Receipt.Receipt{state,input,removed,rows,mapping,publications,previous,remaining,status},restored_status(status))
type Resumed<-S:Data> is Type:
  Resumed{app:Application(~S),receipt:Receipt.Receipt<S>,report:App.Report<String,String>}
  Retained{app:Application(~S),receipt:Receipt.Receipt<S>}
def resumed(~S:Data,receipt:Receipt.Receipt<S>,result:Application(~S) & App.Report<String,String>) -> Resumed<S>:
  match result:
    case (app,report):Resumed{app,receipt,report}
def resume_checked(~S:Data,app:Application(~S),result:Receipt.Receipt<S> & Bool) -> Resumed<S>:
  match result:
    case (receipt,False{}):Retained{app,receipt}
    case (receipt,True{}):resumed(~S,receipt,run(~S,app))
def resume(~S:Data,result:Application(~S) & Receipt.Receipt<S>) -> Resumed<S>:
  match result:
    case (app,receipt):resume_checked(~S,app,status(~S,receipt))
