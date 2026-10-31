import Base
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-system-registration.bend as Registration
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-registry.bend as Facts
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-retained-system.bend as Held
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ./declarations.bend as D
import ./bodies.bend as Body
import ./exit.bend as Exit
import ./peer.bend as Peer
import ./registry.bend as Registry
import ./scheduled.bend as Main
import ./initialize.bend as Init
import ./allocation.bend as Allocation
import ./observation.bend as Observe
import ./owner-observation.bend as Owners
import ./reports.bend as Report
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-machine-maintenance.bend as Maintenance
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

type Schema is Data:
  Schema{}
type Handler is Type:
  Handler{stop:Bool,token:Array<U32>,errors:U32}
def handling(stop:Bool) -> Exec.Handling:
  match stop:
    case True{}:Exec.Escalate{}
    case False{}:Exec.Continue{}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{+stop,token,errors}:(Handler{stop,token,U32.add(errors,1)},handling(stop))
def handler_observed(stop:Bool,errors:U32,result:Array<U32> & U32) -> String:
  match result:
    case (_,token):Observe.bool(stop) ++ "/" ++ U32.show(token) ++ "/errors=" ++ U32.show(errors)
def handler_text(owner:Handler) -> String:
  match owner:
    case Handler{stop,token,errors}:handler_observed(stop,errors,Array.get(U32,token,0))




def World() -> Type:Main.World(~Schema)
def peer_facts(node:Main.PeerNode(~Schema)) -> Facts.Facts<Reg.Registry<World(),Main.PeerNode(~Schema),String,String,Main.peer_dispatch(~Schema)>>:Facts.ordinary(~World(),~Main.PeerNode(~Schema),~String,~String,~Main.peer_dispatch(~Schema),Leaf.facts(~Schema,~D.component_layout(~Schema),~D.root_layout(Schema),~Unit,~Peer.Ops(~Schema),~Peer.Local<Schema>,~String,~String,~Build.framework_program(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~Peer.Ops(~Schema),~Peer.declaration(~Schema)),~Peer.body(~Schema),~Main.peer_compilation(~Schema),node))
def CommandPair() -> Type:Reg.Product<Registry.ApplyNode(~Schema),Registry.ExitNode(~Schema)>
def pair_dispatch() -> CommandPair() -> World() -> U32 -> CommandPair() & (World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(),~Registry.ApplyNode(~Schema),~Registry.ExitNode(~Schema),~String,~String,~Registry.apply_dispatch(~Schema),~Registry.exit_dispatch(~Schema))
def pair_facts(nodes:CommandPair()) -> Facts.Facts<Reg.Registry<World(),CommandPair(),String,String,pair_dispatch()>>:
  match nodes:
    case Reg.Product{left,right,_}:Facts.paired(~World(),~Registry.ApplyNode(~Schema),~Registry.ExitNode(~Schema),~String,~String,~Registry.apply_dispatch(~Schema),~Registry.exit_dispatch(~Schema),Registry.apply_facts(~Schema)(left),Registry.exit_facts(~Schema)(right))
def pair_pending(ids:List<&2,U32>,world:World(),nodes:CommandPair()) -> World() & (CommandPair() & Bool):Retention.pending_pair(~World(),~Registry.ApplyNode(~Schema),~Registry.ExitNode(~Schema),~Retention.pending_none(~World(),~Registry.ApplyNode(~Schema)),~Registry.exit_pending(~Schema),ids,world,nodes)
def pair_publish(ids:List<&2,U32>,tick:Tick.Tick,world:World(),nodes:CommandPair()) -> World() & CommandPair():Retention.publish_pair(~World(),~Registry.ApplyNode(~Schema),~Registry.ExitNode(~Schema),~Retention.publish_none(~World(),~Registry.ApplyNode(~Schema)),~Registry.exit_publish(~Schema),ids,tick,world,nodes)
def pair_collect(ids:List<&2,U32>,nodes:CommandPair()) -> CommandPair() & List<&2,U32>:Retention.collect_pair(~Registry.ApplyNode(~Schema),~Registry.ExitNode(~Schema),~Retention.collect_none(~Registry.ApplyNode(~Schema)),~Registry.exit_collect(~Schema),ids,nodes)
def Left() -> Type:Reg.Product<Registry.RequestNode(~Schema),CommandPair()>
def left_dispatch() -> Left() -> World() -> U32 -> Left() & (World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(),~Registry.RequestNode(~Schema),~CommandPair(),~String,~String,~Registry.request_dispatch(~Schema),~pair_dispatch())
def left_facts(nodes:Left()) -> Facts.Facts<Reg.Registry<World(),Left(),String,String,left_dispatch()>>:
  match nodes:
    case Reg.Product{left,right,_}:Facts.paired(~World(),~Registry.RequestNode(~Schema),~CommandPair(),~String,~String,~Registry.request_dispatch(~Schema),~pair_dispatch(),Registry.request_facts(~Schema)(left),pair_facts(right))
def left_pending(ids:List<&2,U32>,world:World(),nodes:Left()) -> World() & (Left() & Bool):Retention.pending_pair(~World(),~Registry.RequestNode(~Schema),~CommandPair(),~Retention.pending_none(~World(),~Registry.RequestNode(~Schema)),~pair_pending,ids,world,nodes)
def left_publish(ids:List<&2,U32>,tick:Tick.Tick,world:World(),nodes:Left()) -> World() & Left():Retention.publish_pair(~World(),~Registry.RequestNode(~Schema),~CommandPair(),~Retention.publish_none(~World(),~Registry.RequestNode(~Schema)),~pair_publish,ids,tick,world,nodes)
def left_collect(ids:List<&2,U32>,nodes:Left()) -> Left() & List<&2,U32>:Retention.collect_pair(~Registry.RequestNode(~Schema),~CommandPair(),~Retention.collect_none(~Registry.RequestNode(~Schema)),~pair_collect,ids,nodes)
def Nodes() -> Type:Reg.Product<Left(),Main.PeerNode(~Schema)>
def nodes_dispatch() -> Nodes() -> World() -> U32 -> Nodes() & (World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(),~Left(),~Main.PeerNode(~Schema),~String,~String,~left_dispatch(),~Main.peer_dispatch(~Schema))
def nodes_facts(nodes:Nodes()) -> Facts.Facts<Reg.Registry<World(),Nodes(),String,String,nodes_dispatch()>>:
  match nodes:
    case Reg.Product{left,right,_}:Facts.paired(~World(),~Left(),~Main.PeerNode(~Schema),~String,~String,~left_dispatch(),~Main.peer_dispatch(~Schema),left_facts(left),peer_facts(right))
def nodes_pending(ids:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & Bool):Retention.pending_pair(~World(),~Left(),~Main.PeerNode(~Schema),~left_pending,~Retention.pending_none(~World(),~Main.PeerNode(~Schema)),ids,world,nodes)
def nodes_publish(ids:List<&2,U32>,tick:Tick.Tick,world:World(),nodes:Nodes()) -> World() & Nodes():Retention.publish_pair(~World(),~Left(),~Main.PeerNode(~Schema),~left_publish,~Retention.publish_none(~World(),~Main.PeerNode(~Schema)),ids,tick,world,nodes)
def nodes_collect(ids:List<&2,U32>,nodes:Nodes()) -> Nodes() & List<&2,U32>:Retention.collect_pair(~Left(),~Main.PeerNode(~Schema),~left_collect,~Retention.collect_none(~Main.PeerNode(~Schema)),ids,nodes)
def publication(ids:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & List<&2,U32>):Publication.apply(~Schema,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Nodes(),~nodes_pending,~nodes_publish,~nodes_collect,ids,world,nodes)
def Inner() -> Type:App.State<World(),Nodes(),Unit,Handler>
def Application() -> Type:Schedule.Scheduled<Inner()>
# Root chooses deferred application before this machine hook. A completed run
# rotates messages even with final application disabled; escalation preserves
# the generations and every authored command for the caller's next decision.
def completed(result:Application() & App.Report<String,String>) -> Application() & App.Report<String,String>:
  Maintenance.completed(~Schema,~D.Key,~D.Mode,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Layout.LayoutPair{D.layout(Schema),Layout.EmptyLayout{}},~Layout.InLeft{Layout.AtLeaf{}},~{==},~Main.machine_shape(~Schema),~Nodes(),~Unit,~Handler,~String,~String,result)
def pending_returned(guards:Unit,handler:Handler,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,deferred:Schedule.Deferred,result:World() & (Nodes() & Bool)) -> Application() & Bool:
  match result:
    case (world,(nodes,buffered)):(Schedule.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,deferred},buffered)
def pending(app:Application()) -> Application() & Bool:
  match app:
    case Schedule.Scheduled{App.State{world,nodes,guards,handler,stateBindings},plan,bindings,Schedule.Deferred{+systems,settings,unapplied,compiled,publication}}:pending_returned(guards,handler,stateBindings,plan,bindings,Schedule.Deferred{systems,settings,unapplied,compiled,publication},nodes_pending(systems,world,nodes))
def final(result:Application() & (App.Report<String,String> & Bool)) -> String:
  match result:
    case (Schedule.Scheduled{App.State{world,Reg.Product{Reg.Product{request,Reg.Product{marker,exit,_},_},peer,_},_,handler,_},_,_,Schedule.Deferred{systems,_,unapplied,_,_}},(report,buffered)):Report.report(report) ++ "|buffered=" ++ Observe.bool(buffered) ++ "|command-systems=" ++ List.show(&2,U32,U32.show,systems) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied) ++ "|world{" ++ Observe.world(~Schema,world) ++ "}|request{" ++ Owners.enter(~Schema,Held.owner(Registry.RequestCompilation(~Schema),Registry.RequestOwner(~Schema),request)) ++ "}|marker{" ++ Owners.apply(~Schema,Held.owner(Registry.ApplyCompilation(~Schema),Registry.ApplyOwner(~Schema),marker)) ++ "}|exit{" ++ Owners.exit(~Schema,Held.owner(Registry.ExitCompilation(~Schema),Registry.ExitOwner(~Schema),exit)) ++ "}|peer{" ++ Owners.peer(~Schema,Held.owner(Main.PeerCompilation(~Schema),Peer.Owner(~Schema),peer)) ++ "}|handler=" ++ handler_text(handler)
def retained(report:App.Report<String,String>,result:Application() & Bool) -> Application() & (App.Report<String,String> & Bool):
  match result:
    case (app,buffered):(app,(report,buffered))
def returned(result:Application() & App.Report<String,String>) -> Application() & (App.Report<String,String> & Bool):
  match result:
    case (app,report):retained(report,pending(app))
def run_retained(app:Application()) -> IO(Application() & (App.Report<String,String> & Bool)):
  IO.pure(Application() & (App.Report<String,String> & Bool),returned(completed(General.run(~Schema,~D.component_layout(~Schema),~D.root_layout(Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,~nodes_dispatch(),~Reg.empty_dispatch(~World(),~String,~Bool),~handle,~publication,app))))
def run_once(app:Application()) -> IO(String):IO.bind(Application() & (App.Report<String,String> & Bool),String,run_retained(app),result => IO.pure(String,final(result)))
def built(stop:Bool,finalApply:Bool,world:World(),request:Registry.RequestNode(~Schema),marker:Registry.ApplyNode(~Schema),exit:Registry.ExitNode(~Schema),peer:Main.PeerNode(~Schema)) -> IO(String):
  run_once(Schedule.configure(~Inner(),Settings.Settings{False{},finalApply,[],[]},General.build(~Schema,~D.component_layout(~Schema),~D.root_layout(Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,~nodes_dispatch(),~Reg.empty_dispatch(~World(),~String,~Bool),~Report.available,world,nodes_facts(Reg.Product{Reg.Product{request,Reg.Product{marker,exit,[]},[]},peer,[]}),Reg.empty_conditions(~World(),~String),Handler{stop,ALeaf{801},0},[Plan.Edge{1,2},Plan.Edge{2,3},Plan.Edge{2,4}],[])))
def peer_defined(stop:Bool,finalApply:Bool,+handle:W.Handle<Schema>,request:Registry.RequestNode(~Schema),marker:Registry.ApplyNode(~Schema),exit:Registry.ExitNode(~Schema),result:Main.PeerCompilation(~Schema) & Sys.Defined<World(),Peer.Owner(~Schema),Peer.Local<Schema>>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,peer}):built(stop,finalApply,world,request,marker,exit,Held.pack(Main.PeerCompilation(~Schema),Peer.Owner(~Schema),compilation,peer))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:peer")
def exit_defined(stop:Bool,finalApply:Bool,+handle:W.Handle<Schema>,request:Registry.RequestNode(~Schema),marker:Registry.ApplyNode(~Schema),result:Registry.ExitCompilation(~Schema) & Sys.Defined<World(),Registry.ExitOwner(~Schema),Exit.Captures(~Schema)>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,exit}):peer_defined(stop,finalApply,handle,request,marker,Held.pack(Registry.ExitCompilation(~Schema),Registry.ExitOwner(~Schema),compilation,exit),Registration.define_with_compilation(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Peer.Ops(~Schema),~Peer.Local<Schema>,~String,~String,~Build.framework_program(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~Peer.Ops(~Schema),~Peer.declaration(~Schema)),~Peer.body(~Schema),~Main.Resources(~Schema),Main.peer_compilation(~Schema),world,"independent-peer",Peer.Local{handle,Body.local(201,202)}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:exit")
def marker_defined(stop:Bool,finalApply:Bool,+handle:W.Handle<Schema>,request:Registry.RequestNode(~Schema),result:Registry.ApplyCompilation(~Schema) & Sys.Defined<World(),Registry.ApplyOwner(~Schema),Body.Local()>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,marker}):exit_defined(stop,finalApply,handle,request,Held.pack(Registry.ApplyCompilation(~Schema),Registry.ApplyOwner(~Schema),compilation,marker),Author.define_with_compilation(~Schema,~D.component_layout(~Schema),~D.root_layout(Schema),~Unit,~Exit.route(),~Exit.Ops(~Schema),~Exit.User<Schema>,~String,~String,~Exit.declaration(~Schema),~Exit.body(~Schema),~{==},Registry.exit_compilation(~Schema),world,"exit",Exit.User{handle,Body.local(301,302)}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:marker")
def request_defined(stop:Bool,finalApply:Bool,+handle:W.Handle<Schema>,result:Registry.RequestCompilation(~Schema) & Sys.Defined<World(),Registry.RequestOwner(~Schema),Body.Local()>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,request}):marker_defined(stop,finalApply,handle,Held.pack(Registry.RequestCompilation(~Schema),Registry.RequestOwner(~Schema),compilation,request),Registration.define_with_compilation(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~D.apply_ops(~Schema),~Body.Local(),~String,~String,~Build.framework_program(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~D.apply_ops(~Schema),~D.apply(~Schema)),~Body.apply(~Schema),~Main.Resources(~Schema),Registry.apply_compilation(~Schema),world,"transition-marker",Body.local(101,102)))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:request")
def allocated(stop:Bool,finalApply:Bool,result:Allocation.Allocation<Schema>) -> IO(String):
  match result:
    case Allocation.AllocationReady{world,+handle}:request_defined(stop,finalApply,handle,Registration.define_with_compilation(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~D.request_ops(~Schema),~Body.Local(),~String,~String,~Build.framework_program(~Schema,~D.Store(~Schema),~D.Store(~Schema),~Main.Resources(~Schema),~D.request_ops(~Schema),~D.request(~Schema)),~Body.request(~Schema),~Main.Resources(~Schema),Registry.request_compilation(~Schema),world,"request",Body.local(401,402)))
    case Allocation.Refused{_,_}:IO.pure(String,"ERROR:allocation")
def created(stop:Bool,finalApply:Bool,result:W.Creation<Schema,D.Store(~Schema),Main.Resources(~Schema),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:allocated(stop,finalApply,Allocation.allocate(~Schema,Init.setup(~Schema,world)))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:create")
def run(stop:Bool,finalApply:Bool) -> IO(String):
  created(stop,finalApply,W.create(~Schema,~D.Store(~Schema),~Main.Resources(~Schema),~Unit,~Main.empty(~Schema),W.factory(),Main.resources(~Schema)))
def main() -> IO(Unit):IO.bind(String,Unit,run(False{},False{}),first => IO.bind(String,Unit,run(True{},True{}),second => IO.print("final-off{" ++ first ++ "}\nstop{" ++ second ++ "}")))
