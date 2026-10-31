import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-generalized-command-leaf.bend as Command
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Held
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/dependency-registration.bend as Common
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./controls/positive.bend as P
import ./controls/registered.bend as Registered
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/trace-world.bend as Trace
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

import ./spawn.bend as S
import ./spawn-identity-observation.bend as ObserveIdentity
import ../../src/ecs/execution-resource-policy.bend as Policy
def local_layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.LayoutLeaf{S.Parcel,String,S.parcel_refresh,"parcel",Policy.Ordinary{}}}
def layout() -> Layout.Layout:Layout.LayoutPair{local_layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}
def Left() -> Type:Layout.columns(~S.Schema,local_layout())
def Store() -> Type:Layout.columns(~S.Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def resources() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def World() -> Type:W.World<S.Schema,Store(),Resources(),Unit>
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def CmdOps(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,S.Schema,layout(),Permit,F>
def author_granted(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & CmdOps(Permit,F,H,Q)) -> B & (K & CmdOps(Permit,F,H,Q)):
  match result:
    case (permission,caps):(book,(permission,caps))
def author_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,S.Schema,P.Token>,~B:Type,~builder:Build.Builder(~S.Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~S.Schema,~layout(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~S.Schema,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~S.Schema,~resources(),~Q,~K),book:B,permission:K) -> B & (K & CmdOps(Permit,F,H,Q)):
  author_granted(~Permit,~F,~H,~Q,~B,~K,book,Permission.entity(~S.Schema,~layout(),~Permit,~F,~Q,~K,~entity,permission))

def peer_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S.Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_written(~H:Type,scope:H,result:Array<U32> & U32) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  match result:
    case (token,_):(scope,(token,Sys.Success{Unit{}}))
def peer_seen(~H:Type,scope:H,result:Array<U32> & U32) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  match result:
    case (token,value):peer_written(~H,scope,Array.swap(U32,token,0,U32.add(value,1)))
def peer_body_sync(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,Unit>):
  peer_seen(~H,scope,Array.get(U32,token,0))

def peer_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> F(H & (Array<U32> & Sys.Completion<String,Unit>)):
  Effects.pure(~F,(H & (Array<U32> & Sys.Completion<String,Unit>)),effects,peer_body_sync(~Permit,~F,~effects,~H,~caps,scope,token))

type Action is Data:
  Spawn{value:U32}
  Erase{index:Nat}
  Write{index:Nat,value:U32}
  ForeignWrite{}
  ForeignErase{}
  SpawnErase{value:U32}
type AuthorLocal is Type:
  AuthorLocal{phase:U32,handles:List<&2,W.Handle<S.Schema>>,foreign:W.Handle<S.Schema>,rejected:List<Removed.Removed(layout())>,reasons:List<&2,W.WorldError>}
def bundle(+value:U32) -> Removed.Removed(layout()):
  Product.Owner{Product.Owner{Some{P.Token{ALeaf{value}}},Some{S.Parcel{ALeaf{"parcel-" ++ U32.show(value)}}}},Unit{}}
def target(index:Nat,handles:List<&2,W.Handle<S.Schema>>) -> Maybe<&2,W.Handle<S.Schema>>:
  match index handles:
    case _ Nil{}:None{}
    case 0n handle <> _:Some{handle}
    case 1n+rest _ <> tail:target(rest,tail)
def actions(phase:U32) -> List<&2,Action>:
  match phase:
    case 0:[Spawn{100},Spawn{200}]
    case 2:[Erase{0n},Spawn{300}]
    case 4:[Spawn{400}]
    case 5:[Write{0n,900},Erase{0n},ForeignWrite{},ForeignErase{}]
    case 6:[SpawnErase{500}]
    case 7:[Spawn{100},Spawn{200},Spawn{300},Spawn{400},Spawn{500},Spawn{600},Spawn{700},Spawn{800}]
    case 9:[Spawn{1000}]
    case 10:[Spawn{131072},Spawn{131073}]
    case _:[]
def completed(phase:U32) -> Sys.Completion<String,Unit>:
  match phase:
    case 1:Sys.Success{Unit{}}
    case 3:Sys.Success{Unit{}}
    case 8:Sys.Success{Unit{}}
    case _:Sys.BodyError{"after-actions",Unit{}}
def erase_if(~Q:Type,~erase:Q -> W.Handle<S.Schema> -> Q,queue:Q,handle:W.Handle<S.Schema>,enabled:Bool) -> Q:
  match enabled:
    case False{}:queue
    case True{}:erase(queue,handle)
def spawn_join(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~erase:Q -> W.Handle<S.Schema> -> Q,eraseAfter:Bool,next:H -> Q -> AuthorLocal -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),scope:H,user:AuthorLocal,result:Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>) -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))):
  match user result:
    case AuthorLocal{phase,handles,foreign,rejected,reasons} Tuple{queue,Buffer.SpawnQueued{+handle}}:next(scope,erase_if(~Q,~erase,queue,handle,eraseAfter),AuthorLocal{phase,List.append(&2,W.Handle<S.Schema>,handles,[handle]),foreign,rejected,reasons})
    case AuthorLocal{phase,handles,foreign,rejected,reasons} Tuple{queue,Buffer.SpawnRejected{bundle,error}}:next(scope,queue,AuthorLocal{phase,handles,foreign,bundle <> rejected,error <> reasons})
def write_or_erase(~Q:Type,~insert:Q -> W.Handle<S.Schema> -> P.Token -> Q,~erase:Q -> W.Handle<S.Schema> -> Q,queue:Q,handle:W.Handle<S.Schema>,value:Maybe<&2,U32>) -> Q:
  match value:
    case None{}:erase(queue,handle)
    case Some{value}:insert(queue,handle,P.Token{ALeaf{value}})
def target_join(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~insert:Q -> W.Handle<S.Schema> -> P.Token -> Q,~erase:Q -> W.Handle<S.Schema> -> Q,next:H -> Q -> AuthorLocal -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),scope:H,queue:Q,user:AuthorLocal,value:Maybe<&2,U32>,found:Maybe<&2,W.Handle<S.Schema>>) -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))):
  match found:
    case None{}:Effects.pure(~F,(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,(scope,(queue,(user,Sys.BodyError{"missing-handle",Unit{}}))))
    case Some{handle}:next(scope,write_or_erase(~Q,~insert,~erase,queue,handle,value),user)
def actions_done(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,scope:H,queue:Q,user:AuthorLocal) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match user:
    case AuthorLocal{+phase,handles,foreign,rejected,reasons}:(scope,(queue,(AuthorLocal{U32.add(phase,1),handles,foreign,rejected,reasons},completed(phase))))
def run_actions(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~insert:Q -> W.Handle<S.Schema> -> P.Token -> Q,~erase:Q -> W.Handle<S.Schema> -> Q,~spawn:Q -> Removed.Removed(layout()) -> F(Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>),todo:List<&2,Action>,scope:H,queue:Q,user:AuthorLocal) -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))):
  match todo:
    case Nil{}:Effects.pure(~F,(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,actions_done(~Permit,~F,~H,~Q,scope,queue,user))
    case action <> rest:
      match action user:
        case Spawn{value} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:Effects.bind(~F,(Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>),(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,spawn(queue,bundle(value)),admission=>spawn_join(~Permit,~F,~H,~Q,~erase,False{},scope => queue => user => run_actions(~Permit,~F,~effects,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,AuthorLocal{phase,handles,foreign,rejected,reasons},admission))
        case SpawnErase{value} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:Effects.bind(~F,(Q & Buffer.SpawnAdmission<S.Schema,Removed.Removed(layout())>),(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,spawn(queue,bundle(value)),admission=>spawn_join(~Permit,~F,~H,~Q,~erase,True{},scope => queue => user => run_actions(~Permit,~F,~effects,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,AuthorLocal{phase,handles,foreign,rejected,reasons},admission))
        case Erase{index} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:target_join(~Permit,~F,~effects,~H,~Q,~insert,~erase,scope => queue => user => run_actions(~Permit,~F,~effects,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,queue,AuthorLocal{phase,handles,foreign,rejected,reasons},None{},target(index,handles))
        case Write{index,value} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:target_join(~Permit,~F,~effects,~H,~Q,~insert,~erase,scope => queue => user => run_actions(~Permit,~F,~effects,~H,~Q,~insert,~erase,~spawn,rest,scope,queue,user),scope,queue,AuthorLocal{phase,handles,foreign,rejected,reasons},Some{value},target(index,handles))
        case ForeignWrite{} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:run_actions(~Permit,~F,~effects,~H,~Q,~insert,~erase,~spawn,rest,scope,insert(queue,foreign,P.Token{ALeaf{901}}),AuthorLocal{phase,handles,foreign,rejected,reasons})
        case ForeignErase{} AuthorLocal{phase,+handles,+foreign,rejected,reasons}:run_actions(~Permit,~F,~effects,~H,~Q,~insert,~erase,~spawn,rest,scope,erase(queue,foreign),AuthorLocal{phase,handles,foreign,rejected,reasons})
def author_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:CmdOps(Permit,F,H,Q),~commands:Local.Commands<Q,S.Schema,P.Token>,scope:H,queue:Q,user:AuthorLocal) -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))):
  match user:
    case AuthorLocal{+phase,handles,foreign,rejected,reasons}:run_actions(~Permit,~F,~effects,~H,~Q,~Local.insert_field(~Q,~S.Schema,~P.Token,commands),~Permission.despawn_field(~Q,~S.Schema,~layout(),~Permit,~F,caps),~Permission.spawn_field(~Q,~S.Schema,~layout(),~Permit,~F,caps),actions(phase),scope,queue,AuthorLocal{phase,handles,foreign,rejected,reasons})

def Author() -> Type:Command.Owner(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def peer_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S.Schema>),~H:Type,~B:Type,~builder:Build.Builder(~S.Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Unit:Build.framework_program(~S.Schema,~Store(),~Store(),~Resources(),~Ops,~peer_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def Peer() -> Type:Sys.Owner<S.Schema,Store(),Store(),Resources(),Unit,Ops,Array<U32>,String,Unit,peer_kernel,peer_body>


def PeerCompilation() -> Type:Decl.Compilation<S.Schema,Store(),Store(),Resources(),Ops>
def peer_compilation() -> PeerCompilation():Program.compile_framework(~S.Schema,~Store(),~Store(),~Resources(),~Ops,~peer_kernel)
def PeerNode() -> Type:Held.CompiledBinding<PeerCompilation(),Peer()>
def AuthorCompilation() -> Type:Command.Compilation(~S.Schema,~layout(),~resources(),~path(),~CmdOps)
def author_compilation() -> AuthorCompilation():Program.compile_framework(~S.Schema,~Store(),~Store(),~Resources(),~Cmd.ScopedOps(~S.Schema,~layout(),~resources(),~path(),~CmdOps),~Cmd.program_for_buffer(~S.Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,~author_declaration))
def AuthorNode() -> Type:Held.CompiledBinding<AuthorCompilation(),Author()>
def Owners() -> Type:Common.Product<AuthorNode(),PeerNode()>
def author_dispatch() -> AuthorNode() -> World() -> U32 -> AuthorNode() & (World() & Exec.Invocation<String,Unit>):Command.dispatch(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~author_compilation())
def peer_dispatch() -> PeerNode() -> World() -> U32 -> PeerNode() & (World() & Exec.Invocation<String,Unit>):Leaf.dispatch(~S.Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~peer_compilation())
def dispatch() -> Owners() -> World() -> U32 -> Owners() & (World() & Exec.Invocation<String,Unit>):Common.paired_dispatch(~World(),~AuthorNode(),~PeerNode(),~String,~Unit,~author_dispatch(),~peer_dispatch())
def facts(author:AuthorNode(),peer:PeerNode()) -> Registry.Facts<Common.Registry<World(),Owners(),String,Unit,dispatch()>>:
  Registry.paired(~World(),~AuthorNode(),~PeerNode(),~String,~Unit,~author_dispatch(),~peer_dispatch(),Registry.command(~World(),~AuthorNode(),~String,~Unit,~author_dispatch(),Command.facts(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~author_compilation(),author)),Registry.ordinary(~World(),~PeerNode(),~String,~Unit,~peer_dispatch(),Leaf.facts(~S.Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~peer_compilation(),peer)))
def author_pending() -> List<&2,U32> -> World() -> AuthorNode() -> World() & (AuthorNode() & Bool):Command.pending(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def author_publish() -> List<&2,U32> -> Tick.Tick -> World() -> AuthorNode() -> World() & AuthorNode():Command.publish(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~{==},~Cmd.checked_relations(~S.Schema,~resources(),Cmd.compiled_permission(~S.Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,author_compilation())),~Cmd.construction_selection(~S.Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,author_compilation()))
def author_collect() -> List<&2,U32> -> AuthorNode() -> AuthorNode() & List<&2,U32>:Command.collect(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def pending(ids:List<&2,U32>,world:World(),owners:Owners()) -> World() & (Owners() & Bool):Retention.pending_pair(~World(),~AuthorNode(),~PeerNode(),~author_pending(),~Retention.pending_none(~World(),~PeerNode()),ids,world,owners)
def publish(ids:List<&2,U32>,tick:Tick.Tick,world:World(),owners:Owners()) -> World() & Owners():Retention.publish_pair(~World(),~AuthorNode(),~PeerNode(),~author_publish(),~Retention.publish_none(~World(),~PeerNode()),ids,tick,world,owners)
def collect(ids:List<&2,U32>,owners:Owners()) -> Owners() & List<&2,U32>:Retention.collect_pair(~AuthorNode(),~PeerNode(),~author_collect(),~Retention.collect_none(~PeerNode()),ids,owners)
def publication(ids:List<&2,U32>,world:World(),owners:Owners()) -> World() & (Owners() & List<&2,U32>):Publication.apply(~S.Schema,~Store(),~Resources(),~Unit,~Owners(),~pending,~publish,~collect,ids,world,owners)

type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def State() -> Type:DepApp.State<World(),Owners(),Unit,Handler>
def Application() -> Type:Schedule.Scheduled<State()>
def event(value:Exec.Observation<String,Unit>) -> String:
  match value:
    case Exec.Ran{id,_}:"ran:" ++ U32.show(id)
    case Exec.BodyFailed{id,error,_}:"error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.Skipped{id}:"skip:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"refused:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"condition-refused:" ++ U32.show(id)
def report(value:DepApp.Report<String,Unit>) -> String:
  match value:
    case DepApp.Finished{events}:List.show(&2,Exec.Observation<String,Unit>,event,events)
    case DepApp.Stopped{_,events}:"stopped:" ++ List.show(&2,Exec.Observation<String,Unit>,event,events)
    case DepApp.Invalid{_}:"invalid"
def token_keep(value:P.Token) -> P.Token & String:
  match value:
    case P.Token{array}:
      ObserveIdentity.joined(Array<U32>,U32,P.Token & String,Array.get(U32,array,0),array => value =>
        (P.Token{array},U32.show(value)))
def parcel_keep(value:S.Parcel) -> S.Parcel & String:
  match value:
    case S.Parcel{array}:
      ObserveIdentity.joined(Array<String>,String,S.Parcel & String,Array.get(String,array,0),array => value =>
        (S.Parcel{array},value))
def maybe_keep(~T:Type,~show:T -> T & String,value:Maybe<&1,T>) -> Maybe<&1,T> & String:
  match value:
    case None{}:(None{},"none")
    case Some{value}:
      ObserveIdentity.joined(T,String,Maybe<&1,T> & String,show(value),value => text =>
        (Some{value},text))
def list_keep(~T:Type,~show:T -> T & String,values:List<T>) -> List<T> & String:
  match values:
    case []:([],"")
    case head <> tail:
      ObserveIdentity.joined(T,String,List<T> & String,show(head),head => ht =>
        ObserveIdentity.joined(List<T>,String,List<T> & String,list_keep(~T,~show,tail),tail => tt =>
          (head <> tail,ht ++ ";" ++ tt)))
def bundle_keep(value:Removed.Removed(layout())) -> Removed.Removed(layout()) & String:
  match value:
    case Product.Owner{Product.Owner{token,parcel},unit}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Removed.Removed(layout()) & String,maybe_keep(~P.Token,~token_keep,token),token => tt =>
        ObserveIdentity.joined(Maybe<&1,S.Parcel>,String,Removed.Removed(layout()) & String,maybe_keep(~S.Parcel,~parcel_keep,parcel),parcel => pt =>
          (Product.Owner{Product.Owner{token,parcel},unit},"token=" ++ tt ++ ",parcel=" ++ pt)))
def entry_keep(value:Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())>) -> Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())> & String:
  match value:
    case Buffer.Spawn{+handle,owner}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.Spawn{handle,owner},"spawn:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.Entry{+handle,owner}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())> & String,maybe_keep(~P.Token,~token_keep,owner),owner => text =>
        (Buffer.Entry{handle,owner},"write:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},"despawn:" ++ S.handle_text(handle))
    case value:(value,"unselected-command")
def receipt_keep(value:Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())>) -> Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String:
  match value:
    case Buffer.Spawned{+handle,owner}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.Spawned{handle,owner},"spawned:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.SpawnRefused{+handle,owner,+reason}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.SpawnRefused{handle,owner,reason},"spawn-refused:" ++ S.handle_text(handle) ++ ":" ++ text ++ ":" ++ S.spawn_reason(reason)))
    case Buffer.Despawned{+handle,owner}:
      ObserveIdentity.joined(Removed.Removed(layout()),String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,bundle_keep(owner),owner => text =>
        (Buffer.Despawned{handle,owner},"despawned:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.DespawnRefused{+handle}:(Buffer.DespawnRefused{handle},"despawn-refused:" ++ S.handle_text(handle))
    case Buffer.Applied{+handle,owner}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,maybe_keep(~P.Token,~token_keep,owner),owner => text =>
        (Buffer.Applied{handle,owner},"applied:" ++ S.handle_text(handle) ++ ":" ++ text))
    case Buffer.Refused{+handle,owner}:
      ObserveIdentity.joined(Maybe<&1,P.Token>,String,Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())> & String,maybe_keep(~P.Token,~token_keep,owner),owner => text =>
        (Buffer.Refused{handle,owner},"refused:" ++ S.handle_text(handle) ++ ":" ++ text))
    case value:(value,"unselected-receipt")
def permission_text(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family"
    case Permission.EntityStructural{}:"entity"
def header(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>) -> String:
  U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,value=>value,access) ++ ":" ++ Tick.cursor_show(cursor)
def snapshot_open(world:World(),guards:Unit,handler:Handler,bindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,appBindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred,ids:List<&2,U32>,author:AuthorCompilation() & Author(),peer:PeerCompilation() & Peer()) -> Application() & String:
  match handler deferred author peer:
    case Handler{handler,+errors}, Schedule.Deferred{+systems,+config,+unapplied,compiled,publicationIDs}, (compilation,Cmd.Owner{Sys.Owner{+an,+ai,+name,+access,+cursor,Local.Local{AuthorLocal{+phase,+handles,+foreign,rejected,+reasons},Buffer.Buffer{pending,receipts},+permission}}}), (peerCompilation,Sys.Owner{+pn,+pi,+pname,+pa,+pc,peer}):
      ObserveIdentity.joined(ObserveIdentity.World(),String,Application() & String,ObserveIdentity.inspected(world,List.append(&2,W.Handle<S.Schema>,handles,[foreign])),world => wt =>
        ObserveIdentity.joined(List<Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())>>,String,Application() & String,list_keep(~Buffer.Entry<S.Schema,P.Token,Removed.Removed(layout())>,~entry_keep,pending),pending => qt =>
          ObserveIdentity.joined(List<Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())>>,String,Application() & String,list_keep(~Buffer.Receipt<S.Schema,P.Token,Removed.Removed(layout())>,~receipt_keep,receipts),receipts => rt =>
            ObserveIdentity.joined(List<Removed.Removed(layout())>,String,Application() & String,list_keep(~Removed.Removed(layout()),~bundle_keep,rejected),rejected => jt =>
              ObserveIdentity.joined(Array<U32>,U32,Application() & String,Array.get(U32,peer,0),peer => pv =>
                ObserveIdentity.joined(Array<U32>,U32,Application() & String,Array.get(U32,handler,0),handler => hv =>
                  (Schedule.Scheduled{DepApp.State{world,Common.Product{Held.pack(AuthorCompilation(),Author(),compilation,Cmd.Owner{Sys.Owner{an,ai,name,access,cursor,Local.Local{AuthorLocal{phase,handles,foreign,rejected,reasons},Buffer.Buffer{pending,receipts},permission}}}),Held.pack(PeerCompilation(),Peer(),peerCompilation,Sys.Owner{pn,pi,pname,pa,pc,peer}),ids},guards,Handler{handler,errors},bindings},plan,appBindings,Schedule.Deferred{systems,config,unapplied,compiled,publicationIDs}},"world={" ++ wt ++ "}|author=" ++ header(an,ai,name,access,cursor) ++ ":phase=" ++ U32.show(phase) ++ ":permission=" ++ permission_text(permission) ++ "|queue={" ++ qt ++ "}|receipts={" ++ rt ++ "}|rejected={" ++ jt ++ "}:reasons=" ++ List.show(&2,W.WorldError,Trace.error,reasons) ++ "|peer=" ++ header(pn,pi,pname,pa,pc) ++ ":" ++ U32.show(pv) ++ "|handler=" ++ U32.show(hv) ++ ":" ++ U32.show(errors) ++ "|systems=" ++ List.show(&2,U32,U32.show,systems) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied))))))))
def snapshot(app:Application()) -> Application() & String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Common.Product{author,peer,ids},guards,handler,bindings},plan,appBindings,deferred}:snapshot_open(world,guards,handler,bindings,plan,appBindings,deferred,ids,Held.unpack(AuthorCompilation(),Author(),author),Held.unpack(PeerCompilation(),Peer(),peer))
def selected(app:Application()) -> IO(Application() & DepApp.Report<String,Unit>):IO.pure(Application() & DepApp.Report<String,Unit>,General.run(~S.Schema,~layout(),~resources(),~Unit,~Owners(),~Unit,~Handler,~String,~Unit,~dispatch(),~Common.empty_dispatch(~World(),~String,~Bool),~handle,~publication,app))
def settings(phase:U32) -> Settings.Settings:
  match phase:
    case 0:Settings.Settings{True{},False{},[],[]}
    case 2:Settings.Settings{True{},False{},[],[]}
    case 7:Settings.Settings{True{},False{},[],[]}
    case _:Settings.defaults()
def cancel_handles(skip:Nat,fuel:Nat,handles:List<&2,W.Handle<S.Schema>>,world:ObserveIdentity.World()) -> ObserveIdentity.World():
  match skip fuel handles:
    case _ _ Nil{}:world
    case 1n+skip fuel _ <> rest:cancel_handles(skip,fuel,rest,world)
    case 0n 0n _:world
    case 0n 1n+fuel handle <> rest:cancel_handles(0n,fuel,rest,W.clear_pending(~S.Schema,~Store(),~Resources(),~Unit,world,handle))
def cancel_open(world:World(),peer:PeerNode(),ids:List<&2,U32>,guards:Unit,handler:Handler,bindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,appBindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred,result:AuthorCompilation() & Author()) -> Application():
  match result:
    case (compilation,Cmd.Owner{Sys.Owner{an,ai,name,access,cursor,Local.Local{AuthorLocal{phase,+handles,foreign,rejected,reasons},queue,permission}}}):Schedule.Scheduled{DepApp.State{cancel_handles(6n,7n,handles,world),Common.Product{Held.pack(AuthorCompilation(),Author(),compilation,Cmd.Owner{Sys.Owner{an,ai,name,access,cursor,Local.Local{AuthorLocal{phase,handles,foreign,rejected,reasons},queue,permission}}}),peer,ids},guards,handler,bindings},plan,appBindings,deferred}
def cancel(app:Application()) -> Application():
  match app:
    case Schedule.Scheduled{DepApp.State{world,Common.Product{author,peer,ids},guards,handler,bindings},plan,appBindings,deferred}:cancel_open(world,peer,ids,guards,handler,bindings,plan,appBindings,deferred,Held.unpack(AuthorCompilation(),Author(),author))
def before(phase:U32,app:Application()) -> Application():
  match phase:
    case 8:cancel(app)
    case _:app
def updates(fuel:Nat,+phase:U32,app:Application(),foreign:ObserveIdentity.World(),log:String) -> IO(String):
  match fuel:
    case 0n:
      ObserveIdentity.joined(ObserveIdentity.World(),String,IO(String),ObserveIdentity.world_text(foreign),_ => text =>
        IO.pure(String,log ++ "foreign-final={" ++ text ++ "}"))
    case 1n+rest:
      ObserveIdentity.joined(Application(),String,IO(String),snapshot(before(phase,app)),app => prior =>
        IO.bind(Application() & DepApp.Report<String,Unit>,String,selected(Schedule.configure(~State(),settings(phase),app)),result =>
          ObserveIdentity.joined(Application(),DepApp.Report<String,Unit>,IO(String),result,app => done =>
            ObserveIdentity.joined(Application(),String,IO(String),snapshot(app),app => text =>
              updates(rest,U32.add(phase,1),app,foreign,log ++ "step=" ++ U32.show(phase) ++ ":before={" ++ prior ++ "}:report=" ++ report(done) ++ ":after={" ++ text ++ "}\n")))))
def built(start:U32,fuel:Nat,world:World(),author:AuthorNode(),peer:PeerNode(),foreign:ObserveIdentity.World()) -> IO(String):
  ObserveIdentity.joined(ObserveIdentity.World(),String,IO(String),ObserveIdentity.world_text(foreign),foreign => initial =>
    updates(fuel,start,General.build(~S.Schema,~layout(),~resources(),~Unit,~Owners(),~Unit,~Handler,~String,~Unit,~dispatch(),~Common.empty_dispatch(~World(),~String,~Bool),~(name=>True{}),world,facts(author,peer),Common.empty_conditions(~World(),~String),Handler{ALeaf{901},0},[],[]),foreign,"foreign-initial={" ++ initial ++ "}\n"))
def peer_defined(start:U32,fuel:Nat,author:AuthorNode(),foreign:ObserveIdentity.World(),result:PeerCompilation() & Sys.Defined<World(),Peer(),Array<U32>>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,peer}):built(start,fuel,world,author,Held.pack(PeerCompilation(),Peer(),compilation,peer),foreign)
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"peer-refused")
def author_defined(start:U32,fuel:Nat,foreign:ObserveIdentity.World(),result:AuthorCompilation() & Sys.Defined<World(),Author(),Cmd.Captures(~S.Schema,~layout(),~resources(),~path(),~AuthorLocal)>) -> IO(String):
  match result:
    case (compilation,Sys.Defined{world,author}):peer_defined(start,fuel,Held.pack(AuthorCompilation(),Author(),compilation,author),foreign,Register.define_with_compilation(~S.Schema,~Store(),~Store(),~Resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~Resources(),peer_compilation(),world,"peer",ALeaf{801}))
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"author-refused")
def registered_at(+start:U32,fuel:Nat,world:ObserveIdentity.World(),foreign:ObserveIdentity.World(),handle:W.Handle<S.Schema>) -> IO(String):
  author_defined(start,fuel,foreign,Command.define_with_compilation(~S.Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~{==},author_compilation(),world,"author",AuthorLocal{start,[],handle,[],[]}))
def activated_join(next:ObserveIdentity.World() -> IO(String),result:ObserveIdentity.World() & W.Status) -> IO(String):
  match result:
    case (world,W.Accepted{}):next(world)
    case (_,_):IO.pure(String,"activation-refused")
def reserved_join(next:ObserveIdentity.World() -> W.Handle<S.Schema> -> IO(String),result:ObserveIdentity.World() & W.Reservation<S.Schema>) -> IO(String):
  match result:
    case (world,W.Reserved{+handle}):activated_join(world => next(world,handle),W.activate(~S.Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):IO.pure(String,"reservation-refused")
def foreign_created(world:ObserveIdentity.World(),result:W.Creation<S.Schema,Store(),Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{_,foreign}:reserved_join(foreign => handle => registered_at(0,10n,world,foreign,handle),W.reserve_id(~S.Schema,~Store(),~Resources(),~Unit,foreign))
    case W.CreateRejected{_,_}:IO.pure(String,"foreign-creation-refused")
def created(result:W.Creation<S.Schema,Store(),Resources(),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}:reserved_join(world => _ => foreign_created(world,W.create(~S.Schema,~Store(),~Resources(),~Unit,~S.empty,factory,Product.Owner{Unit{},Unit{}})),W.reserve_id(~S.Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:IO.pure(String,"creation-refused")
def main() -> IO(Unit):
  IO.bind(String,Unit,created(W.create(~S.Schema,~Store(),~Resources(),~Unit,~S.empty,W.factory(),Product.Owner{Unit{},Unit{}})),IO.print)
