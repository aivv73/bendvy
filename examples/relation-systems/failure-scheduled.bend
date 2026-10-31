import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./scheduled.bend as Existing
import ./failure-reader.bend as Reader
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-command-retention.bend as Commands
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-failure-retention.bend as Retention
import ../../src/ecs/execution-lifecycle-maintenance.bend as Lifecycle
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick

def Owners(~S:Data) -> Type:Reg.Product<Existing.Nodes(~S),Reader.Node(~S)>
def State(~S:Data) -> Type:App.State<Existing.World(~S),Owners(~S),Unit,Unit>
def Application(~S:Data) -> Type:Schedule.Scheduled<State(~S)>
def Bound(~S:Data) -> Type:Context.Bound<S,Existing.Resources(~S),Actor.resources(~S),{==},Application(~S)>
def reader_dispatch(~S:Data) -> Reader.Node(~S) -> Existing.World(~S) -> U32 -> Reader.Node(~S) & (Existing.World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Reader.Ops(~S),~Reader.State(~S),~String,~String,~Reader.kernel(~S),~Reader.body(~S),~Reader.compilation(~S))
def dispatch(~S:Data) -> Owners(~S) -> Existing.World(~S) -> U32 -> Owners(~S) & (Existing.World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~Existing.World(~S),~Existing.Nodes(~S),~Reader.Node(~S),~String,~String,~Existing.dispatch(~S),~reader_dispatch(~S))
def pending(~S:Data,ids:List<&2,U32>,world:Existing.World(~S),nodes:Owners(~S)) -> Existing.World(~S) & (Owners(~S) & Bool):Commands.pending_pair(~Existing.World(~S),~Existing.Nodes(~S),~Reader.Node(~S),~Existing.pending(~S),~Commands.pending_none(~Existing.World(~S),~Reader.Node(~S)),ids,world,nodes)
def publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:Existing.World(~S),nodes:Owners(~S)) -> Existing.World(~S) & Owners(~S):Commands.publish_pair(~Existing.World(~S),~Existing.Nodes(~S),~Reader.Node(~S),~Existing.publish(~S),~Commands.publish_none(~Existing.World(~S),~Reader.Node(~S)),ids,tick,world,nodes)
def collect(~S:Data,ids:List<&2,U32>,nodes:Owners(~S)) -> Owners(~S) & List<&2,U32>:Commands.collect_pair(~Existing.Nodes(~S),~Reader.Node(~S),~Existing.collect(~S),~Commands.collect_none(~Reader.Node(~S)),ids,nodes)
def apply(~S:Data,ids:List<&2,U32>,world:Existing.World(~S),nodes:Owners(~S)) -> Existing.World(~S) & (Owners(~S) & List<&2,U32>):Publication.apply(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Owners(~S),~pending(~S),~publish(~S),~collect(~S),ids,world,nodes)
def catalogue(~S:Data) -> Retention.Catalogue<S,Actor.resources(~S)>:
  Retention.add(~S,~Actor.resources(~S),~Actor.route(),~{==},~Scene.hierarchy(~S),~{==},~{==},~{==},Retention.none(~S,~Actor.resources(~S)))
def completed(~S:Data,program:Retention.Program(~S,~Actor.resources(~S)),result:Exec.ExecutionResult<State(~S),String,String,String>) -> Exec.ExecutionResult<State(~S),String,String,String>:
  Retention.completed(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Actor.resources(~S),~{==},~Owners(~S),~Unit,~Unit,~String,~String,program,Lifecycle.completed(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Owners(~S),~Unit,~Unit,~String,~String,result))
def run_application(~S:Data,program:Retention.Program(~S,~Actor.resources(~S)),application:Application(~S)) -> Application(~S) & App.Report<String,String>:
  Root.run_with_completion(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Owners(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~Existing.World(~S),~String,~Bool),~Existing.handle,~apply(~S),result => completed(~S,program,result),application)
type Run<-S:Data> is Type:
  Returned{bound:Bound(~S),report:Context.RunReport<App.Report<String,String>>}
  CatalogueRefused{bound:Bound(~S),catalogue:Retention.Catalogue<S,Actor.resources(~S)>}
def bound_result(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,result:Application(~S) & App.Report<String,String>) -> Run<S>:
  match result:
    case (application,report):Returned{Context.Bound{context,application},Context.RunReported{report}}
def admitted(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,application:Application(~S),admission:Retention.Admission<S,Actor.resources(~S)>) -> Run<S>:
  match admission:
    case Retention.Refused{catalogue}:CatalogueRefused{Context.Bound{context,application},catalogue}
    case Retention.Accepted{program}:bound_result(~S,context,run_application(~S,program,application))
def checked(~S:Data,allowed:Bool,bound:Bound(~S)) -> Run<S>:
  match allowed bound:
    case False{} bound:Returned{bound,Context.ContextRefused{}}
    case True{} Context.Bound{context,application}:admitted(~S,context,application,Retention.prepare(~S,~Actor.resources(~S),catalogue(~S)))
def context_returned(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,restore:Existing.World(~S) -> Application(~S),result:Existing.World(~S) & Bool) -> Bound(~S) & Bool:
  match result:
    case (world,allowed):(Context.Bound{context,restore(world)},allowed)
def context_checked(~S:Data,bound:Bound(~S)) -> Bound(~S) & Bool:
  match bound:
    case Context.Bound{+context,Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred}}:context_returned(~S,context,world => Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred},Context.matches(~S,~Existing.Columns(~S),~Existing.Resources(~S),~Unit,~Actor.resources(~S),~{==},context,world))
def run_checked(~S:Data,result:Bound(~S) & Bool) -> Run<S>:
  match result:
    case (bound,allowed):checked(~S,allowed,bound)
def run(~S:Data,bound:Bound(~S)) -> Run<S>:run_checked(~S,context_checked(~S,bound))
def reader_facts(~S:Data,node:Reader.Node(~S)) -> Registry.Facts<Reg.Registry<Existing.World(~S),Reader.Node(~S),String,String,reader_dispatch(~S)>>:Registry.ordinary(~Existing.World(~S),~Reader.Node(~S),~String,~String,~reader_dispatch(~S),Leaf.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Reader.Ops(~S),~Reader.State(~S),~String,~String,~Reader.kernel(~S),~Reader.body(~S),~Reader.compilation(~S),node))
def build(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,world:Existing.World(~S),actor:Actor.Node(~S),reader:Reader.Node(~S),peer:Existing.PeerNode(~S)) -> Bound(~S):
  Context.Bound{context,Root.build(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Owners(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~Existing.World(~S),~String,~Bool),~Existing.available,world,Registry.paired(~Existing.World(~S),~Existing.Nodes(~S),~Reader.Node(~S),~String,~String,~Existing.dispatch(~S),~reader_dispatch(~S),Registry.paired(~Existing.World(~S),~Actor.Node(~S),~Existing.PeerNode(~S),~String,~String,~Existing.actor_dispatch(~S),~Existing.peer_dispatch(~S),Existing.actor_facts(~S,actor),Existing.peer_facts(~S,peer)),reader_facts(~S,reader)),Reg.empty_conditions(~Existing.World(~S),~String),Unit{},[],[])}
