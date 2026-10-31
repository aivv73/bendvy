import Base
import ./schema.bend as D
import ./spawn.bend as Spawn
import ./system.bend as Decay
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-schedule.bend as Scheduled
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/dependency-executor.bend as Exec

def handle(local:Unit,_:String) -> Unit & Exec.Handling:(local,Exec.Continue{})
def available(_:String) -> Bool:True{}
def Nodes() -> Type:Reg.Product<Spawn.Node(),Decay.Node()>
def State() -> Type:App.State<D.World(),Nodes(),Unit,Unit>
def Application() -> Type:Scheduled.Scheduled<State()>
def spawn_dispatch() -> Spawn.Node() -> D.World() -> U32 -> Spawn.Node() & (D.World() & Exec.Invocation<String,Unit>):
  Author.dispatch(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~Spawn.compilation())
def spawn_pending() -> List<&2,U32> -> D.World() -> Spawn.Node() -> D.World() & (Spawn.Node() & Bool):
  Author.pending(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body)
def spawn_publish() -> List<&2,U32> -> Tick.Tick -> D.World() -> Spawn.Node() -> D.World() & Spawn.Node():
  Author.publish(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~{==},~Cmd.checked_relations(~D.Schema,~D.resources(),Cmd.compiled_permission(~D.Schema,~D.Columns(),~D.Resources(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,Spawn.compilation())),~Cmd.construction_selection(~D.Schema,~D.Columns(),~D.Resources(),~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops,Spawn.compilation()))
def spawn_collect() -> List<&2,U32> -> Spawn.Node() -> Spawn.Node() & List<&2,U32>:
  Author.collect(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body)
def spawn_facts(node:Spawn.Node()) -> Registry.Facts<Reg.Registry<D.World(),Spawn.Node(),String,Unit,spawn_dispatch()>>:
  Registry.command(~D.World(),~Spawn.Node(),~String,~Unit,~spawn_dispatch(),Author.facts(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~Spawn.compilation(),node))
def decay_dispatch() -> Decay.Node() -> D.World() -> U32 -> Decay.Node() & (D.World() & Exec.Invocation<String,Unit>):
  Leaf.dispatch(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.Ops,~Unit,~String,~Unit,~Decay.kernel,~Decay.body,~Decay.compiled())
def decay_pending() -> List<&2,U32> -> D.World() -> Decay.Node() -> D.World() & (Decay.Node() & Bool):
  Retention.pending_none(~D.World(),~Decay.Node())
def decay_publish() -> List<&2,U32> -> Tick.Tick -> D.World() -> Decay.Node() -> D.World() & Decay.Node():
  Retention.publish_none(~D.World(),~Decay.Node())
def decay_collect() -> List<&2,U32> -> Decay.Node() -> Decay.Node() & List<&2,U32>:
  Retention.collect_none(~Decay.Node())
def decay_facts(node:Decay.Node()) -> Registry.Facts<Reg.Registry<D.World(),Decay.Node(),String,Unit,decay_dispatch()>>:
  Registry.ordinary(~D.World(),~Decay.Node(),~String,~Unit,~decay_dispatch(),Leaf.facts(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.Ops,~Unit,~String,~Unit,~Decay.kernel,~Decay.body,~Decay.compiled(),node))
def dispatch() -> Nodes() -> D.World() -> U32 -> Nodes() & (D.World() & Exec.Invocation<String,Unit>):
  Reg.paired_dispatch(~D.World(),~Spawn.Node(),~Decay.Node(),~String,~Unit,~spawn_dispatch(),~decay_dispatch())
def pending(ids:List<&2,U32>,world:D.World(),nodes:Nodes()) -> D.World() & (Nodes() & Bool):
  Retention.pending_pair(~D.World(),~Spawn.Node(),~Decay.Node(),~spawn_pending(),~decay_pending(),ids,world,nodes)
def publish(ids:List<&2,U32>,tick:Tick.Tick,world:D.World(),nodes:Nodes()) -> D.World() & Nodes():
  Retention.publish_pair(~D.World(),~Spawn.Node(),~Decay.Node(),~spawn_publish(),~decay_publish(),ids,tick,world,nodes)
def collect(ids:List<&2,U32>,nodes:Nodes()) -> Nodes() & List<&2,U32>:
  Retention.collect_pair(~Spawn.Node(),~Decay.Node(),~spawn_collect(),~decay_collect(),ids,nodes)
def apply(ids:List<&2,U32>,world:D.World(),nodes:Nodes()) -> D.World() & (Nodes() & List<&2,U32>):
  Publication.apply(~D.Schema,~D.Columns(),~D.Resources(),~Unit,~Nodes(),~pending,~publish,~collect,ids,world,nodes)
def run(app:Application()) -> Application() & App.Report<String,Unit>:
  Root.run(~D.Schema,~D.components(),~D.resources(),~Unit,~Nodes(),~Unit,~Unit,~String,~Unit,~dispatch(),~Reg.empty_dispatch(~D.World(),~String,~Bool),~handle,~apply,app)
def configure(automatic:Bool,app:Application()) -> Application():Scheduled.configure(~State(),Settings.Settings{automatic,False{},[],[]},app)
def prepare(app:Application()) -> Application():Scheduled.configure(~State(),Settings.Settings{False{},True{},[],[]},app)
def Compilation() -> Type:Author.Compilation(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.Ops)
def Owner() -> Type:Author.Owner(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body)
def Binding() -> Type:Spawn.Node()
def Peer() -> Type:Sys.Owner<D.Schema,D.Columns(),D.Columns(),D.Resources(),Unit,Decay.Ops,Unit,String,Unit,Decay.kernel,Decay.body>
def PeerCompilation() -> Type:Decl.Compilation<D.Schema,D.Columns(),D.Columns(),D.Resources(),Decay.Ops>
def PeerBinding() -> Type:Decay.Node()
def build_unpacked(world:D.World(),left:Compilation() & Owner(),right:PeerCompilation() & Peer()) -> Application():
  match left right:
    case (lc,Cmd.Owner{Sys.Owner{ln,+lid,lname,la,lt,ll}}), (rc,Sys.Owner{rn,+rid,rname,ra,rt,rl}):
      configure(False{},Root.build(~D.Schema,~D.components(),~D.resources(),~Unit,~Nodes(),~Unit,~Unit,~String,~Unit,~dispatch(),~Reg.empty_dispatch(~D.World(),~String,~Bool),~available,world,Registry.paired(~D.World(),~Spawn.Node(),~Decay.Node(),~String,~Unit,~spawn_dispatch(),~decay_dispatch(),spawn_facts(Retained.pack(Compilation(),Owner(),lc,Cmd.Owner{Sys.Owner{ln,lid,lname,la,lt,ll}})),decay_facts(Retained.pack(PeerCompilation(),Peer(),rc,Sys.Owner{rn,rid,rname,ra,rt,rl}))),Reg.empty_conditions(~D.World(),~String),Unit{},[Plan.Edge{lid,rid}],[]))
def build(world:D.World(),left:Binding(),right:PeerBinding()) -> Application():build_unpacked(world,Retained.unpack(Compilation(),Owner(),left),Retained.unpack(PeerCompilation(),Peer(),right))
