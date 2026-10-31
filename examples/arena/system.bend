import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./schema.bend as D
import ./gameplay.bend as G
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-resource-store.bend as Resources
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-generalized-command-leaf.bend as Author

def C() -> Type:L.columns(~D.Schema,D.components())
def R() -> Type:L.resources(~D.Schema,D.resources())
def route() -> L.Route:L.AtLeaf{}
type Caps<-Permit:Data,-F:Type -> Type,-H:Type,-Queue:Type> is Type:
  Caps{body:Q.GeneralWriter<D.Schema,H,G.Body,G.Body>,commands:Permission.EntityCommands<Queue,D.Schema,D.components(),Permit,F>}
def Ops(Permit:Data,F:(Type -> Type),H:Type,Queue:Type) -> Type:Caps<Permit,F,H,Queue>
type User is Data:User{active:Bool,args:G.Args,rows:List<&2,G.Row>}
def any_body(_:Maybe<&2,G.Body>) -> Bool:True{}
def selected(~Permit:Data,~F:(Type -> Type),~H:Type,~Queue:Type,-B:Type,-K:Type,commands:Permission.EntityCommands<Queue,D.Schema,D.components(),Permit,F>,permission:K,result:B & Q.GeneralWriter<D.Schema,H,G.Body,G.Body>) -> B & (K & Ops(Permit,F,H,Queue)):
  match result:
    case (book,query):(book,(permission,Caps{query,commands}))
def query(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~D.Schema,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~D.Schema,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~D.Schema,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~D.Schema,~C(),~R(),~H,~B),~q:Build.Query(~D.Schema,~D.Columns(),~C(),~R(),~F,~H,~B),~life:Build.Lifecycle(~D.Schema,~D.Columns(),~C(),~R(),~H,~B),book:B) -> B & Q.GeneralWriter<D.Schema,H,G.Body,G.Body>:
  Build.general_query(~D.Schema,~D.Columns(),~C(),~R(),~F,~D.components(),~L.AtLeaf{},~{==},~{==},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any_body,~H,~B,~q,book)
def granted(~Permit:Data,~F:(Type -> Type),~H:Type,~Queue:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~C(),~R(),~Permit,~F,~H,~B),-K:Type,book:B,result:K & Permission.EntityCommands<Queue,D.Schema,D.components(),Permit,F>) -> B & (K & Ops(Permit,F,H,Queue)):
  match result:
    case (permission,commands):selected(~Permit,~F,~H,~Queue,B,K,commands,permission,builder(Permit => F => H => Q.GeneralWriter<D.Schema,H,G.Body,G.Body>,query(~Permit,~F,~H,~B),book))
def declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Queue:Type,~commands:Local.Commands<Queue,D.Schema,G.Body>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~C(),~R(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~D.Schema,~D.components(),~Permit,~F,~Queue,~K),~relations:Permission.RelationGrant(~D.Schema,~D.resources(),~Queue,~K),~scopes:Permission.ScopeGrant(~D.Schema,~D.resources(),~Queue,~K),book:B,permission:K) -> B & (K & Ops(Permit,F,H,Queue)):
  granted(~Permit,~F,~H,~Queue,~B,~builder,K,book,Permission.entity(~D.Schema,~D.components(),~Permit,~F,~Queue,~K,~entity,permission))
def rows(~H:Type,~Queue:Type,~Permit:Data,~F:(Type -> Type),caps:Caps<Permit,F,H,Queue>) -> H -> H & Q.GeneralReport<D.Schema,G.Body>:
  match caps:
    case Caps{Q.GeneralWriter{Q.GeneralReader{read,_},_},_}:read
    case _:scope => (scope,Q.SelectionRefused{})
def modify(~H:Type,~Queue:Type,~Permit:Data,~F:(Type -> Type),caps:Caps<Permit,F,H,Queue>) -> @-Out:Type -> H -> W.Handle<D.Schema> -> (G.Body -> G.Body & Out) -> H & Q.GeneralEdit<G.Body,Out>:
  match caps:
    case Caps{Q.GeneralWriter{_,write},_}:write
    case _:Out => scope => _ => edit => (scope,Q.GeneralUnchanged{edit})
def despawn(~H:Type,~Queue:Type,~Permit:Data,~F:(Type -> Type),caps:Caps<Permit,F,H,Queue>) -> Queue -> W.Handle<D.Schema> -> Queue:
  match caps:
    case Caps{_,commands}:Permission.despawn_field(~Queue,~D.Schema,~D.components(),~Permit,~F,commands)
def updated(row:G.Row) -> G.Body & G.Row:
  match row:
    case G.Row{+body,+hit,+points,+killed,+dead}:(body,G.Row{body,hit,points,killed,dead})
def update(+args:G.Args,body:G.Body) -> G.Body & G.Row:updated(G.update(body,args))
def remove(~Queue:Type,~despawn:Queue -> W.Handle<D.Schema> -> Queue,dead:U32,queue:Queue,handle:W.Handle<D.Schema>) -> Queue:
  match dead:
    case 1:despawn(queue,handle)
    case _:queue
def edited(~Permit:Data,~F:(Type -> Type),~H:Type,~Queue:Type,~despawn:Queue -> W.Handle<D.Schema> -> Queue,next:H -> Queue -> List<&2,G.Row> -> H & (Queue & (User & Sys.Completion<String,Unit>)),args:G.Args,handle:W.Handle<D.Schema>,queue:Queue,rows:List<&2,G.Row>,result:H & Q.GeneralEdit<G.Body,G.Row>) -> H & (Queue & (User & Sys.Completion<String,Unit>)):
  match result:
    case (scope,Q.GeneralEdited{G.Row{+body,+hit,+points,+killed,+dead}}):next(scope,remove(~Queue,~despawn,dead,queue,handle),G.Row{body,hit,points,killed,dead} <> rows)
    case (scope,_):(scope,(queue,(User{True{},args,List.reverse(&2,G.Row,rows)},Sys.BodyError{"Body write refused",Unit{}})))
def update_rows(~Permit:Data,~F:(Type -> Type),~H:Type,~Queue:Type,~write:@-Out:Type -> H -> W.Handle<D.Schema> -> (G.Body -> G.Body & Out) -> H & Q.GeneralEdit<G.Body,Out>,~despawn:Queue -> W.Handle<D.Schema> -> Queue,+args:G.Args,remaining:List<&2,Q.GeneralRow<D.Schema,G.Body>>,scope:H,queue:Queue,rows:List<&2,G.Row>) -> H & (Queue & (User & Sys.Completion<String,Unit>)):
  match remaining:
    case []:(scope,(queue,(User{True{},args,List.reverse(&2,G.Row,rows)},Sys.Success{Unit{}})))
    case Q.GeneralRow{+handle,_} <> rest:edited(~Permit,~F,~H,~Queue,~despawn,scope => queue => rows => update_rows(~Permit,~F,~H,~Queue,~write,~despawn,args,rest,scope,queue,rows),args,handle,queue,rows,write(G.Row,scope,handle,update(args)))
def queried(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Queue:Type,~caps:Ops(Permit,F,H,Queue),+args:G.Args,queue:Queue,result:H & Q.GeneralReport<D.Schema,G.Body>) -> F(H & (Queue & (User & Sys.Completion<String,Unit>))):
  match result:
    case (scope,Q.SelectedRows{values}):Effects.pure(~F,(H & (Queue & (User & Sys.Completion<String,Unit>))),effects,update_rows(~Permit,~F,~H,~Queue,~modify(~H,~Queue,~Permit,~F,caps),~despawn(~H,~Queue,~Permit,~F,caps),args,values,scope,queue,[]))
    case (scope,_):Effects.pure(~F,(H & (Queue & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{True{},args,[]},Sys.BodyError{"Body query refused",Unit{}}))))
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Queue:Type,~caps:Ops(Permit,F,H,Queue),~commands:Local.Commands<Queue,D.Schema,G.Body>,scope:H,queue:Queue,user:User) -> F(H & (Queue & (User & Sys.Completion<String,Unit>))):
  match user:
    case User{False{},args,rows}:Effects.pure(~F,(H & (Queue & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{False{},args,rows},Sys.Success{Unit{}}))))
    case User{True{},args,_}:queried(~Permit,~F,~effects,~H,~Queue,~caps,args,queue,rows(~H,~Queue,~Permit,~F,caps)(scope))
def kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<D.Schema>),~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops,Permit,F,H):Cmd.program_for_buffer(~D.Schema,~C(),~R(),~D.components(),~D.resources(),~route(),~Ops,~declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def compilation() -> Decl.Compilation<D.Schema,D.Columns(),C(),R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops)>:Program.compile_framework(~D.Schema,~D.Columns(),~C(),~R(),~Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops),~kernel)
def Node() -> Type:Author.Node(~D.Schema,~D.components(),~D.resources(),~Unit,~route(),~Ops,~User,~String,~Unit,~declaration,~body)
