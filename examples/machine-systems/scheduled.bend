import Base
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-registry.bend as Facts
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-builder.bend as Build
import ./declarations.bend as D
import ./bodies.bend as Body
import ./registry.bend as Registry
import ./peer.bend as Peer
import ./guard-registry.bend as Guards
import ../../src/ecs/execution-retained-system.bend as Scope
import ./conditions.bend as Cond
import ./actor.bend as Actor
import ./exit.bend as Exit
import ./allocation.bend as Alloc
import ./events.bend as Events
import ./observation.bend as Observe
import ./owner-observation.bend as Owners
import ../../src/ecs/execution-command-system.bend as Cmd
import ./reports.bend as Report
import ./initialize.bend as Init
import ../../src/ecs/execution-machine-state.bend as State
import ../../src/ecs/execution-machine-maintenance.bend as Maintenance
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-registration.bend as Registration
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan

def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def World(~S:Data) -> Type:W.World<S,D.Store(~S),Resources(~S),Unit>
def PeerOwner(~S:Data) -> Type:Peer.Owner(~S)

def PeerCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),Resources(~S),Peer.Ops(~S)>
def peer_compilation(~S:Data) -> PeerCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Peer.Ops(~S),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Peer.Ops(~S),~Peer.declaration(~S)))
def PeerNode(~S:Data) -> Type:Leaf.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Peer.Ops(~S),~Peer.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Peer.Ops(~S),~Peer.declaration(~S)),~Peer.body(~S))
def Nodes(~S:Data) -> Type:Reg.Product<Registry.Owners(~S),PeerNode(~S)>
def peer_dispatch(~S:Data) -> PeerNode(~S) -> World(~S) -> U32 -> PeerNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Peer.Ops(~S),~Peer.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Peer.Ops(~S),~Peer.declaration(~S)),~Peer.body(~S),~peer_compilation(~S))
def dispatch(~S:Data) -> Nodes(~S) -> World(~S) -> U32 -> Nodes(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~Registry.Owners(~S),~PeerNode(~S),~String,~String,~Registry.owners_dispatch(~S),~peer_dispatch(~S))
def facts(~S:Data,left:Registry.Owners(~S),right:PeerNode(~S)) -> Facts.Facts<Reg.Registry<World(~S),Nodes(~S),String,String,dispatch(~S)>>:Facts.paired(~World(~S),~Registry.Owners(~S),~PeerNode(~S),~String,~String,~Registry.owners_dispatch(~S),~peer_dispatch(~S),Registry.owners_facts(~S,left),Facts.ordinary(~World(~S),~PeerNode(~S),~String,~String,~peer_dispatch(~S),Leaf.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Peer.Ops(~S),~Peer.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Peer.Ops(~S),~Peer.declaration(~S)),~Peer.body(~S),~peer_compilation(~S),right)))
def pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & Bool):Retention.pending_pair(~World(~S),~Registry.Owners(~S),~PeerNode(~S),~Registry.owners_pending(~S),~Retention.pending_none(~World(~S),~PeerNode(~S)),ids,world,nodes)
def publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Nodes(~S)) -> World(~S) & Nodes(~S):Retention.publish_pair(~World(~S),~Registry.Owners(~S),~PeerNode(~S),~Registry.owners_publish(~S),~Retention.publish_none(~World(~S),~PeerNode(~S)),ids,tick,world,nodes)
def collect(~S:Data,ids:List<&2,U32>,nodes:Nodes(~S)) -> Nodes(~S) & List<&2,U32>:Retention.collect_pair(~Registry.Owners(~S),~PeerNode(~S),~Registry.owners_collect(~S),~Retention.collect_none(~PeerNode(~S)),ids,nodes)
def publication(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):Publication.apply(~S,~D.Store(~S),~Resources(~S),~Unit,~Nodes(~S),~pending(~S),~publish(~S),~collect(~S),ids,world,nodes)

def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<World(~S),Nodes(~S),Guards.Owners(~S),Report.Handler>>
type BuildResult<-S:Data> is Type:
  BuildReady{app:Application(~S)}
  BuildRefused{error:String}
def empty(~S:Data,_:Unit) -> D.Store(~S):Layout.empty_columns(~S,D.component_layout(~S))
def resources(~S:Data) -> Resources(~S):
  Product.Owner{Layout.ResourceSlot{Layout.initialize(D.layout(S),Layout.AtLeaf{},State.empty(~S,~D.Key,~D.Mode)),Layout.unknown_stamp()},Unit{}}
def machine_shape(~S:Data) -> {Layout.payload(Cond.layout(S),Layout.InLeft{Layout.AtLeaf{}}) == State.Cell<S,D.Key,D.Mode> : Type}:{==}
def completed(~S:Data,result:Application(~S) & App.Report<String,String>) -> Application(~S) & App.Report<String,String>:
  Maintenance.completed(~S,~D.Key,~D.Mode,~D.Store(~S),~Resources(~S),~Unit,~Cond.layout(S),~Layout.InLeft{Layout.AtLeaf{}},~{==},~machine_shape(~S),~Nodes(~S),~Guards.Owners(~S),~Report.Handler,~String,~String,result)
def run_once(~S:Data,app:Application(~S)) -> IO(Application(~S) & App.Report<String,String>):
  IO.pure(Application(~S) & App.Report<String,String>,completed(~S,General.run(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Nodes(~S),~Guards.Owners(~S),~Report.Handler,~String,~String,~dispatch(~S),~Guards.dispatch(~S),~Report.handle,~publication(~S),app)))
def finished(~S:Data,history:List<&2,String>,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{App.State{world,Reg.Product{left,right,_},guards,handler,_},_,_,_}:"runs=" ++ List.show(&2,String,Observe.text,history) ++ "|world{" ++ Observe.world(~S,world) ++ "}|owners{" ++ Owners.left(~S,left) ++ ";peer{" ++ Owners.peer(~S,Scope.owner(PeerCompilation(~S),PeerOwner(~S),right)) ++ "}}|guards{" ++ Owners.guards(~S,guards) ++ "}|handler=" ++ Report.handler(handler)
def continued(~S:Data,next:List<&2,String> -> Application(~S) -> IO(String),history:List<&2,String>,result:Application(~S) & App.Report<String,String>) -> IO(String):
  match result:
    case (app,status):next(List.append(&2,String,history,[Report.report(status)]),app)
def updates(~S:Data,fuel:Nat,history:List<&2,String>,app:Application(~S)) -> IO(String):
  match fuel:
    case 0n:IO.pure(String,finished(~S,history,app))
    case 1n++rest:IO.bind(Application(~S) & App.Report<String,String>,String,run_once(~S,app),result => continued(~S,history => app => updates(~S,rest,history,app),history,result))
def guard_running_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerNode(~S),exit:Guards.Owner(~S),transition:Guards.Owner(~S),enter:Guards.Owner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,running}):IO.pure(BuildResult<S>,BuildReady{General.build(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Nodes(~S),~Guards.Owners(~S),~Report.Handler,~String,~String,~dispatch(~S),~Guards.dispatch(~S),~Report.available,world,facts(~S,owners,peer),Guards.registry(~S,Guards.pack(~S,exit,transition,enter,Scope.pack(Guards.Compilation(~S),Guards.System(~S),compilation,running))),Report.Handler{ALeaf{801},0},[Plan.Edge{1,3},Plan.Edge{3,4},Plan.Edge{4,5},Plan.Edge{5,6},Plan.Edge{6,7}],[App.Binding{3,8},App.Binding{4,9},App.Binding{5,10},App.Binding{6,11},App.Binding{7,11}])})
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:running-guard"})
def guard_enter_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerNode(~S),exit:Guards.Owner(~S),transition:Guards.Owner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,enter}):guard_running_defined(~S,owners,peer,exit,transition,Scope.pack(Guards.Compilation(~S),Guards.System(~S),compilation,enter),Guards.define(~S,world,"running-guard",Cond.Local{ALeaf{902},Cond.Running{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:enter-guard"})
def guard_transition_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerNode(~S),exit:Guards.Owner(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,transition}):guard_enter_defined(~S,owners,peer,exit,Scope.pack(Guards.Compilation(~S),Guards.System(~S),compilation,transition),Guards.define(~S,world,"enter-guard",Cond.Local{ALeaf{901},Cond.Enter{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:transition-guard"})
def guard_exit_defined(~S:Data,owners:Registry.Owners(~S),peer:PeerNode(~S),result:Guards.Compilation(~S) & Sys.Defined<World(~S),Guards.System(~S),Cond.Local>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,exit}):guard_transition_defined(~S,owners,peer,Scope.pack(Guards.Compilation(~S),Guards.System(~S),compilation,exit),Guards.define(~S,world,"transition-guard",Cond.Local{ALeaf{900},Cond.Transition{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:exit-guard"})
def events_defined(~S:Data,+handle:W.Handle<S>,apply:Registry.ApplyNode(~S),peer:PeerNode(~S),exit:Registry.ExitNode(~S),transition:Registry.ReadNode(~S),enter:Registry.RequestNode(~S),read:Registry.ActorNode(~S),result:Registry.EventsCompilation(~S) & Sys.Defined<World(~S),Registry.EventsOwner(~S),Events.Local<S>>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,events}):guard_exit_defined(~S,Registry.pack(~S,apply,exit,transition,enter,read,Scope.pack(Registry.EventsCompilation(~S),Registry.EventsOwner(~S),compilation,Events.bound(~S,events))),peer,Guards.define(~S,world,"exit-guard",Cond.Local{ALeaf{900},Cond.ExitPhase{}}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:events"})
def read_defined(~S:Data,+handle:W.Handle<S>,apply:Registry.ApplyNode(~S),peer:PeerNode(~S),exit:Registry.ExitNode(~S),transition:Registry.ReadNode(~S),enter:Registry.RequestNode(~S),result:Registry.ActorCompilation(~S) & Sys.Defined<World(~S),Registry.ActorOwner(~S),Actor.Local<S>>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,read}):events_defined(~S,handle,apply,peer,exit,transition,enter,Scope.pack(Registry.ActorCompilation(~S),Registry.ActorOwner(~S),compilation,read),Registration.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Events.Ops(~S),~Events.declaration(~S)),~Events.body(~S),~Resources(~S),Registry.events_compilation(~S),world,"transition-events",Events.Local{None{},Body.local(701,702)}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:read"})
def enter_defined(~S:Data,+handle:W.Handle<S>,apply:Registry.ApplyNode(~S),peer:PeerNode(~S),exit:Registry.ExitNode(~S),transition:Registry.ReadNode(~S),result:Registry.RequestCompilation(~S) & Sys.Defined<World(~S),Registry.RequestOwner(~S),Body.Local()>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,enter}):read_defined(~S,handle,apply,peer,exit,transition,Scope.pack(Registry.RequestCompilation(~S),Registry.RequestOwner(~S),compilation,enter),Registration.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),~Actor.body(~S),~Resources(~S),Registry.actor_compilation(~S),world,"state-running",Actor.Local{handle,Body.local(601,602)}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:enter"})
def transition_defined(~S:Data,+handle:W.Handle<S>,apply:Registry.ApplyNode(~S),peer:PeerNode(~S),exit:Registry.ExitNode(~S),result:Registry.ReadCompilation(~S) & Sys.Defined<World(~S),Registry.ReadOwner(~S),Body.Local()>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,transition}):enter_defined(~S,handle,apply,peer,exit,Scope.pack(Registry.ReadCompilation(~S),Registry.ReadOwner(~S),compilation,transition),Registration.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Unit,~D.request_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~D.request_ops(~S),~D.request(~S)),~Body.request(~S),~Resources(~S),Registry.request_compilation(~S),world,"enter",Body.local(501,502)))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:transition"})
def exit_defined(~S:Data,+handle:W.Handle<S>,apply:Registry.ApplyNode(~S),peer:PeerNode(~S),result:Registry.ExitCompilation(~S) & Sys.Defined<World(~S),Registry.ExitOwner(~S),Exit.Captures(~S)>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,exit}):transition_defined(~S,handle,apply,peer,Scope.pack(Registry.ExitCompilation(~S),Registry.ExitOwner(~S),compilation,exit),Registration.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Unit,~D.read_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~D.read_ops(~S),~D.read(~S)),~Body.read(~S),~Resources(~S),Registry.read_compilation(~S),world,"transition",Body.local(401,402)))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:exit"})
def peer_defined(~S:Data,+handle:W.Handle<S>,apply:Registry.ApplyNode(~S),result:PeerCompilation(~S) & Sys.Defined<World(~S),PeerOwner(~S),Peer.Local<S>>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,peer}):exit_defined(~S,handle,apply,Scope.pack(PeerCompilation(~S),PeerOwner(~S),compilation,peer),Author.define_with_compilation(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S),~{==},Registry.exit_compilation(~S),world,"exit",Exit.User{handle,Body.local(301,302)}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:peer"})
def apply_defined(~S:Data,+handle:W.Handle<S>,result:Registry.ApplyCompilation(~S) & Sys.Defined<World(~S),Registry.ApplyOwner(~S),Body.Local()>) -> IO(BuildResult<S>):
  match result:
    case (compilation,Sys.Defined{world,apply}):peer_defined(~S,handle,Scope.pack(Registry.ApplyCompilation(~S),Registry.ApplyOwner(~S),compilation,apply),Registration.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Unit,~Peer.Ops(~S),~Peer.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Peer.Ops(~S),~Peer.declaration(~S)),~Peer.body(~S),~Resources(~S),peer_compilation(~S),world,"peer",Peer.Local{handle,Body.local(201,202)}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(BuildResult<S>,BuildRefused{"ERROR:apply"})
def allocated(~S:Data,result:Alloc.Allocation<S>) -> IO(BuildResult<S>):
  match result:
    case Alloc.AllocationReady{world,+handle}:apply_defined(~S,handle,Registration.define_with_compilation(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~Unit,~D.apply_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~Resources(~S),~D.apply_ops(~S),~D.apply(~S)),~Body.apply(~S),~Resources(~S),Registry.apply_compilation(~S),world,"state-marker",Body.local(101,102)))
    case Alloc.Refused{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:allocation"})
def initialized(~S:Data,world:World(~S)) -> IO(BuildResult<S>):allocated(~S,Alloc.allocate(~S,world))
def created(~S:Data,result:W.Creation<S,D.Store(~S),Resources(~S),Unit>) -> IO(BuildResult<S>):
  match result:
    case W.Created{_,world}:initialized(~S,Init.setup(~S,world))
    case W.CreateRejected{_,_}:IO.pure(BuildResult<S>,BuildRefused{"ERROR:create"})
def prepare(~S:Data) -> IO(BuildResult<S>):created(~S,W.create(~S,~D.Store(~S),~Resources(~S),~Unit,~empty(~S),W.factory(),resources(~S)))
def execute_prepared(~S:Data,result:BuildResult<S>) -> IO(String):
  match result:
    case BuildReady{app}:updates(~S,4n,[],app)
    case BuildRefused{error}:IO.pure(String,error)
def run(~S:Data) -> IO(String):
  IO.bind(BuildResult<S>,String,prepare(~S),built => execute_prepared(~S,built))
type Schema is Data:
  Schema{}
def main() -> IO(Unit):IO.bind(String,Unit,run(~Schema),IO.print)
