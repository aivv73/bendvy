import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-system.bend as Sys

def Receipts() -> Type:List<Buffer.Receipt<P.AuditWorkshop,Array<U32>,Removed.Removed(D.components())>>
def resources() -> L.Layout:D.resources(~Receipts())
def route() -> L.Route:L.InLeft{L.AtLeaf{}}
def C() -> Type:L.columns(~P.AuditWorkshop,D.components())
def R() -> Type:L.resources(~P.AuditWorkshop,resources())
def Columns() -> Type:L.columns(~P.AuditWorkshop,D.components())
def Ops(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,P.AuditWorkshop,D.components(),Permit,F>
type User is Type:
  Seed{}
  Queued{target:W.Handle<P.AuditWorkshop>}
  Refused{bundle:Removed.Removed(D.components()),error:W.WorldError}
def declared(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,-B:Type,-K:Type,book:B,result:K & Ops(Permit,F,H,Q)) -> B & (K & Ops(Permit,F,H,Q)):
  (book,result)
def declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,P.AuditWorkshop,Array<U32>>,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~P.AuditWorkshop,~D.components(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~P.AuditWorkshop,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~P.AuditWorkshop,~resources(),~Q,~K),book:B,permissions:K) -> B & (K & Ops(Permit,F,H,Q)):
  declared(~Permit,~F,~H,~Q,B,K,book,Permission.entity(~P.AuditWorkshop,~D.components(),~Permit,~F,~Q,~K,~entity,permissions))
def bundle() -> Removed.Removed(D.components()):Product.Owner{Some{ANode{ALeaf{7},ALeaf{9}}},Some{11}}
def seeded(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,scope:H,result:Q & Buffer.SpawnAdmission<P.AuditWorkshop,Removed.Removed(D.components())>) -> F(H & (Q & (User & Sys.Completion<String,String>))):
  match result:
    case (queue,Buffer.SpawnQueued{target}):Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,String>))),effects,(scope,(queue,(Queued{target},Sys.Success{"bundle queued"}))))
    case (queue,Buffer.SpawnRejected{bundle,error}):Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,String>))),effects,(scope,(queue,(Refused{bundle,error},Sys.BodyError{"reservation refused","bundle retained"}))))
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(Permit,F,H,Q),~commands:Local.Commands<Q,P.AuditWorkshop,Array<U32>>,scope:H,queue:Q,user:User) -> F(H & (Q & (User & Sys.Completion<String,String>))):
  match user:
    case Seed{}:Effects.bind(~F,(Q & Buffer.SpawnAdmission<P.AuditWorkshop,Removed.Removed(D.components())>),(H & (Q & (User & Sys.Completion<String,String>))),effects,Permission.spawn_field(~Q,~P.AuditWorkshop,~D.components(),~Permit,~F,caps)(queue,bundle()),result => seeded(~Permit,~F,~effects,~H,~Q,scope,result))
    case user:Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,String>))),effects,(scope,(queue,(user,Sys.Success{"bundle already queued"}))))
def Owner() -> Type:Cmd.Owner<P.AuditWorkshop,C(),R(),Unit,D.components(),resources(),route(),Ops,User,String,String,declaration,body>
