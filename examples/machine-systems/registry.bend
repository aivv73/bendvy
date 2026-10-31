import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./actor.bend as Actor
import ./exit.bend as Exit
import ./events.bend as Events
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.FullResources(~S),Unit>

def ApplyOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Unit,D.apply_ops(~S),Body.Local(),String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.apply_ops(~S),~D.apply(~S)),Body.apply(~S)>
def ApplyCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.FullResources(~S),D.apply_ops(~S)>
def apply_compilation(~S:Data) -> ApplyCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.apply_ops(~S),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.apply_ops(~S),~D.apply(~S)))
def ApplyNode(~S:Data) -> Type:Leaf.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.apply_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.apply_ops(~S),~D.apply(~S)),~Body.apply(~S))
def apply_dispatch(~S:Data) -> ApplyNode(~S) -> World(~S) -> U32 -> ApplyNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.apply_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.apply_ops(~S),~D.apply(~S)),~Body.apply(~S),~apply_compilation(~S))
def apply_facts(~S:Data,node:ApplyNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),ApplyNode(~S),String,String,apply_dispatch(~S)>>:Registry.ordinary(~World(~S),~ApplyNode(~S),~String,~String,~apply_dispatch(~S),Leaf.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.apply_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.apply_ops(~S),~D.apply(~S)),~Body.apply(~S),~apply_compilation(~S),node))
def RequestOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Unit,D.request_ops(~S),Body.Local(),String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.request_ops(~S),~D.request(~S)),Body.request(~S)>
def RequestCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.FullResources(~S),D.request_ops(~S)>
def request_compilation(~S:Data) -> RequestCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.request_ops(~S),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.request_ops(~S),~D.request(~S)))
def RequestNode(~S:Data) -> Type:Leaf.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.request_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.request_ops(~S),~D.request(~S)),~Body.request(~S))
def request_dispatch(~S:Data) -> RequestNode(~S) -> World(~S) -> U32 -> RequestNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.request_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.request_ops(~S),~D.request(~S)),~Body.request(~S),~request_compilation(~S))
def request_facts(~S:Data,node:RequestNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),RequestNode(~S),String,String,request_dispatch(~S)>>:Registry.ordinary(~World(~S),~RequestNode(~S),~String,~String,~request_dispatch(~S),Leaf.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.request_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.request_ops(~S),~D.request(~S)),~Body.request(~S),~request_compilation(~S),node))
def ReadOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Unit,D.read_ops(~S),Body.Local(),String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.read_ops(~S),~D.read(~S)),Body.read(~S)>
def ReadCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.FullResources(~S),D.read_ops(~S)>
def read_compilation(~S:Data) -> ReadCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.read_ops(~S),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.read_ops(~S),~D.read(~S)))
def ReadNode(~S:Data) -> Type:Leaf.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.read_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.read_ops(~S),~D.read(~S)),~Body.read(~S))
def read_dispatch(~S:Data) -> ReadNode(~S) -> World(~S) -> U32 -> ReadNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.read_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.read_ops(~S),~D.read(~S)),~Body.read(~S),~read_compilation(~S))
def read_facts(~S:Data,node:ReadNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),ReadNode(~S),String,String,read_dispatch(~S)>>:Registry.ordinary(~World(~S),~ReadNode(~S),~String,~String,~read_dispatch(~S),Leaf.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~D.read_ops(~S),~Body.Local(),~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~D.read_ops(~S),~D.read(~S)),~Body.read(~S),~read_compilation(~S),node))
def ActorOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Unit,Actor.Ops(~S),Actor.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),Actor.body(~S)>
def ActorCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Actor.Ops(~S)>
def actor_compilation(~S:Data) -> ActorCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Actor.Ops(~S),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Actor.Ops(~S),~Actor.declaration(~S)))
def ActorNode(~S:Data) -> Type:Leaf.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),~Actor.body(~S))
def actor_dispatch(~S:Data) -> ActorNode(~S) -> World(~S) -> U32 -> ActorNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),~Actor.body(~S),~actor_compilation(~S))
def actor_facts(~S:Data,node:ActorNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),ActorNode(~S),String,String,actor_dispatch(~S)>>:Registry.ordinary(~World(~S),~ActorNode(~S),~String,~String,~actor_dispatch(~S),Leaf.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Actor.Ops(~S),~Actor.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Actor.Ops(~S),~Actor.declaration(~S)),~Actor.body(~S),~actor_compilation(~S),node))
def EventsOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Unit,Events.Ops(~S),Events.Local<S>,String,String,Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Events.Ops(~S),~Events.declaration(~S)),Events.body(~S)>
def EventsCompilation(~S:Data) -> Type:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.FullResources(~S),Events.Ops(~S)>
def events_compilation(~S:Data) -> EventsCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Events.Ops(~S),~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Events.Ops(~S),~Events.declaration(~S)))
def EventsNode(~S:Data) -> Type:Leaf.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Events.Ops(~S),~Events.declaration(~S)),~Events.body(~S))
def events_dispatch(~S:Data) -> EventsNode(~S) -> World(~S) -> U32 -> EventsNode(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Events.Ops(~S),~Events.declaration(~S)),~Events.body(~S),~events_compilation(~S))
def events_facts(~S:Data,node:EventsNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),EventsNode(~S),String,String,events_dispatch(~S)>>:Registry.ordinary(~World(~S),~EventsNode(~S),~String,~String,~events_dispatch(~S),Leaf.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Events.Ops(~S),~Events.Local<S>,~String,~String,~Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Events.Ops(~S),~Events.declaration(~S)),~Events.body(~S),~events_compilation(~S),node))
def ExitOwner(~S:Data) -> Type:Exit.Owner(~S)
def ExitCompilation(~S:Data) -> Type:Author.Compilation(~S,~D.component_layout(~S),~D.root_layout(S),~Exit.route(),~Exit.Ops(~S))
def exit_compilation(~S:Data) -> ExitCompilation(~S):Program.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.FullResources(~S),~Cmd.ScopedOps(~S,~D.component_layout(~S),~D.root_layout(S),~Exit.route(),~Exit.Ops(~S)),~Cmd.program_for_buffer(~S,~D.Store(~S),~D.FullResources(~S),~D.component_layout(~S),~D.root_layout(S),~Exit.route(),~Exit.Ops(~S),~Exit.declaration(~S)))
def ExitNode(~S:Data) -> Type:Author.Node(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S))
def exit_dispatch(~S:Data) -> ExitNode(~S) -> World(~S) -> U32 -> ExitNode(~S) & (World(~S) & Exec.Invocation<String,String>):Author.dispatch(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S),~exit_compilation(~S))
def exit_facts(~S:Data,node:ExitNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),ExitNode(~S),String,String,exit_dispatch(~S)>>:Registry.command(~World(~S),~ExitNode(~S),~String,~String,~exit_dispatch(~S),Author.facts(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S),~exit_compilation(~S),node))
def exit_pending(~S:Data) -> List<&2,U32> -> World(~S) -> ExitNode(~S) -> World(~S) & (ExitNode(~S) & Bool):Author.pending(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S))
def exit_publish(~S:Data) -> List<&2,U32> -> Tick.Tick -> World(~S) -> ExitNode(~S) -> World(~S) & ExitNode(~S):Author.publish(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S),~{==},~Cmd.checked_relations(~S,~D.root_layout(S),Cmd.compiled_permission(~S,~D.Store(~S),~D.FullResources(~S),~D.component_layout(~S),~D.root_layout(S),~Exit.route(),~Exit.Ops(~S),exit_compilation(~S))),~Cmd.construction_selection(~S,~D.Store(~S),~D.FullResources(~S),~D.component_layout(~S),~D.root_layout(S),~Exit.route(),~Exit.Ops(~S),exit_compilation(~S)))
def exit_collect(~S:Data) -> List<&2,U32> -> ExitNode(~S) -> ExitNode(~S) & List<&2,U32>:Author.collect(~S,~D.component_layout(~S),~D.root_layout(S),~Unit,~Exit.route(),~Exit.Ops(~S),~Exit.User<S>,~String,~String,~Exit.declaration(~S),~Exit.body(~S))
def Readers(~S:Data) -> Type:Reg.Product<ActorNode(~S),EventsNode(~S)>
def readers_dispatch(~S:Data) -> Readers(~S) -> World(~S) -> U32 -> Readers(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~ActorNode(~S),~EventsNode(~S),~String,~String,~actor_dispatch(~S),~events_dispatch(~S))
def readers_facts(~S:Data,nodes:Readers(~S)) -> Registry.Facts<Reg.Registry<World(~S),Readers(~S),String,String,readers_dispatch(~S)>>:
  match nodes:
    case Reg.Product{left,right,_}:Registry.paired(~World(~S),~ActorNode(~S),~EventsNode(~S),~String,~String,~actor_dispatch(~S),~events_dispatch(~S),actor_facts(~S,left),events_facts(~S,right))
def readers_pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Readers(~S)) -> World(~S) & (Readers(~S) & Bool):Retention.pending_pair(~World(~S),~ActorNode(~S),~EventsNode(~S),~Retention.pending_none(~World(~S),~ActorNode(~S)),~Retention.pending_none(~World(~S),~EventsNode(~S)),ids,world,nodes)
def readers_publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Readers(~S)) -> World(~S) & Readers(~S):Retention.publish_pair(~World(~S),~ActorNode(~S),~EventsNode(~S),~Retention.publish_none(~World(~S),~ActorNode(~S)),~Retention.publish_none(~World(~S),~EventsNode(~S)),ids,tick,world,nodes)
def readers_collect(~S:Data,ids:List<&2,U32>,nodes:Readers(~S)) -> Readers(~S) & List<&2,U32>:Retention.collect_pair(~ActorNode(~S),~EventsNode(~S),~Retention.collect_none(~ActorNode(~S)),~Retention.collect_none(~EventsNode(~S)),ids,nodes)
def Tail(~S:Data) -> Type:Reg.Product<RequestNode(~S),Readers(~S)>
def tail_dispatch(~S:Data) -> Tail(~S) -> World(~S) -> U32 -> Tail(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~RequestNode(~S),~Readers(~S),~String,~String,~request_dispatch(~S),~readers_dispatch(~S))
def tail_facts(~S:Data,nodes:Tail(~S)) -> Registry.Facts<Reg.Registry<World(~S),Tail(~S),String,String,tail_dispatch(~S)>>:
  match nodes:
    case Reg.Product{left,right,_}:Registry.paired(~World(~S),~RequestNode(~S),~Readers(~S),~String,~String,~request_dispatch(~S),~readers_dispatch(~S),request_facts(~S,left),readers_facts(~S,right))
def tail_pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Tail(~S)) -> World(~S) & (Tail(~S) & Bool):Retention.pending_pair(~World(~S),~RequestNode(~S),~Readers(~S),~Retention.pending_none(~World(~S),~RequestNode(~S)),~readers_pending(~S),ids,world,nodes)
def tail_publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Tail(~S)) -> World(~S) & Tail(~S):Retention.publish_pair(~World(~S),~RequestNode(~S),~Readers(~S),~Retention.publish_none(~World(~S),~RequestNode(~S)),~readers_publish(~S),ids,tick,world,nodes)
def tail_collect(~S:Data,ids:List<&2,U32>,nodes:Tail(~S)) -> Tail(~S) & List<&2,U32>:Retention.collect_pair(~RequestNode(~S),~Readers(~S),~Retention.collect_none(~RequestNode(~S)),~readers_collect(~S),ids,nodes)
def Phases(~S:Data) -> Type:Reg.Product<ReadNode(~S),Tail(~S)>
def phases_dispatch(~S:Data) -> Phases(~S) -> World(~S) -> U32 -> Phases(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~ReadNode(~S),~Tail(~S),~String,~String,~read_dispatch(~S),~tail_dispatch(~S))
def phases_facts(~S:Data,nodes:Phases(~S)) -> Registry.Facts<Reg.Registry<World(~S),Phases(~S),String,String,phases_dispatch(~S)>>:
  match nodes:
    case Reg.Product{left,right,_}:Registry.paired(~World(~S),~ReadNode(~S),~Tail(~S),~String,~String,~read_dispatch(~S),~tail_dispatch(~S),read_facts(~S,left),tail_facts(~S,right))
def phases_pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Phases(~S)) -> World(~S) & (Phases(~S) & Bool):Retention.pending_pair(~World(~S),~ReadNode(~S),~Tail(~S),~Retention.pending_none(~World(~S),~ReadNode(~S)),~tail_pending(~S),ids,world,nodes)
def phases_publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Phases(~S)) -> World(~S) & Phases(~S):Retention.publish_pair(~World(~S),~ReadNode(~S),~Tail(~S),~Retention.publish_none(~World(~S),~ReadNode(~S)),~tail_publish(~S),ids,tick,world,nodes)
def phases_collect(~S:Data,ids:List<&2,U32>,nodes:Phases(~S)) -> Phases(~S) & List<&2,U32>:Retention.collect_pair(~ReadNode(~S),~Tail(~S),~Retention.collect_none(~ReadNode(~S)),~tail_collect(~S),ids,nodes)
def AfterApply(~S:Data) -> Type:Reg.Product<ExitNode(~S),Phases(~S)>
def afterapply_dispatch(~S:Data) -> AfterApply(~S) -> World(~S) -> U32 -> AfterApply(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~ExitNode(~S),~Phases(~S),~String,~String,~exit_dispatch(~S),~phases_dispatch(~S))
def afterapply_facts(~S:Data,nodes:AfterApply(~S)) -> Registry.Facts<Reg.Registry<World(~S),AfterApply(~S),String,String,afterapply_dispatch(~S)>>:
  match nodes:
    case Reg.Product{left,right,_}:Registry.paired(~World(~S),~ExitNode(~S),~Phases(~S),~String,~String,~exit_dispatch(~S),~phases_dispatch(~S),exit_facts(~S,left),phases_facts(~S,right))
def afterapply_pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:AfterApply(~S)) -> World(~S) & (AfterApply(~S) & Bool):Retention.pending_pair(~World(~S),~ExitNode(~S),~Phases(~S),~exit_pending(~S),~phases_pending(~S),ids,world,nodes)
def afterapply_publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:AfterApply(~S)) -> World(~S) & AfterApply(~S):Retention.publish_pair(~World(~S),~ExitNode(~S),~Phases(~S),~exit_publish(~S),~phases_publish(~S),ids,tick,world,nodes)
def afterapply_collect(~S:Data,ids:List<&2,U32>,nodes:AfterApply(~S)) -> AfterApply(~S) & List<&2,U32>:Retention.collect_pair(~ExitNode(~S),~Phases(~S),~exit_collect(~S),~phases_collect(~S),ids,nodes)
def Owners(~S:Data) -> Type:Reg.Product<ApplyNode(~S),AfterApply(~S)>
def owners_dispatch(~S:Data) -> Owners(~S) -> World(~S) -> U32 -> Owners(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~ApplyNode(~S),~AfterApply(~S),~String,~String,~apply_dispatch(~S),~afterapply_dispatch(~S))
def owners_facts(~S:Data,nodes:Owners(~S)) -> Registry.Facts<Reg.Registry<World(~S),Owners(~S),String,String,owners_dispatch(~S)>>:
  match nodes:
    case Reg.Product{left,right,_}:Registry.paired(~World(~S),~ApplyNode(~S),~AfterApply(~S),~String,~String,~apply_dispatch(~S),~afterapply_dispatch(~S),apply_facts(~S,left),afterapply_facts(~S,right))
def owners_pending(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Owners(~S)) -> World(~S) & (Owners(~S) & Bool):Retention.pending_pair(~World(~S),~ApplyNode(~S),~AfterApply(~S),~Retention.pending_none(~World(~S),~ApplyNode(~S)),~afterapply_pending(~S),ids,world,nodes)
def owners_publish(~S:Data,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Owners(~S)) -> World(~S) & Owners(~S):Retention.publish_pair(~World(~S),~ApplyNode(~S),~AfterApply(~S),~Retention.publish_none(~World(~S),~ApplyNode(~S)),~afterapply_publish(~S),ids,tick,world,nodes)
def owners_collect(~S:Data,ids:List<&2,U32>,nodes:Owners(~S)) -> Owners(~S) & List<&2,U32>:Retention.collect_pair(~ApplyNode(~S),~AfterApply(~S),~Retention.collect_none(~ApplyNode(~S)),~afterapply_collect(~S),ids,nodes)
def pack(~S:Data,apply:ApplyNode(~S),exit:ExitNode(~S),transition:ReadNode(~S),enter:RequestNode(~S),read:ActorNode(~S),events:EventsNode(~S)) -> Owners(~S):Reg.Product{apply,Reg.Product{exit,Reg.Product{transition,Reg.Product{enter,Reg.Product{read,events,[]},[]},[]},[]},[]}
