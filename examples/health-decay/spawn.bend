import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./schema.bend as D
import ./components.bend as V
import ./system.bend as Decay
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/world.bend as W

def route() -> L.Route:L.InLeft{L.AtLeaf{}}
def Ops(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,D.Schema,D.components(),Permit,F>
type User is Type:
  User{seeds:List<Removed.Removed(D.components())>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>}
def initial() -> User:
  User{[Product.Owner{Some{V.Health{10.0}},Some{V.HealthDecay{0.5}}},Product.Owner{Some{V.Health{20.0}},Some{V.HealthDecay{0.25}}},Product.Owner{Some{V.Health{30.0}},None{}}],[],[]}
def granted(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,-B:Type,-K:Type,book:B,result:K & Ops(Permit,F,H,Q)) -> B & (K & Ops(Permit,F,H,Q)):(book,result)
def declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Health>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~D.Schema,~D.components(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~D.Schema,~D.resources(),~Q,~K),~scopes:Permission.ScopeGrant(~D.Schema,~D.resources(),~Q,~K),book:B,permission:K) -> B & (K & Ops(Permit,F,H,Q)):
  granted(~Permit,~F,~H,~Q,B,K,book,Permission.entity(~D.Schema,~D.components(),~Permit,~F,~Q,~K,~entity,permission))
def admitted(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,next:List<Removed.Removed(D.components())> -> H -> Q -> List<&2,W.Handle<D.Schema>> -> F(H & (Q & (User & Sys.Completion<String,Unit>))),scope:H,remaining:List<Removed.Removed(D.components())>,handles:List<&2,W.Handle<D.Schema>>,result:Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match result:
    case (queue,Buffer.SpawnQueued{handle}):next(remaining,scope,queue,List.append(&2,W.Handle<D.Schema>,handles,[handle]))
    case (queue,Buffer.SpawnRejected{bundle,_}):Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{remaining,handles,[bundle]},Sys.BodyError{"spawn reservation refused",Unit{}}))))
def seeded(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,seeds:List<Removed.Removed(D.components())>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{seeds,handles,[]},Sys.Success{Unit{}}))))
def queue_last(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),seeds:List<Removed.Removed(D.components())>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match seeds:
    case seed <> rest:Effects.bind(~F,(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),(H & (Q & (User & Sys.Completion<String,Unit>))),effects,spawn(queue,seed),result=>admitted(~Permit,~F,~effects,~H,~Q,seeded(~Permit,~F,~effects,~H,~Q),scope,rest,handles,result))
    case []:seeded(~Permit,~F,~effects,~H,~Q,[],scope,queue,handles)
def queue_second(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),seeds:List<Removed.Removed(D.components())>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match seeds:
    case seed <> rest:Effects.bind(~F,(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),(H & (Q & (User & Sys.Completion<String,Unit>))),effects,spawn(queue,seed),result=>admitted(~Permit,~F,~effects,~H,~Q,queue_last(~Permit,~F,~effects,~H,~Q,~spawn),scope,rest,handles,result))
    case []:seeded(~Permit,~F,~effects,~H,~Q,[],scope,queue,handles)
def queue_seeds(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),seeds:List<Removed.Removed(D.components())>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match seeds:
    case []:seeded(~Permit,~F,~effects,~H,~Q,[],scope,queue,handles)
    case seed <> rest:Effects.bind(~F,(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),(H & (Q & (User & Sys.Completion<String,Unit>))),effects,spawn(queue,seed),result=>admitted(~Permit,~F,~effects,~H,~Q,queue_second(~Permit,~F,~effects,~H,~Q,~spawn),scope,rest,handles,result))
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(Permit,F,H,Q),~commands:Local.Commands<Q,D.Schema,V.Health>,scope:H,queue:Q,user:User) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match user:
    case User{seeds,handles,[]}:queue_seeds(~Permit,~F,~effects,~H,~Q,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,~F,caps),seeds,scope,queue,handles)
    case user:Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(user,Sys.BodyError{"spawn bundle retained after refusal",Unit{}}))))
def kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<D.Schema>),~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~F,~H,~B),book:B) -> B & Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops,Permit,F,H):
  Cmd.program_for_buffer(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~route(),~Ops,~declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def compilation() -> Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops)>:
  Program.compile_framework(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops),~kernel)
def Node() -> Type:Author.Node(~D.Schema,~D.components(),~D.resources(),~Unit,~route(),~Ops,~User,~String,~Unit,~declaration,~body)
