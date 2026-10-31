import Base
import ./extended-declarations.bend as Schema
import ./extended-programs.bend as P
import ./extended-target.bend as Target
import ./extended-admission.bend as Admission
import ./extended-restore.bend as Restore
import ../../src/ecs/execution-restore-extended-data.bend as Extended
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/restore-data.bend as R
import ../../src/ecs/relation-types.bend as T
import ../../src/ecs/execution-restore-publication.bend as Publication
import ./restore.bend as Ordinary
import ../../src/ecs/execution-restore-receiver.bend as Receiver

import ./scheduled.bend as OrdinarySchedule
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-system-registration.bend as Registration
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/world.bend as W
type Handler<-S:Data> is Type:Handler{capture:Array<U32>,handled:U32,reader:Maybe<&1,Target.Reader(~S)>}
def handle(~S:Data,handler:Handler<S>,_:String) -> Handler<S> & Exec.Handling:
  match handler:
    case Handler{capture,handled,reader}:(Handler{capture,U32.add(handled,1),reader},Exec.Continue{})
def dispatch(~S:Data) -> Conditions.Dispatch(~Schema.World(~S),~P.Guard(~S),~String):Conditions.retained_leaf_dispatch(~S,~P.Columns(~S),~Schema.Resources(~S),~Unit,~P.GuardOps(~S),~P.Local,~String,~P.guard_program(~S),~P.guard_body(~S),~P.guard_construction(~S))
def Nodes(~S:Data) -> Type:Reg.Product<P.Left(~S),P.Right(~S)>
def left_dispatch(~S:Data) -> P.Left(~S) -> Schema.World(~S) -> U32 -> P.Left(~S) & (Schema.World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~P.LeftOps(~S),~P.Local,~String,~String,~P.left_program(~S),~P.left_body(~S),~P.left_construction(~S))
def left_facts(~S:Data,node:P.Left(~S)) -> Registry.Facts<Reg.Registry<Schema.World(~S),P.Left(~S),String,String,left_dispatch(~S)>>:Registry.ordinary(~Schema.World(~S),~P.Left(~S),~String,~String,~left_dispatch(~S),Leaf.facts(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~P.LeftOps(~S),~P.Local,~String,~String,~P.left_program(~S),~P.left_body(~S),~P.left_construction(~S),node))
def right_dispatch(~S:Data) -> P.Right(~S) -> Schema.World(~S) -> U32 -> P.Right(~S) & (Schema.World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~P.RightOps(~S),~P.Local,~String,~String,~P.right_program(~S),~P.right_body(~S),~P.right_construction(~S))
def right_facts(~S:Data,node:P.Right(~S)) -> Registry.Facts<Reg.Registry<Schema.World(~S),P.Right(~S),String,String,right_dispatch(~S)>>:Registry.ordinary(~Schema.World(~S),~P.Right(~S),~String,~String,~right_dispatch(~S),Leaf.facts(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~P.RightOps(~S),~P.Local,~String,~String,~P.right_program(~S),~P.right_body(~S),~P.right_construction(~S),node))
def node_dispatch(~S:Data) -> Nodes(~S) -> Schema.World(~S) -> U32 -> Nodes(~S) & (Schema.World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~Schema.World(~S),~P.Left(~S),~P.Right(~S),~String,~String,~left_dispatch(~S),~right_dispatch(~S))
def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<Schema.World(~S),Nodes(~S),P.Guard(~S),Handler<S>>>
def build(~S:Data,world:Schema.World(~S),l:P.Left(~S),r:P.Right(~S),guard:P.Guard(~S),reader:Maybe<&1,Target.Reader(~S)>) -> Application(~S):General.build(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~Nodes(~S),~P.Guard(~S),~Handler<S>,~String,~String,~node_dispatch(~S),~dispatch(~S),~(key=>True{}),world,Registry.paired(~Schema.World(~S),~P.Left(~S),~P.Right(~S),~String,~String,~left_dispatch(~S),~right_dispatch(~S),left_facts(~S,l),right_facts(~S,r)),Conditions.compile_retained_leaf(~String,~S,~P.Columns(~S),~Schema.Resources(~S),~Unit,~P.GuardOps(~S),~P.Local,~P.guard_program(~S),~P.guard_body(~S),~P.guard_construction(~S),guard),Handler{ALeaf{803},0,reader},[],[App.Binding{2,3}])
type Defined<-S:Data> is Type:
  Defined{app:Application(~S)}
  LeftRefused{world:Schema.World(~S),local:P.Local,reader:Maybe<&1,Target.Reader(~S)>}
  RightRefused{world:Schema.World(~S),left:P.Left(~S),local:P.Local,reader:Maybe<&1,Target.Reader(~S)>}
  GuardRefused{world:Schema.World(~S),left:P.Left(~S),right:P.Right(~S),compilation:P.GuardCompilation(~S),local:P.Local,reader:Maybe<&1,Target.Reader(~S)>}
def guard_defined(~S:Data,l:P.Left(~S),r:P.Right(~S),reader:Maybe<&1,Target.Reader(~S)>,result:P.GuardCompilation(~S) & Sys.Defined<Schema.World(~S),P.GuardOwner(~S),P.Local>) -> Defined<S>:
  match result:
    case (compilation,Sys.Defined{world,guard}):Defined{build(~S,world,l,r,Retained.pack(P.GuardCompilation(~S),P.GuardOwner(~S),compilation,guard),reader)}
    case (compilation,Sys.DefinitionRefused{world,local}):GuardRefused{world,l,r,compilation,local,reader}
def right_defined(~S:Data,l:P.Left(~S),reader:Maybe<&1,Target.Reader(~S)>,result:P.RightCompilation(~S) & Sys.Defined<Schema.World(~S),P.RightOwner(~S),P.Local>) -> Defined<S>:
  match result:
    case (compilation,Sys.Defined{world,r}):guard_defined(~S,l,Retained.pack(P.RightCompilation(~S),P.RightOwner(~S),compilation,r),reader,Registration.define_with_compilation(~S,~P.Columns(~S),~P.Columns(~S),~Schema.Resources(~S),~Unit,~P.GuardOps(~S),~P.Local,~String,~Bool,~P.guard_program(~S),~P.guard_body(~S),~Schema.Resources(~S),P.guard_construction(~S),world,"restored-waiting",P.Local{ALeaf{903},0}))
    case (_,Sys.DefinitionRefused{world,local}):RightRefused{world,l,local,reader}
def left_defined(~S:Data,reader:Maybe<&1,Target.Reader(~S)>,result:P.LeftCompilation(~S) & Sys.Defined<Schema.World(~S),P.LeftOwner(~S),P.Local>) -> Defined<S>:
  match result:
    case (compilation,Sys.Defined{world,l}):right_defined(~S,Retained.pack(P.LeftCompilation(~S),P.LeftOwner(~S),compilation,l),reader,Leaf.define_with_compilation(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~P.RightOps(~S),~P.Local,~String,~String,~P.right_program(~S),~P.right_body(~S),P.right_construction(~S),world,"restored-transition",P.Local{ALeaf{703},0}))
    case (_,Sys.DefinitionRefused{world,local}):LeftRefused{world,local,reader}
def setup(~S:Data,world:Schema.World(~S),reader:Maybe<&1,Target.Reader(~S)>) -> Defined<S>:left_defined(~S,reader,Leaf.define_with_compilation(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~P.LeftOps(~S),~P.Local,~String,~String,~P.left_program(~S),~P.left_body(~S),P.left_construction(~S),world,"retained-graph-read",P.Local{ALeaf{603},0}))
def pending(~S:Data,app:Application(~S)) -> Application(~S) & Bool:
  match app:
    case Schedule.Scheduled{App.State{W.World{namespace,allocator,columns,resources,events,pending,+registrations,next,clock,lifecycle},owners,guard,handler,stateBindings},plan,appBindings,+deferred}:
      match deferred:
        case Schedule.Deferred{_,_,unapplied,_,_}:(Schedule.Scheduled{App.State{W.World{namespace,allocator,columns,resources,events,pending,registrations,next,clock,lifecycle},owners,guard,handler,stateBindings},plan,appBindings,deferred},OrdinarySchedule.unknown(unapplied,registrations))
def publish(~S:Data,ids:List<&2,U32>,world:Schema.World(~S),nodes:Nodes(~S)) -> Schema.World(~S) & (Nodes(~S) & List<&2,U32>):(world,(nodes,ids))
def run(~S:Data,app:Application(~S)) -> Application(~S) & App.Report<String,String>:General.run(~S,~Schema.components(~S),~Schema.resource_layout(~S),~Unit,~Nodes(~S),~P.Guard(~S),~Handler<S>,~String,~String,~node_dispatch(~S),~dispatch(~S),~handle(~S),~publish(~S),app)
type Held<-S:Data> is Type:Held{owners:Nodes(~S),guard:P.Guard(~S),handler:Handler<S>,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,appBindings:List<&2,App.Binding>,deferred:Schedule.Deferred}
def rejoin(~S:Data,held:Held<S>,world:Schema.World(~S)) -> Application(~S):
  match held:
    case Held{owners,guard,handler,stateBindings,plan,appBindings,deferred}:Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,deferred}
type Restoration<-S:Data> is Type:
  Pending{schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Application(~S)}
  InputRefused{app:Application(~S),schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,reason:Admission.Reason}
  NamespaceRefused{app:Application(~S),state:Restore.State<S>}
  ReceiverRefused{app:Application(~S),state:Restore.State<S>,reason:Receiver.Reason}
  StagingRefused{app:Application(~S),state:Restore.State<S>,error:R.Error<Unit>}
  RowsRefused{app:Application(~S),state:Restore.State<S>,rows:List<Publication.Row<Schema.components(~S)>>}
  Restored{app:Application(~S),state:Restore.State<S>,removed:List<Ordinary.Receipt(~S)>,mapping:List<&2,R.Binding<S>>,publications:List<Publication.Receipt<S,Schema.components(~S)>>,previous:Restore.Previous<S>}
  Refused{held:Held<S>,result:Restore.Outcome<S>}
def completed(~S:Data,held:Held<S>,result:Restore.Outcome<S>) -> Restoration<S>:
  match result:
    case Restore.InputRefused{world,schema,input,reason}:InputRefused{rejoin(~S,held,world),schema,input,reason}
    case Restore.NamespaceRefused{state,world}:NamespaceRefused{rejoin(~S,held,world),state}
    case Restore.ReceiverRefused{state,Receiver.Refused{world,reason}}:ReceiverRefused{rejoin(~S,held,world),state,reason}
    case Restore.StagingRefused{state,world,error}:StagingRefused{rejoin(~S,held,world),state,error}
    case Restore.RowsRefused{state,world,rows}:RowsRefused{rejoin(~S,held,world),state,rows}
    case Restore.Restored{state,world,removed,mapping,publications,previous}:Restored{rejoin(~S,held,world),state,removed,mapping,publications,previous}
    case result:Refused{held,result}
def checked(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,result:Application(~S) & Bool) -> Restoration<S>:
  match result:
    case (app,True{}):Pending{schema,input,app}
    case (Schedule.Scheduled{App.State{world,owners,guard,handler,stateBindings},plan,appBindings,deferred},False{}):completed(~S,Held{owners,guard,handler,stateBindings,plan,appBindings,deferred},Restore.restore(~S,schema,input,world))
def restore(~S:Data,schema:Admission.Recipes(~S),input:Extended.Snapshot<S>,app:Application(~S)) -> Restoration<S>:checked(~S,schema,input,pending(~S,app))
