import Base
import ./declarations.bend as O
import ./receiver.bend as R
import ./execution.bend as E
import ../../src/ecs/execution-effects.bend as Effects
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-generalized-command-leaf.bend as Leaf
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W

type Capture<-S:Data> is Type:Capture{handle:W.Handle<S>,retained:E.Left(~S),capture:Array<U32>,runs:U32}
# Authored commands remain owned when deferred application is disabled.
def route() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Ops(Permit:Data,F:Type -> Type,H:Type,Q:Type) -> Type:Unit
def declaration(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,O.Actor<S>>,~B:Type,~builder:Build.Builder(~S,~E.Columns(~S),~E.Columns(~S),~R.Resources(~S),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~S,~R.Components(~S),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~S,~Plan.layout(O.resources(~S)),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Plan.layout(O.resources(~S)),~Q,~K),book:B,permission:K) -> B & (K & Unit):(book,(permission,Unit{}))
def body(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Unit,~commands:Local.Commands<Q,S,O.Actor<S>>,scope:H,queue:Q,local:Capture<S>) -> F(H & (Q & (Capture<S> & Sys.Completion<String,String>))):
  match local:
    case Capture{+handle,retained,capture,runs}:Effects.pure(~F,(H & (Q & (Capture<S> & Sys.Completion<String,String>))),effects,(scope,(Local.insert_field(~Q,~S,~O.Actor<S>,commands)(queue,handle,O.Actor{"queued",ALeaf{515}}),(Capture{handle,retained,capture,U32.add(runs,1)},Sys.Success{"authored"}))))
def Compilation(~S:Data) -> Type:Leaf.Compilation(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Ops)
def compilation(~S:Data) -> Compilation(~S):
  Build.compile_framework(~S,~E.Columns(~S),~E.Columns(~S),~R.Resources(~S),~Cmd.ScopedOps(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Ops),~Cmd.program_for_buffer(~S,~E.Columns(~S),~R.Resources(~S),~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Ops,~declaration(~S)))
def Owner(~S:Data) -> Type:Leaf.Owner(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S))
def Node(~S:Data) -> Type:Leaf.Node(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S))
def dispatch(~S:Data) -> Node(~S) -> R.World(~S) -> U32 -> Node(~S) & (R.World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S),~compilation(~S))
def facts(~S:Data,node:Node(~S)) -> Registry.Facts<Reg.Registry<R.World(~S),Node(~S),String,String,dispatch(~S)>>:Registry.command(~R.World(~S),~Node(~S),~String,~String,~dispatch(~S),Leaf.facts(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S),~compilation(~S),node))
def pending(~S:Data) -> List<&2,U32> -> R.World(~S) -> Node(~S) -> R.World(~S) & (Node(~S) & Bool):Leaf.pending(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S))
def publish(~S:Data) -> List<&2,U32> -> Tick.Tick -> R.World(~S) -> Node(~S) -> R.World(~S) & Node(~S):Leaf.publish(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S),~{==},~Cmd.checked_relations(~S,~Plan.layout(O.resources(~S)),Cmd.compiled_permission(~S,~E.Columns(~S),~R.Resources(~S),~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Ops,compilation(~S))),~Cmd.construction_selection(~S,~E.Columns(~S),~R.Resources(~S),~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Ops,compilation(~S)))
def collect(~S:Data) -> List<&2,U32> -> Node(~S) -> Node(~S) & List<&2,U32>:Leaf.collect(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S))
def define(~S:Data,world:R.World(~S),handle:W.Handle<S>,retained:E.Left(~S)) -> Leaf.Compilation(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Ops) & Sys.Defined<R.World(~S),Owner(~S),Cmd.Captures(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~route(),~Capture<S>)>:
  Leaf.define_with_compilation(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~route(),~Ops,~Capture<S>,~String,~String,~declaration(~S),~body(~S),~{==},compilation(~S),world,"pending-actor",Capture{handle,retained,ALeaf{404},0})
