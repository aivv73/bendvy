import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./application.bend as Ordinary
import ./scheduled.bend as Common
import ./conditions.bend as Cond
import ../../src/ecs/execution-effects.bend as Effects
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def available(_:String) -> Bool:True{}
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/success/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/error/" ++ error ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/refused"
def event_id(value:Exec.Observation<String,String>) -> U32:
  match value:
    case Exec.Ran{id,_}:id
    case Exec.BodyFailed{id,_,_}:id
    case Exec.Skipped{id}:id
    case Exec.ConditionFailed{id,_}:id
    case Exec.ConditionRejected{id}:id
    case Exec.AdmissionRejected{id}:id
def event_selected(selected:Bool,value:Exec.Observation<String,String>,rest:String) -> String:
  match selected:
    case True{}:event(value)
    case False{}:rest
def event_for(+id:U32,values:List<&2,Exec.Observation<String,String>>) -> String:
  match values:
    case []:"missing"
    case +first <> rest:event_selected(U32.is_eq(id,event_id(first)),first,event_for(id,rest))
def report(value:DepApp.Report<String,String>) -> String:
  match value:
    case DepApp.Finished{+events}:"[" ++ event_for(1,events) ++ ", " ++ event_for(2,events) ++ ", " ++ event_for(3,events) ++ "]"
    case DepApp.Stopped{_,events}:"stopped" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case DepApp.Invalid{_}:"invalid"
def handler_observed(errors:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,id):U32.show(id) ++ ":" ++ U32.show(errors)
def handler(owner:Handler) -> String:
  match owner:
    case Handler{token,errors}:handler_observed(errors,Array.get(U32,token,0))
def World(~S:Data) -> Type:Ordinary.World(~S)
def Tail(~S:Data) -> Type:Reg.Product<Ordinary.Right(~S),Ordinary.Left(~S)>
def Nodes(~S:Data) -> Type:Reg.Product<Ordinary.Left(~S),Tail(~S)>
def guard_kernel(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Cond.Ops(~S,Permit,F)(H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def GuardCompilation(~S:Data) -> Type:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),Cond.Ops(~S)>
def guard_construction(~S:Data) -> GuardCompilation(~S):Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~guard_kernel(~S))
def GuardRaw(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,Cond.Ops(~S),Cond.Local<S>,String,Bool,guard_kernel(~S),Cond.body(~S)>
def Guard(~S:Data) -> Type:Conditions.RetainedSystem(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~guard_kernel(~S),~Cond.body(~S))
def guard_dispatch(~S:Data) -> Guard(~S) -> World(~S) -> U32 -> Guard(~S) & (World(~S) & Exec.Invocation<String,Bool>):
  Conditions.retained_leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~guard_kernel(~S),~Cond.body(~S),~guard_construction(~S))
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.State<World(~S),Nodes(~S),Guard(~S),Handler>>
def left_dispatch(~S:Data) -> Ordinary.Left(~S) -> World(~S) -> U32 -> Ordinary.Left(~S) & (World(~S) & Exec.Invocation<String,String>):
  Leaf.dispatch(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~Ordinary.left_program(~S),~Body.left(~S),~Ordinary.left_compilation(~S))
def right_dispatch(~S:Data) -> Ordinary.Right(~S) -> World(~S) -> U32 -> Ordinary.Right(~S) & (World(~S) & Exec.Invocation<String,String>):
  Leaf.dispatch(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~Ordinary.right_program(~S),~Body.right(~S),~Ordinary.right_compilation(~S))
def tail_dispatch(~S:Data) -> Tail(~S) -> World(~S) -> U32 -> Tail(~S) & (World(~S) & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~World(~S),~Ordinary.Right(~S),~Ordinary.Left(~S),~String,~String,~right_dispatch(~S),~left_dispatch(~S))
def dispatch(~S:Data) -> Nodes(~S) -> World(~S) -> U32 -> Nodes(~S) & (World(~S) & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~World(~S),~Ordinary.Left(~S),~Tail(~S),~String,~String,~left_dispatch(~S),~tail_dispatch(~S))
def publish(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):(world,(nodes,ids))
def run_application(~S:Data,app:Application(~S)) -> Application(~S) & DepApp.Report<String,String>:
  General.run(~S,~D.components_layout(),~D.resources_layout(),~Unit,~Nodes(~S),~Guard(~S),~Handler,~String,~String,~dispatch(~S),~guard_dispatch(~S),~handle,~publish(~S),app)
def observed_owners(~S:Data,trace:String,world:World(~S),left:Ordinary.LeftOwner(~S),right:Ordinary.RightOwner(~S),other:Ordinary.LeftOwner(~S),guard:GuardRaw(~S),errorHandler:Handler) -> String:
  match left right other guard:
    case Sys.Owner{_,_,_,_,lc,ll} Sys.Owner{_,_,_,_,rc,lr} Sys.Owner{_,_,_,_,oc,ol} Sys.Owner{_,_,_,_,gc,gl}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Observe.local(~S,ll) ++ "," ++ Observe.local(~S,lr) ++ "," ++ Observe.local(~S,ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ handler(errorHandler) ++ "|guard=" ++ Cond.observed(~S,gl) ++ "|guard-cursor=" ++ Tick.cursor_show(gc)
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{left,Reg.Product{right,other,_},_},guard,errorHandler,_},_,_,_}:observed_owners(~S,trace,world,Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Ordinary.LeftOwner(~S),left),Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,Ordinary.RightOwner(~S),right),Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Ordinary.LeftOwner(~S),other),Retained.owner(GuardCompilation(~S),GuardRaw(~S),guard),errorHandler)
def third(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ report(status),app)
def second(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):third(~S,trace ++ "|" ++ report(status),run_application(~S,app))
def first(~S:Data,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):second(~S,report(status),run_application(~S,app))
def left_facts(~S:Data,node:Ordinary.Left(~S)) -> Registry.Facts<Reg.Registry<World(~S),Ordinary.Left(~S),String,String,left_dispatch(~S)>>:
  Registry.ordinary(~World(~S),~Ordinary.Left(~S),~String,~String,~left_dispatch(~S),Leaf.facts(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~Ordinary.left_program(~S),~Body.left(~S),~Ordinary.left_compilation(~S),node))
def right_facts(~S:Data,node:Ordinary.Right(~S)) -> Registry.Facts<Reg.Registry<World(~S),Ordinary.Right(~S),String,String,right_dispatch(~S)>>:
  Registry.ordinary(~World(~S),~Ordinary.Right(~S),~String,~String,~right_dispatch(~S),Leaf.facts(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~Ordinary.right_program(~S),~Body.right(~S),~Ordinary.right_compilation(~S),node))
def application(~S:Data,world:World(~S),left:Ordinary.Left(~S),right:Ordinary.Right(~S),other:Ordinary.Left(~S),guard:Guard(~S)) -> Application(~S):
  General.build(~S,~D.components_layout(),~D.resources_layout(),~Unit,~Nodes(~S),~Guard(~S),~Handler,~String,~String,~dispatch(~S),~guard_dispatch(~S),~available,world,Registry.paired(~World(~S),~Ordinary.Left(~S),~Tail(~S),~String,~String,~left_dispatch(~S),~tail_dispatch(~S),left_facts(~S,left),Registry.paired(~World(~S),~Ordinary.Right(~S),~Ordinary.Left(~S),~String,~String,~right_dispatch(~S),~left_dispatch(~S),right_facts(~S,right),left_facts(~S,other))),Conditions.compile_retained_leaf(~String,~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~guard_kernel(~S),~Cond.body(~S),~guard_construction(~S),guard),Handler{ALeaf{701},0},[],[DepApp.Binding{2,4}])
def guard_defined(~S:Data,left:Ordinary.Left(~S),right:Ordinary.Right(~S),other:Ordinary.Left(~S),result:GuardCompilation(~S) & Sys.Defined<World(~S),GuardRaw(~S),Cond.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,guard}):first(~S,run_application(~S,application(~S,world,left,right,other,Retained.pack(GuardCompilation(~S),GuardRaw(~S),compilation,guard))))
    case _:"ERROR:guard"
def other_defined(~S:Data,handle:W.Handle<S>,left:Ordinary.Left(~S),right:Ordinary.Right(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,other}):guard_defined(~S,left,right,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,compilation,other),Register.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local<S>,~String,~Bool,~guard_kernel(~S),~Cond.body(~S),~D.Resources(~S),guard_construction(~S),world,"guard",Cond.Local{ALeaf{901},0,"unset",handle}))
    case _:"ERROR:other"
def right_defined(~S:Data,+handle:W.Handle<S>,left:Ordinary.Left(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)> & Sys.Defined<World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,Ordinary.right_program(~S),Body.right(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,right}):other_defined(~S,handle,left,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,Ordinary.right_program(~S),Body.right(~S)>,compilation,right),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~Ordinary.left_program(~S),~Body.left(~S),Ordinary.left_compilation(~S),world,"other",Body.Local{ALeaf{801},0,handle}))
    case _:"ERROR:right define"
def left_defined(~S:Data,+handle:W.Handle<S>,result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,handle,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,compilation,left),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~Ordinary.right_program(~S),~Body.right(~S),Ordinary.right_compilation(~S),world,"right",Body.Local{ALeaf{601},0,handle}))
    case _:"ERROR:left define"
def activated(~S:Data,+handle:W.Handle<S>,result:World(~S) & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):left_defined(~S,handle,Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~Ordinary.left_program(~S),~Body.left(~S),Ordinary.left_compilation(~S),world,"left",Body.Local{ALeaf{501},0,handle}))
    case _:"ERROR:activate"
def reserved(~S:Data,result:World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case _:"ERROR:reserve"
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:reserved(~S,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data) -> String:created(~S,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
def main() -> IO(Unit):IO.print("A=" ++ run(~SchemaA) ++ "\nB=" ++ run(~SchemaB))
