import Base
import ./actor.bend as Actor
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-effects.bend as Effects
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick

def Columns(~S:Data) -> Type:Actor.C(~S)
def Resources(~S:Data) -> Type:Actor.R(~S)
def World(~S:Data) -> Type:W.World<S,Columns(~S),Resources(~S),Unit>
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def peer_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Unit:(book,Unit{})
def peer_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,local:Unit) -> F(H & (Unit & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (Unit & Sys.Completion<String,String>)),effects,(scope,(local,Sys.Success{"peer finished"})))
def kernel(~S:Data,~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Columns(~S),~Columns(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):Build.framework_program(~S,~Columns(~S),~Columns(~S),~Resources(~S),~Ops,~peer_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def Peer(~S:Data) -> Type:Sys.Owner<S,Columns(~S),Columns(~S),Resources(~S),Unit,Ops,Unit,String,String,kernel(~S),peer_body(~S)>
def PeerCompilation(~S:Data) -> Type:D.Compilation<S,Columns(~S),Columns(~S),Resources(~S),Ops>
def peer_compilation(~S:Data) -> PeerCompilation(~S):Program.compile_framework(~S,~Columns(~S),~Columns(~S),~Resources(~S),~Ops,~kernel(~S))
def PeerNode(~S:Data) -> Type:Retained.CompiledBinding<PeerCompilation(~S),Peer(~S)>
def Nodes(~S:Data) -> Type:Reg.Product<Actor.Node(~S),PeerNode(~S)>
def actor_dispatch(~S:Data) -> Actor.Node(~S) -> World(~S) -> U32 -> Actor.Node(~S) & (World(~S) & Exec.Invocation<String,String>):Author.dispatch(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~Actor.compilation(~S))
def peer_dispatch(~S:Data) -> PeerNode(~S) -> World(~S) -> U32 -> PeerNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Ops,~Unit,~String,~String,~kernel(~S),~peer_body(~S),~peer_compilation(~S))
def dispatch(~S:Data) -> Nodes(~S) -> World(~S) -> U32 -> Nodes(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~Actor.Node(~S),~PeerNode(~S),~String,~String,~actor_dispatch(~S),~peer_dispatch(~S))
def actor_pending(~S:Data) -> List<&2,U32> -> World(~S) -> Actor.Node(~S) -> World(~S) & (Actor.Node(~S) & Bool):Author.pending(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S))
def actor_publish(~S:Data) -> List<&2,U32> -> Tick.Tick -> World(~S) -> Actor.Node(~S) -> World(~S) & Actor.Node(~S):Author.publish(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~{==},~Cmd.checked_relations(~S,~Actor.resources(~S),Cmd.compiled_permission(~S,~Columns(~S),~Resources(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S),Actor.compilation(~S))),~Cmd.construction_selection(~S,~Columns(~S),~Resources(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S),Actor.compilation(~S)))
def actor_collect(~S:Data) -> List<&2,U32> -> Actor.Node(~S) -> Actor.Node(~S) & List<&2,U32>:Author.collect(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S))
def pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & Bool):Retention.pending_pair(~World(~S),~Actor.Node(~S),~PeerNode(~S),~actor_pending(~S),~Retention.pending_none(~World(~S),~PeerNode(~S)),ids,world,nodes)
def publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Nodes(~S)) -> World(~S) & Nodes(~S):Retention.publish_pair(~World(~S),~Actor.Node(~S),~PeerNode(~S),~actor_publish(~S),~Retention.publish_none(~World(~S),~PeerNode(~S)),ids,tick,world,nodes)
def collect(~S:Data,ids:List<&2,U32>,nodes:Nodes(~S)) -> Nodes(~S) & List<&2,U32>:Retention.collect_pair(~Actor.Node(~S),~PeerNode(~S),~actor_collect(~S),~Retention.collect_none(~PeerNode(~S)),ids,nodes)
def apply(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):Publication.apply(~S,~Columns(~S),~Resources(~S),~Unit,~Nodes(~S),~pending(~S),~publish(~S),~collect(~S),ids,world,nodes)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def Application(~S:Data) -> Type:Schedule.Scheduled<App.State<World(~S),Nodes(~S),Unit,Unit>>
def Bound(~S:Data) -> Type:Context.Bound<S,Resources(~S),Actor.resources(~S),{==},Application(~S)>
def actor_facts(~S:Data,node:Actor.Node(~S)) -> Registry.Facts<Reg.Registry<World(~S),Actor.Node(~S),String,String,actor_dispatch(~S)>>:Registry.command(~World(~S),~Actor.Node(~S),~String,~String,~actor_dispatch(~S),Author.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~Actor.compilation(~S),node))
def peer_facts(~S:Data,node:PeerNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),PeerNode(~S),String,String,peer_dispatch(~S)>>:Registry.ordinary(~World(~S),~PeerNode(~S),~String,~String,~peer_dispatch(~S),Leaf.facts(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Ops,~Unit,~String,~String,~kernel(~S),~peer_body(~S),~peer_compilation(~S),node))
def build(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),actor:Actor.Node(~S),peer:PeerNode(~S)) -> Bound(~S):
  Context.Bound{context,Root.build(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Nodes(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~World(~S),~String,~Bool),~available,world,Registry.paired(~World(~S),~Actor.Node(~S),~PeerNode(~S),~String,~String,~actor_dispatch(~S),~peer_dispatch(~S),actor_facts(~S,actor),peer_facts(~S,peer)),Reg.empty_conditions(~World(~S),~String),Unit{},[],[])}
def run_once(~S:Data,bound:Bound(~S)) -> Bound(~S) & Context.RunReport<App.Report<String,String>>:
  Root.run_bound(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Nodes(~S),~Unit,~Unit,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~World(~S),~String,~Bool),~handle,~apply(~S),bound)
type Definition<-S:Data> is Type:
  SceneReady{application:Bound(~S)}
  ActorRefused{context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),local:Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)}
  PeerRefused{context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),actor:Actor.Node(~S),local:Unit}
def peer_defined(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,actor:Actor.Node(~S),result:PeerCompilation(~S) & Sys.Defined<World(~S),Peer(~S),Unit>) -> Definition<S>:
  match result:
    case (compilation,Sys.Defined{world,peer}):SceneReady{build(~S,context,world,actor,Retained.pack(PeerCompilation(~S),Peer(~S),compilation,peer))}
    case (_,Sys.DefinitionRefused{world,local}):PeerRefused{context,world,actor,local}
def actor_defined(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,result:Author.Compilation(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S)) & Sys.Defined<World(~S),Actor.Owner(~S),Cmd.Captures(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.User<S>)>) -> Definition<S>:
  match result:
    case (compilation,Sys.Defined{world,actor}):peer_defined(~S,context,Retained.pack(Author.Compilation(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Actor.Ops(~S)),Actor.Owner(~S),compilation,actor),Leaf.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Ops,~Unit,~String,~String,~kernel(~S),~peer_body(~S),peer_compilation(~S),world,"scene-peer",Unit{}))
    case (_,Sys.DefinitionRefused{world,local}):ActorRefused{context,world,local}
def define(~S:Data,context:Context.Context<S,Resources(~S),Actor.resources(~S),{==}>,world:World(~S),user:Actor.User<S>) -> Definition<S>:
  actor_defined(~S,context,Author.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Actor.Ops(~S),~Actor.User<S>,~String,~String,~Actor.declaration(~S),~Actor.body(~S),~{==},Actor.compilation(~S),world,"scene-hierarchy",user))
