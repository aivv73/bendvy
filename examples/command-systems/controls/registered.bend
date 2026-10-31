import Base
import ../../../src/ecs/execution-effects.bend as Effects
import ../../../src/ecs/execution-command-permission.bend as Permission
import ../../../src/ecs/execution-command-removed.bend as Removed
import ./positive.bend as P
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-command-system.bend as Cmd
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../../../src/ecs/execution-generalized-command-leaf.bend as Leaf
import ../../../src/ecs/execution-registry.bend as Registry
import ../../../src/ecs/dependency-registration.bend as Reg
import ../../../src/ecs/dependency-executor.bend as Exec
import ../../../src/ecs/execution-state.bend as State
import ../../../src/ecs/execution-command-local.bend as Local

def observed(result:Array<U32> & U32) -> P.Token & U32:
  match result:
    case (owner,value):(P.Token{owner},value)
def refresh(owner:P.Token) -> P.Token & U32:
  match owner:
    case P.Token{owner}:observed(Array.get(U32,owner,0))
def layout() -> Layout.Layout:Layout.LayoutLeaf{P.Token,U32,refresh,"token",Policy.Ordinary{}}
def Ops(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Unit
def declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,P.Token>,~B:Type,~builder:Build.Builder(~S,~(Layout.columns(~S,layout())),~(Layout.columns(~S,layout())),~Unit,~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~S,~layout(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~S,~Layout.EmptyLayout{},~Q,~K),~scopes:Permission.ScopeGrant(~S,~Layout.EmptyLayout{},~Q,~K),book:B,permission:K) -> B & (K & Unit):
  (book,(permission,Unit{}))
def Owner(~S:Data) -> Type:
  Cmd.Owner<S,Layout.columns(~S,layout()),Unit,Unit,layout(),Layout.EmptyLayout{},Layout.AtLeaf{},Ops,P.Capture<S>,String,Unit,declaration(~S),P.body(~S)>
def Node(~S:Data) -> Type:Leaf.Node(~S,~layout(),~Layout.EmptyLayout{},~Unit,~Layout.AtLeaf{},~Ops,~P.Capture<S>,~String,~Unit,~declaration(~S),~P.body(~S))
def compilation(~S:Data) -> Leaf.Compilation(~S,~layout(),~Layout.EmptyLayout{},~Layout.AtLeaf{},~Ops):
  Build.compile_framework(~S,~(Layout.columns(~S,layout())),~(Layout.columns(~S,layout())),~Unit,~Cmd.ScopedOps(~S,~layout(),~Layout.EmptyLayout{},~Layout.AtLeaf{},~Ops),~Cmd.program_for_buffer(~S,~(Layout.columns(~S,layout())),~Unit,~layout(),~Layout.EmptyLayout{},~Layout.AtLeaf{},~Ops,~declaration(~S)))
def dispatch(~S:Data) -> Node(~S) -> W.World<S,Layout.columns(~S,layout()),Unit,Unit> -> U32 -> Node(~S) & (W.World<S,Layout.columns(~S,layout()),Unit,Unit> & Exec.Invocation<String,Unit>):
  Leaf.dispatch(~S,~layout(),~Layout.EmptyLayout{},~Unit,~Layout.AtLeaf{},~Ops,~P.Capture<S>,~String,~Unit,~declaration(~S),~P.body(~S),~compilation(~S))
def registered(~S:Data,node:Node(~S)) -> Registry.Facts<Reg.Registry<W.World<S,Layout.columns(~S,layout()),Unit,Unit>,Node(~S),String,Unit,dispatch(~S)>>:
  Registry.command(~W.World<S,Layout.columns(~S,layout()),Unit,Unit>,~Node(~S),~String,~Unit,~dispatch(~S),Leaf.facts(~S,~layout(),~Layout.EmptyLayout{},~Unit,~Layout.AtLeaf{},~Ops,~P.Capture<S>,~String,~Unit,~declaration(~S),~P.body(~S),~compilation(~S),node))
