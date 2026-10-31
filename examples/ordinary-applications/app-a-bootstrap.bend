import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-events.bend as Events
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-retained-system.bend as Held
import ../../src/ecs/execution-generalized-command-leaf.bend as Command
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as App
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick

def Columns() -> Type:Author.Columns()
def Resources() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
def World() -> Type:W.World<P.AuditWorkshop,Columns(),Resources(),Unit>
def PeerNode() -> Type:Events.Owners()
def AuthorCompilation() -> Type:Command.Compilation(~P.AuditWorkshop,~D.components(),~Author.resources(),~Author.route(),~Author.Ops)
def author_compilation() -> AuthorCompilation():Program.compile_framework(~P.AuditWorkshop,~Columns(),~Columns(),~Resources(),~Cmd.ScopedOps(~P.AuditWorkshop,~D.components(),~Author.resources(),~Author.route(),~Author.Ops),~Cmd.program_for_buffer(~P.AuditWorkshop,~Columns(),~Resources(),~D.components(),~Author.resources(),~Author.route(),~Author.Ops,~Author.declaration))
def AuthorNode() -> Type:Held.CompiledBinding<AuthorCompilation(),Author.Owner()>
def Owners() -> Type:Reg.Product<AuthorNode(),PeerNode()>
def ApplicationState() -> Type:State.State<World(),Owners(),Unit,Unit>
def Application() -> Type:App.Scheduled<ApplicationState()>
def Bound() -> Type:Context.Bound<P.AuditWorkshop,Resources(),Author.resources(),{==},Application()>
def author_dispatch() -> AuthorNode() -> World() -> U32 -> AuthorNode() & (World() & Exec.Invocation<String,String>):Command.dispatch(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Author.route(),~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body,~author_compilation())
def peer_dispatch() -> PeerNode() -> World() -> U32 -> PeerNode() & (World() & Exec.Invocation<String,String>):Events.dispatch()
def dispatch() -> Owners() -> World() -> U32 -> Owners() & (World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(),~AuthorNode(),~PeerNode(),~String,~String,~author_dispatch(),~peer_dispatch())
def facts(author:AuthorNode(),peer:PeerNode()) -> Registry.Facts<Reg.Registry<World(),Owners(),String,String,dispatch()>>:
  Registry.paired(~World(),~AuthorNode(),~PeerNode(),~String,~String,~author_dispatch(),~peer_dispatch(),Registry.command(~World(),~AuthorNode(),~String,~String,~author_dispatch(),Command.facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Author.route(),~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body,~author_compilation(),author)),Events.facts(peer))
def author_pending() -> List<&2,U32> -> World() -> AuthorNode() -> World() & (AuthorNode() & Bool):Command.pending(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Author.route(),~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body)
def author_publish() -> List<&2,U32> -> Tick.Tick -> World() -> AuthorNode() -> World() & AuthorNode():Command.publish(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Author.route(),~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body,~{==},~Cmd.checked_relations(~P.AuditWorkshop,~Author.resources(),Cmd.compiled_permission(~P.AuditWorkshop,~Columns(),~Resources(),~D.components(),~Author.resources(),~Author.route(),~Author.Ops,author_compilation())),~Cmd.construction_selection(~P.AuditWorkshop,~Columns(),~Resources(),~D.components(),~Author.resources(),~Author.route(),~Author.Ops,author_compilation()))
def author_collect() -> List<&2,U32> -> AuthorNode() -> AuthorNode() & List<&2,U32>:Command.collect(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Author.route(),~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body)
def pending(ids:List<&2,U32>,world:World(),owners:Owners()) -> World() & (Owners() & Bool):Retention.pending_pair(~World(),~AuthorNode(),~PeerNode(),~author_pending(),~Retention.pending_none(~World(),~PeerNode()),ids,world,owners)
def publish(ids:List<&2,U32>,tick:Tick.Tick,world:World(),owners:Owners()) -> World() & Owners():Retention.publish_pair(~World(),~AuthorNode(),~PeerNode(),~author_publish(),~Retention.publish_none(~World(),~PeerNode()),ids,tick,world,owners)
def collect(ids:List<&2,U32>,owners:Owners()) -> Owners() & List<&2,U32>:Retention.collect_pair(~AuthorNode(),~PeerNode(),~author_collect(),~Retention.collect_none(~PeerNode()),ids,owners)
def publication(ids:List<&2,U32>,world:World(),owners:Owners()) -> World() & (Owners() & List<&2,U32>):Publication.apply(~P.AuditWorkshop,~Columns(),~Resources(),~Unit,~Owners(),~pending,~publish,~collect,ids,world,owners)
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def build(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),author:AuthorNode(),peer:PeerNode()) -> Bound():
  Context.Bound{context,App.configure(~ApplicationState(),Settings.Settings{False{},False{},[],[]},General.build(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Owners(),~Unit,~Unit,~String,~String,~dispatch(),~Reg.empty_dispatch(~World(),~String,~Bool),~available,world,facts(author,peer),Reg.empty_conditions(~World(),~String),Unit{},[],[]))}
def invoke(bound:Bound()) -> IO(Bound() & Context.RunReport<State.Report<String,String>>):
  IO.pure(Bound() & Context.RunReport<State.Report<String,String>>,General.run_bound(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Owners(),~Unit,~Unit,~String,~String,~dispatch(),~Reg.empty_dispatch(~World(),~String,~Bool),~handle,~publication,bound))
def flushed(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,systems:List<&2,U32>,settings:Settings.Settings,compiled:Settings.Built,order:List<&2,U32>,result:ApplicationState() & List<&2,U32>) -> Bound():
  match result:
    case (state,remaining):Context.Bound{context,App.Scheduled{state,plan,bindings,App.Deferred{systems,settings,remaining,compiled,order}}}
def flush(bound:Bound()) -> Bound():
  match bound:
    case Context.Bound{context,App.Scheduled{state,plan,bindings,App.Deferred{systems,settings,unapplied,compiled,order}}}:flushed(context,plan,bindings,systems,settings,compiled,order,General.apply(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Owners(),~Unit,~Unit,~publication,unapplied,state))
def Peer() -> Type:PeerNode()
type Definition is Type:
  DefinitionReady{application:Bound()}
  AuthorRefused{context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),compilation:AuthorCompilation(),local:Cmd.Captures(~P.AuditWorkshop,~D.components(),~Author.resources(),~Author.route(),~Author.User),reader:Events.Reader()}
  PeerRefused{context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,author:AuthorNode(),result:Events.Definition}
def peer_defined(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,author:AuthorNode(),result:Events.Definition) -> Definition:
  match result:
    case Events.DefinitionReady{world,peer}:DefinitionReady{build(context,world,author,peer)}
    case result:PeerRefused{context,author,result}
def author_defined(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,reader:Events.Reader(),result:AuthorCompilation() & Sys.Defined<World(),Author.Owner(),Cmd.Captures(~P.AuditWorkshop,~D.components(),~Author.resources(),~Author.route(),~Author.User)>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,author}):peer_defined(context,Held.pack(AuthorCompilation(),Author.Owner(),compilation,author),Events.define(world,reader))
    case (compilation,Sys.DefinitionRefused{world,local}):AuthorRefused{context,world,compilation,local,reader}
def define(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),reader:Events.Reader()) -> Definition:
  author_defined(context,reader,Command.define_with_compilation(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Author.route(),~Author.Ops,~Author.User,~String,~String,~Author.declaration,~Author.body,~{==},author_compilation(),world,"AppA explicit commands",Author.Seed{}))
def world_returned(~Out:Type,context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,owners:Owners(),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,deferred:App.Deferred,result:World() & Out) -> Bound() & Out:
  match result:
    case (world,out):(Context.Bound{context,App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred}},out)
def with_world(~Out:Type,operation:World() -> World() & Out,bound:Bound()) -> Bound() & Out:
  match bound:
    case Context.Bound{context,App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred}}:world_returned(~Out,context,owners,guards,handler,stateBindings,plan,bindings,deferred,operation(world))

def events_returned(~Out:Type,context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,world:World(),author:AuthorNode(),ids:List<&2,U32>,guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,deferred:App.Deferred,result:Peer() & Out) -> Bound() & Out:
  match result:
    case (events,out):(Context.Bound{context,App.Scheduled{State.State{world,Reg.Product{author,events,ids},guards,handler,stateBindings},plan,bindings,deferred}},out)
def with_events(~Out:Type,operation:Peer() -> Peer() & Out,bound:Bound()) -> Bound() & Out:
  match bound:
    case Context.Bound{context,App.Scheduled{State.State{world,Reg.Product{author,events,ids},guards,handler,stateBindings},plan,bindings,deferred}}:events_returned(~Out,context,world,author,ids,guards,handler,stateBindings,plan,bindings,deferred,operation(events))

# The gameplay Root receives the actual World; bootstrap registrations stay held.
type Retained is Type:
  Retained{context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,owners:Owners(),guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,deferred:App.Deferred}
def detach(bound:Bound()) -> World() & Retained:
  match bound:
    case Context.Bound{context,App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred}}:(world,Retained{context,owners,guards,handler,stateBindings,plan,bindings,deferred})
def attach(world:World(),retained:Retained) -> Bound():
  match retained:
    case Retained{context,owners,guards,handler,stateBindings,plan,bindings,deferred}:Context.Bound{context,App.Scheduled{State.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred}}
def retained_events(context:Context.Context<P.AuditWorkshop,Resources(),Author.resources(),{==}>,author:AuthorNode(),ids:List<&2,U32>,guards:Unit,handler:Unit,stateBindings:List<&2,State.Binding>,plan:Plan.Build<String>,bindings:List<&2,State.Binding>,deferred:App.Deferred,result:Peer() & String) -> Retained & String:
  match result:
    case (events,text):(Retained{context,Reg.Product{author,events,ids},guards,handler,stateBindings,plan,bindings,deferred},text)
def retained_observed(retained:Retained) -> Retained & String:
  match retained:
    case Retained{context,Reg.Product{author,events,ids},guards,handler,stateBindings,plan,bindings,deferred}:retained_events(context,author,ids,guards,handler,stateBindings,plan,bindings,deferred,Events.observed(events))
