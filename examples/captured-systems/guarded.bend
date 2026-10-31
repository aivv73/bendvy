import Base
import ../../src/ecs/execution-effects.bend as Effects
import ./guarded-nodes.bend as Nodes
import ./conditions.bend as Cond
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./reports.bend as Common
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system-lifecycle.bend as Life
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

def guard_kernel(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Cond.Ops(~S,Permit,F,H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~Cond.declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def GuardCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),Cond.Ops(~S)>
def guard_construction(~S:Data) -> GuardCompilation(~S):Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Cond.Ops(~S),~guard_kernel(~S))
def GuardRawOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,Cond.Ops(~S),Cond.Local(),String,Bool,guard_kernel(~S),Cond.body(~S)>
def GuardOwner(~S:Data) -> Type:Conditions.RetainedSystem(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~guard_kernel(~S),~Cond.body(~S))
def guard_dispatch(~S:Data) -> GuardOwner(~S) -> Nodes.World(~S) -> U32 -> GuardOwner(~S) & (Nodes.World(~S) & Exec.Invocation<String,Bool>):
  Conditions.retained_leaf_dispatch(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~guard_kernel(~S),~Cond.body(~S),~guard_construction(~S))
def World(~S:Data) -> Type:Nodes.World(~S)
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.State<World(~S),Nodes.Nodes(~S),GuardOwner(~S),Common.Handler>>
def report(value:DepApp.Report<String,String>) -> String:Common.report(value)
def text(value:String) -> String:value
def released(~S:Data,trace:String,ll:Body.LeftLocal(),ol:Body.LeftLocal(),lc:Maybe<&2,Tick.Tick>,oc:Maybe<&2,Tick.Tick>,gl:Cond.Local(),gc:Maybe<&2,Tick.Tick>,handler:Common.Handler,world:World(~S),result:Life.Released<Body.RightLocal()>) -> String:
  match result:
    case Life.Released{Life.Identity{namespace,id,name,access,rc},rl}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Body.observe_left(ll) ++ "," ++ Body.observe_right(rl) ++ "," ++ Body.observe_left(ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ Common.handler(handler) ++ "|guard=" ++ Cond.observed(gl) ++ "|guard-cursor=" ++ Tick.cursor_show(gc) ++ "|released=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access)
def cleaned(~S:Data,trace:String,ll:Body.LeftLocal(),ol:Body.LeftLocal(),lc:Maybe<&2,Tick.Tick>,oc:Maybe<&2,Tick.Tick>,gl:Cond.Local(),gc:Maybe<&2,Tick.Tick>,handler:Common.Handler,result:Life.Retirement<World(~S),Nodes.RightNode(~S)>) -> String:
  match result:
    case Life.Retired{world,Life.Detached{right}}:released(~S,trace,ll,ol,lc,oc,gl,gc,handler,world,Life.release(~S,~Nodes.C(~S),~Nodes.C(~S),~Nodes.R(~S),~Unit,~Nodes.RightOps,~Body.RightLocal(),~String,~String,~Nodes.right_kernel(~S),~Nodes.right_body(~S),Life.Detached{Retained.owner(Nodes.RightCompilation(~S),Nodes.RightOwner(~S),right)}))
    case Life.RetirementRefused{_,_}:"ERROR:cleanup"
def observed_owners(~S:Data,trace:String,world:World(~S),right:Nodes.RightNode(~S),handler:Common.Handler,left:Nodes.LeftOwner(~S),other:Nodes.LeftOwner(~S),guard:GuardRawOwner(~S)) -> String:
  match left other guard:
    case Sys.Owner{_,_,_,_,lc,ll}, Sys.Owner{_,_,_,_,oc,ol}, Sys.Owner{_,_,_,_,gc,gl}:cleaned(~S,trace,ll,ol,lc,oc,gl,gc,handler,Nodes.retire(~S,right,world))
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{Reg.Product{left,other,_},right,_},guard,handler,_},_,_,_}:observed_owners(~S,trace,world,right,handler,Retained.owner(Nodes.LeftCompilation(~S),Nodes.LeftOwner(~S),left),Retained.owner(Nodes.LeftCompilation(~S),Nodes.LeftOwner(~S),other),Retained.owner(GuardCompilation(~S),GuardRawOwner(~S),guard))
def run_application(~S:Data,app:Application(~S)) -> Application(~S) & DepApp.Report<String,String>:
  General.run(~S,~Nodes.components(),~D.resources_layout(),~Unit,~Nodes.Nodes(~S),~GuardOwner(~S),~Common.Handler,~String,~String,~Nodes.dispatch(~S),~guard_dispatch(~S),~Common.handle,~Nodes.publish(~S),app)
type Remainder<-S:Data> is Type:
  Remainder{left:Nodes.LeftTree(~S),ids:List<&2,U32>,guard:GuardOwner(~S),handler:Common.Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred}
def rebuild(~S:Data,remainder:Remainder<S>,world:World(~S),right:Nodes.RightNode(~S)) -> Application(~S):
  match remainder:
    case Remainder{left,ids,guard,handler,stateBindings,plan,bindings,deferred}:Schedule.Scheduled{DepApp.State{world,Reg.Product{left,right,ids},guard,handler,stateBindings},plan,bindings,deferred}
def identity_raw(~S:Data,right:Nodes.RightOwner(~S)) -> Nodes.RightOwner(~S) & String:
  match right:
    case Sys.Owner{+namespace,+id,+name,+access,+cursor,local}:(Sys.Owner{namespace,id,name,access,cursor,local},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,text,access) ++ ":" ++ Tick.cursor_show(cursor))
def identity(~S:Data,right:Nodes.RightNode(~S)) -> Nodes.RightNode(~S) & String:
  Retained.map_owner(Nodes.RightCompilation(~S),Nodes.RightOwner(~S),String,identity_raw(~S),right)
def identified_app(~S:Data,status:String,remainder:Remainder<S>,world:World(~S),result:Nodes.RightNode(~S) & String) -> Application(~S) & String:
  match result:
    case (right,identity):(rebuild(~S,remainder,world,right),status ++ "=" ++ identity)
def retired_app(~S:Data,remainder:Remainder<S>,result:Life.Retirement<World(~S),Nodes.RightNode(~S)>) -> Application(~S) & String:
  match result:
    case Life.Retired{world,Life.Detached{right}}:identified_app(~S,"retired",remainder,world,identity(~S,right))
    case Life.RetirementRefused{world,right}:(rebuild(~S,remainder,world,right),"ERROR:retirement")
def detach(~S:Data,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{left,right,ids},guard,handler,stateBindings},plan,bindings,deferred}:retired_app(~S,Remainder{left,ids,guard,handler,stateBindings,plan,bindings,deferred},Nodes.retire(~S,right,world))
def restored_app(~S:Data,remainder:Remainder<S>,result:Life.Restoration<World(~S),Nodes.RightNode(~S)>) -> Application(~S) & String:
  match result:
    case Life.Restored{world,right}:identified_app(~S,"restored",remainder,world,identity(~S,right))
    case Life.RestorationRefused{world,Life.Detached{right}}:(rebuild(~S,remainder,world,right),"ERROR:restoration")
def restore(~S:Data,app:Application(~S)) -> Application(~S) & String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{left,right,ids},guard,handler,stateBindings},plan,bindings,deferred}:restored_app(~S,Remainder{left,ids,guard,handler,stateBindings,plan,bindings,deferred},Nodes.reregister(~S,right,world))
def fifth(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ report(status),app)
def reregistered(~S:Data,trace:String,result:Application(~S) & String) -> String:
  match result:
    case (app,status):fifth(~S,trace ++ "|" ++ status,run_application(~S,app))
def fourth(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):reregistered(~S,trace ++ "|" ++ report(status),restore(~S,app))
def detached(~S:Data,trace:String,result:Application(~S) & String) -> String:
  match result:
    case (app,status):fourth(~S,trace ++ "|" ++ status,run_application(~S,app))
def third(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):detached(~S,trace ++ "|" ++ report(status),detach(~S,app))
def second(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):third(~S,trace ++ "|" ++ report(status),run_application(~S,app))
def first(~S:Data,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):second(~S,report(status),run_application(~S,app))
def guard_defined(~S:Data,left:Nodes.LeftNode(~S),right:Nodes.RightNode(~S),other:Nodes.LeftNode(~S),result:GuardCompilation(~S) & Sys.Defined<World(~S),GuardRawOwner(~S),Cond.Local()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,guard}):first(~S,run_application(~S,General.build(~S,~Nodes.components(),~D.resources_layout(),~Unit,~Nodes.Nodes(~S),~GuardOwner(~S),~Common.Handler,~String,~String,~Nodes.dispatch(~S),~guard_dispatch(~S),~Common.available,world,Nodes.facts(~S,left,other,right),Conditions.compile_retained_leaf(~String,~S,~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~guard_kernel(~S),~Cond.body(~S),~guard_construction(~S),Retained.pack(GuardCompilation(~S),GuardRawOwner(~S),compilation,guard)),Common.Handler{ALeaf{701},0},[Plan.Edge{1,2},Plan.Edge{3,2}],[DepApp.Binding{2,4}])))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:guard"
def other_defined(~S:Data,left:Nodes.LeftNode(~S),right:Nodes.RightNode(~S),result:Nodes.LeftCompilation(~S) & Sys.Defined<World(~S),Nodes.LeftOwner(~S),Body.LeftLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,other}):guard_defined(~S,left,right,Nodes.left_node(~S,compilation,other),Register.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Unit,~Cond.Ops(~S),~Cond.Local(),~String,~Bool,~guard_kernel(~S),~Cond.body(~S),~D.Resources(~S),guard_construction(~S),world,"guard",Cond.local()))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:other"
def right_defined(~S:Data,left:Nodes.LeftNode(~S),result:Nodes.RightCompilation(~S) & Sys.Defined<World(~S),Nodes.RightOwner(~S),Body.RightLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,right}):other_defined(~S,left,Nodes.right_node(~S,compilation,right),Nodes.define_left(~S,world,"other",Body.left_local(801,203)))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:right"
def left_defined(~S:Data,result:Nodes.LeftCompilation(~S) & Sys.Defined<World(~S),Nodes.LeftOwner(~S),Body.LeftLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,Nodes.left_node(~S,compilation,left),Nodes.define_right(~S,world,"right",Body.right_local()))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:left"
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:left_defined(~S,Nodes.define_left(~S,world,"left",Body.left_local(501,201)))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data) -> IO(String):
  IO.pure(String,created(~S,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S))))
type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~SchemaA),a => IO.bind(String,Unit,run(~SchemaB),b => IO.print("A=" ++ a ++ "\nB=" ++ b)))
