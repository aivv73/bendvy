import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-generalized-command-leaf.bend as Leaf

def R(~S:Data) -> Type:Actor.R(~S)
def Ops(~S:Data,Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,S,Actor.components(),Permit,F>
def declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,S,Actor.Session>,~B:Type,~builder:Build.Builder(~S,~Layout.columns(~S,Actor.components()),~Actor.C(~S),~R(~S),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~S,~Actor.components(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~S,~Actor.resources(~S),~Q,~K),~scopes:Permission.ScopeGrant(~S,~Actor.resources(~S),~Q,~K),book:B,permissions:K) -> B & (K & Ops(~S,Permit,F,H,Q)):
  (book,Permission.entity(~S,~Actor.components(),~Permit,~F,~Q,~K,~entity,permissions))
def queued(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~despawn:Q -> W.Handle<S> -> Q,scope:H,queue:Q,handle:W.Handle<S>) -> H & (Q & (W.Handle<S> & Sys.Completion<String,String>)):
  match handle:
    case +handle:(scope,(despawn(despawn(queue,handle),handle),(handle,Sys.BodyError{"despawn-only author error","schema cleanup queued"})))
def body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(~S,Permit,F,H,Q),~commands:Local.Commands<Q,S,Actor.Session>,scope:H,queue:Q,handle:W.Handle<S>) -> F(H & (Q & (W.Handle<S> & Sys.Completion<String,String>))):
  Effects.pure(~F,(H & (Q & (W.Handle<S> & Sys.Completion<String,String>))),effects,queued(~S,~Permit,~F,~H,~Q,~Permission.despawn_field(~Q,~S,~Actor.components(),~Permit,~F,caps),scope,queue,handle))
def Owner(~S:Data) -> Type:Cmd.Owner<S,Actor.C(~S),R(~S),Unit,Actor.components(),Actor.resources(~S),Actor.route(),Ops(~S),W.Handle<S>,String,String,declaration(~S),body(~S)>

def compilation(~S:Data) -> Decl.Compilation<S,Actor.C(~S),Actor.C(~S),R(~S),Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops(~S))>:
  Program.compile_framework(~S,~Actor.C(~S),~Actor.C(~S),~R(~S),~Cmd.ScopedOps(~S,~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops(~S)),~Cmd.program_for_buffer(~S,~Actor.C(~S),~R(~S),~Actor.components(),~Actor.resources(~S),~Actor.route(),~Ops(~S),~declaration(~S)))
def Node(~S:Data) -> Type:Leaf.Node(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Actor.route(),~Ops(~S),~W.Handle<S>,~String,~String,~declaration(~S),~body(~S))
