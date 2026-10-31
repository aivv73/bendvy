import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./schema.bend as D
import ./gameplay.bend as V
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
import ../../src/ecs/execution-state.bend as State
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/chunk-query.bend as Row
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/world.bend as W

def route() -> L.Route:L.AtLeaf{}
type Firing<-Q:Type> is Type:
  Firing{queue:Q,seeds:List<&2,V.Body>,player:Maybe<&2,W.Handle<D.Schema>>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>,visited:Bool}
type Caps<-Permit:Data,-F:Type -> Type,-H:Type,-Q:Type> is Type:
  Caps{rows:Query.SequentialOutputEach<D.Schema,Permit,F,H,Firing<Q>,String>,commands:Permission.EntityCommands<Q,D.Schema,D.components(),Permit,F>}
def Ops(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Caps<Permit,F,H,Q>
type User is Type:
  User{seeds:List<&2,V.Body>,handles:List<&2,W.Handle<D.Schema>>,returned:List<Removed.Removed(D.components())>,player:Maybe<&2,W.Handle<D.Schema>>}
def player_seed(seed:V.Body) -> Bool:
  match seed:
    case V.Body{_,_,kind,_,_,_,_,_,_}:U32.is_eq(kind,0)
def capture_player(player:Maybe<&2,W.Handle<D.Schema>>,handle:W.Handle<D.Schema>,selected:Bool) -> Maybe<&2,W.Handle<D.Schema>>:
  match player selected:
    case None{} True{}:Some{handle}
    case player _:player
def captured_player(player:Maybe<&2,W.Handle<D.Schema>>,seed:V.Body,handle:W.Handle<D.Schema>) -> Maybe<&2,W.Handle<D.Schema>>:
  capture_player(player,handle,player_seed(seed))
def admitted(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,next:H -> Q -> List<&2,W.Handle<D.Schema>> -> Maybe<&2,W.Handle<D.Schema>> -> F(H & (Q & (User & Sys.Completion<String,Unit>))),scope:H,seed:V.Body,remaining:List<&2,V.Body>,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>,result:Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match result:
    case (queue,Buffer.SpawnQueued{+handle}):next(scope,queue,List.append(&2,W.Handle<D.Schema>,handles,[handle]),captured_player(player,seed,handle))
    case (queue,Buffer.SpawnRejected{bundle,_}):Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{remaining,handles,[bundle],player},Sys.BodyError{"spawn reservation refused",Unit{}}))))
def seeded(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,seeds:List<&2,V.Body>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{seeds,handles,[],player},Sys.Success{Unit{}}))))
def queue_seeds(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),seeds:List<&2,V.Body>,scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match seeds:
    case []:seeded(~Permit,~F,~effects,~H,~Q,[],scope,queue,handles,player)
    case +seed <> +rest:Effects.bind(~F,(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),(H & (Q & (User & Sys.Completion<String,Unit>))),effects,spawn(queue,Some{seed}),result => admitted(~Permit,~F,~effects,~H,~Q,scope => queue => handles => player => queue_seeds(~Permit,~F,~effects,~H,~Q,~spawn,rest,scope,queue,handles,player),scope,seed,rest,handles,player,result))
def row_completed(~Q:Type,body:V.Body,prior:List<Removed.Removed(D.components())>,result:Unit & (Q & (User & Sys.Completion<String,Unit>))) -> V.Body & (Firing<Q> & Maybe<&2,String>):
  match result:
    case (_,(queue,(User{seeds,handles,returned,player},Sys.Success{_}))):(body,(Firing{queue,seeds,player,handles,List.append(&1,Removed.Removed(D.components()),prior,returned),True{}},None{}))
    case (_,(queue,(User{seeds,handles,returned,player},Sys.BodyError{error,_}))):(body,(Firing{queue,seeds,player,handles,List.append(&1,Removed.Removed(D.components()),prior,returned),True{}},Some{error}))
def row_selected(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),body:V.Body,output:Firing<Q>,selected:Bool) -> F(V.Body & (Firing<Q> & Maybe<&2,String>)):
  match output selected:
    case Firing{queue,seeds,player,handles,returned,False{}} True{}:Effects.map(~F,(Unit & (Q & (User & Sys.Completion<String,Unit>))),(V.Body & (Firing<Q> & Maybe<&2,String>)),effects,queue_seeds(~Permit,~F,~effects,~Unit,~Q,~spawn,seeds,Unit{},queue,handles,player),result => row_completed(~Q,body,returned,result))
    case output _:Effects.pure(~F,(V.Body & (Firing<Q> & Maybe<&2,String>)),effects,(body,(output,None{})))
def row_target(handle:W.Handle<D.Schema>,player:Maybe<&2,W.Handle<D.Schema>>) -> Bool:
  match player:
    case None{}:False{}
    case Some{target}:State.same(~D.Schema,handle,target)
def row(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~Q:Type,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),handle:W.Handle<D.Schema>,_:V.Body,body:V.Body,output:Firing<Q>) -> F(V.Body & (Firing<Q> & Maybe<&2,String>)):
  match output:
    case Firing{queue,seeds,+player,handles,returned,visited}:row_selected(~Permit,~F,~effects,~Q,~spawn,body,Firing{queue,seeds,player,handles,returned,visited},row_target(handle,player))
def any_body(_:Maybe<&2,V.Body>) -> Bool:True{}
def query(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~spawn:Q -> Removed.Removed(D.components()) -> F(Q & Buffer.SpawnAdmission<D.Schema,Removed.Removed(D.components())>),~B:Type,~cr:Build.ComponentRead(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~cw:Build.ComponentWrite(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~rr:Build.ResourceRead(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~rw:Build.ResourceWrite(~D.Schema,~Decay.C(),~Decay.R(),~H,~B),~q:Build.Query(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~F,~H,~B),~life:Build.Lifecycle(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~H,~B),book:B) -> B & Query.SequentialOutputEach<D.Schema,Permit,F,H,Firing<Q>,String>:
  Build.sequential_general_query(~D.Schema,~Permit,~D.Columns(),~Decay.C(),~Decay.R(),~F,~D.components(),~route(),~{==},~{==},~{==},~Recipe.AllLive{},~Match.Required{},~any_body,~Firing<Q>,~String,~row(~Permit,~F,~effects,~Q,~spawn),~Query.AllRows{},~H,~B,~q,book)
def selected_caps(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~B:Type,structural:Permission.EntityCommands<Q,D.Schema,D.components(),Permit,F>,result:B & Query.SequentialOutputEach<D.Schema,Permit,F,H,Firing<Q>,String>) -> B & Ops(Permit,F,H,Q):
  match result:
    case (book,rows):(book,Caps{rows,structural})
def entity_selection(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~F,~H,~B),~structural:Permission.EntityCommands<Q,D.Schema,D.components(),Permit,F>) -> B -> B & Ops(Permit,F,H,Q):
  book=>selected_caps(~Permit,~F,~H,~Q,~B,structural,builder(Permit=>F=>H=>Query.SequentialOutputEach<D.Schema,Permit,F,H,Firing<Q>,String>,query(~Permit,~F,~effects,~H,~Q,~commands,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,~F,structural),~B),book))
def declared(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~B:Type,~K:Type,permission:K,result:B & Ops(Permit,F,H,Q)) -> B & (K & Ops(Permit,F,H,Q)):
  match result:
    case (book,ops):(book,(permission,ops))
def granted(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & (B -> B & Ops(Permit,F,H,Q))) -> B & (K & Ops(Permit,F,H,Q)):
  match result:
    case (permission,selection):declared(~Permit,~F,~H,~Q,~B,~K,permission,selection(book))
def declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,D.Schema,V.Body>,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~D.Schema,~D.components(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~D.Schema,~D.resources(),~Q,~K),~scopes:Permission.ScopeGrant(~D.Schema,~D.resources(),~Q,~K),book:B,permission:K) -> B & (K & Ops(Permit,F,H,Q)):
  granted(~Permit,~F,~H,~Q,~B,~K,book,entity(B -> B & Ops(Permit,F,H,Q),entity_selection(~Permit,~F,~effects,~H,~Q,~commands,~B,~builder),permission))
def projectile(seed:V.Body) -> Bool:
  match seed:
    case V.Body{_,_,+kind,_,_,_,_,_,_}:Bool.and(U32.is_le(3,kind),U32.is_le(kind,5))
def prepend_seed(seed:V.Body,parts:List<&2,V.Body> & List<&2,V.Body>) -> List<&2,V.Body> & List<&2,V.Body>:
  match parts:
    case (direct,firing):(seed <> direct,firing)
def split_seed(seed:V.Body,rest:List<&2,V.Body>,parts:List<&2,V.Body> & List<&2,V.Body>,isProjectile:Bool) -> List<&2,V.Body> & List<&2,V.Body>:
  match isProjectile:
    case True{}:([],seed <> rest)
    case False{}:prepend_seed(seed,parts)
def split_seeds(seeds:List<&2,V.Body>) -> List<&2,V.Body> & List<&2,V.Body>:
  match seeds:
    case []:([],[])
    case +seed <> +rest:split_seed(seed,rest,split_seeds(rest),projectile(seed))
def firing_status(~H:Type,~Q:Type,scope:H,queue:Q,user:User,visited:Bool,report:Query.Report<String>) -> H & (Q & (User & Sys.Completion<String,Unit>)):
  match visited report:
    case True{} Query.Completed{[]}:(scope,(queue,(user,Sys.Success{Unit{}})))
    case _ Query.Completed{Row.Error{_,error} <> _}:(scope,(queue,(user,Sys.BodyError{error,Unit{}})))
    case _ _:(scope,(queue,(user,Sys.BodyError{"player firing query refused",Unit{}})))
def firing_done(~H:Type,~Q:Type,prior:List<&2,W.Handle<D.Schema>>,result:H & (Firing<Q> & Query.Report<String>)) -> H & (Q & (User & Sys.Completion<String,Unit>)):
  match result:
    case (scope,(Firing{queue,seeds,player,handles,returned,visited},report)):firing_status(~H,~Q,scope,queue,User{seeds,List.append(&2,W.Handle<D.Schema>,prior,handles),returned,player},visited,report)
def rows_field(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,caps:Ops(Permit,F,H,Q)) -> Query.SequentialOutputEach<D.Schema,Permit,F,H,Firing<Q>,String>:
  match caps:
    case Caps{rows,_}:rows
def structural_field(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,caps:Ops(Permit,F,H,Q)) -> Permission.EntityCommands<Q,D.Schema,D.components(),Permit,F>:
  match caps:
    case Caps{_,structural}:structural
def fire(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(Permit,F,H,Q),scope:H,queue:Q,user:User) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match user:
    case User{[],handles,returned,player}:Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{[],handles,returned,player},Sys.Success{Unit{}}))))
    case User{seeds,handles,returned,player}:Effects.map(~F,(H & (Firing<Q> & Query.Report<String>)),(H & (Q & (User & Sys.Completion<String,Unit>))),effects,Query.each_sequential_output(~D.Schema,~Permit,~F,~H,~Firing<Q>,~String,rows_field(~Permit,~F,~H,~Q,caps))(scope,Firing{queue,seeds,player,[],returned,False{}}),result => firing_done(~H,~Q,handles,result))
def direct_done(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(Permit,F,H,Q),firing:List<&2,V.Body>,result:H & (Q & (User & Sys.Completion<String,Unit>))) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match result:
    case (scope,(queue,(User{_,handles,returned,player},Sys.Success{_}))):fire(~Permit,~F,~effects,~H,~Q,~caps,scope,queue,User{firing,handles,returned,player})
    case (scope,(queue,(User{seeds,handles,returned,player},completion))):Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(User{List.append(&2,V.Body,seeds,firing),handles,returned,player},completion))))
def direct(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(Permit,F,H,Q),scope:H,queue:Q,handles:List<&2,W.Handle<D.Schema>>,player:Maybe<&2,W.Handle<D.Schema>>,parts:List<&2,V.Body> & List<&2,V.Body>) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match parts:
    case (seeds,firing):Effects.bind(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),(H & (Q & (User & Sys.Completion<String,Unit>))),effects,queue_seeds(~Permit,~F,~effects,~H,~Q,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,~F,structural_field(~Permit,~F,~H,~Q,caps)),seeds,scope,queue,handles,player),result => direct_done(~Permit,~F,~effects,~H,~Q,~caps,firing,result))
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Ops(Permit,F,H,Q),~commands:Local.Commands<Q,D.Schema,V.Body>,scope:H,queue:Q,user:User) -> F(H & (Q & (User & Sys.Completion<String,Unit>))):
  match user:
    case User{seeds,handles,[],None{}}:queue_seeds(~Permit,~F,~effects,~H,~Q,~Permission.spawn_field(~Q,~D.Schema,~D.components(),~Permit,~F,structural_field(~Permit,~F,~H,~Q,caps)),seeds,scope,queue,handles,None{})
    case User{seeds,handles,[],player}:direct(~Permit,~F,~effects,~H,~Q,~caps,scope,queue,handles,player,split_seeds(seeds))
    case user:Effects.pure(~F,(H & (Q & (User & Sys.Completion<String,Unit>))),effects,(scope,(queue,(user,Sys.BodyError{"spawn bundle retained after refusal",Unit{}}))))
def kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<D.Schema>),~H:Type,~B:Type,~builder:Build.Builder(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Permit,~F,~H,~B),book:B) -> B & Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops,Permit,F,H):
  Cmd.program_for_buffer(~D.Schema,~Decay.C(),~Decay.R(),~D.components(),~D.resources(),~route(),~Ops,~declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def compilation() -> Decl.Compilation<D.Schema,D.Columns(),Decay.C(),Decay.R(),Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops)>:
  Program.compile_framework(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Cmd.ScopedOps(~D.Schema,~D.components(),~D.resources(),~route(),~Ops),~kernel)
def Node() -> Type:Author.Node(~D.Schema,~D.components(),~D.resources(),~Unit,~route(),~Ops,~User,~String,~Unit,~declaration,~body)
