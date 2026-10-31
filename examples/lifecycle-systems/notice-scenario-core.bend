import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ../query-systems/payloads.bend as P
import ../query-systems/declarations.bend as D
import ./notice-writer.bend as Decl
import ./notice-readers.bend as Readers
import ./notice-observation.bend as NoticeObserve
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-lifecycle-administration.bend as Admin
import ../../src/ecs/dependency-plan.bend as Plan
import ../query-systems/commands-core.bend as Core
import ../query-systems/command-body.bend as Body
import ../query-systems/observation.bend as QueryObserve
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-generalized-command-leaf.bend as AuthorLeaf
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-registry-program.bend as Prog
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

def layout(~S:Data) -> Layout.Layout:Layout.LayoutPair{D.layout(),Layout.EmptyLayout{}}
def path(~S:Data) -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}}}
def Left(~S:Data) -> Type:Layout.columns(~S,D.layout())
def Store(~S:Data) -> Type:Layout.columns(~S,layout(~S))
def resources() -> Layout.Layout:Layout.LayoutPair{D.resource_layout(),Layout.EmptyLayout{}}
def Resources(~S:Data) -> Type:Product.Owner<D.Resources(~S),Unit>
def Ops(~S:Data,Permit:Data,F:(Type -> Type),H:Type,O:Type) -> Type:Decl.Ops(~S,Permit,F,H,O)
def PeerOps(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Readers.Ops(~S,Permit,F,H)
def author_declaration(~S:Data,~mode:Query.Mode,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~O:Type,~commands:Local.Commands<O,S,P.Output>,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~S,~layout(~S),~Permit,~F,~O,~K),~relations:Permission.RelationGrant(~S,~resources(),~O,~K),~scopes:Permission.ScopeGrant(~S,~resources(),~O,~K),book:B,permission:K) -> B & (K & Ops(~S,Permit,F,H,O)):
  Decl.author_declaration(~S,~mode,~Permit,~F,~effects,~H,~O,~commands,~B,~builder,~K,~entity,~relations,~scopes,book,permission)
def peer_declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Readers.Ops(~S,Permit,F,H):
  Readers.declaration(~S,~Permit,~F,~effects,~H,~B,~builder,book)
def peer_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Readers.Ops(~S,Permit,F,H),scope:H,local:Readers.Captures<S>) -> F(H & (Readers.Captures<S> & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (Readers.Captures<S> & Sys.Completion<String,String>)),effects,Readers.body(~S,~H,~caps,scope,local))
def AuthorLocal(~S:Data) -> Type:Decl.User<S>
def peer_kernel(~S:Data,~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(~S),~Store(~S),~Resources(~S),~Permit,~F,~H,~B),book:B) -> B & PeerOps(~S,Permit,F,H):Build.framework_program(~S,~Store(~S),~Store(~S),~Resources(~S),~PeerOps(~S),~peer_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def AuthorOwner(~S:Data,~mode:Query.Mode) -> Type:Cmd.Owner<S,Store(~S),Resources(~S),Unit,layout(~S),resources(),path(~S),Ops(~S),AuthorLocal(~S),String,String,author_declaration(~S,~mode),Decl.body(~S)>
def PeerOwner(~S:Data) -> Type:Sys.Owner<S,Store(~S),Store(~S),Resources(~S),Unit,PeerOps(~S),Readers.Captures<S>,String,String,peer_kernel(~S),peer_body(~S)>
def AuthorCompilation(~S:Data) -> Type:Declaration.Compilation<S,Store(~S),Store(~S),Resources(~S),Cmd.ScopedOps(~S,~layout(~S),~resources(),~path(~S),~Ops(~S))>
def PeerCompilation(~S:Data) -> Type:Declaration.Compilation<S,Store(~S),Store(~S),Resources(~S),PeerOps(~S)>
def author_compilation(~S:Data,~mode:Query.Mode) -> AuthorCompilation(~S):Program.compile_framework(~S,~Store(~S),~Store(~S),~Resources(~S),~Cmd.ScopedOps(~S,~layout(~S),~resources(),~path(~S),~Ops(~S)),~Cmd.program_for_buffer(~S,~Store(~S),~Resources(~S),~layout(~S),~resources(),~path(~S),~Ops(~S),~author_declaration(~S,~mode)))
def peer_compilation(~S:Data) -> PeerCompilation(~S):Program.compile_framework(~S,~Store(~S),~Store(~S),~Resources(~S),~PeerOps(~S),~peer_kernel(~S))
def Author(~S:Data,~mode:Query.Mode) -> Type:Retained.CompiledBinding<AuthorCompilation(~S),AuthorOwner(~S,~mode)>
def Peer(~S:Data) -> Type:Retained.CompiledBinding<PeerCompilation(~S),PeerOwner(~S)>
type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(~S:Data,handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def World(~S:Data) -> Type:W.World<S,Store(~S),Resources(~S),Unit>
def Nodes(~S:Data,~mode:Query.Mode) -> Type:Reg.Product<Author(~S,~mode),Peer(~S)>
def Application(~S:Data,~mode:Query.Mode) -> Type:Schedule.Scheduled<DepApp.State<World(~S),Nodes(~S,~mode),Unit,Handler>>
def author_dispatch(~S:Data,~mode:Query.Mode) -> Author(~S,~mode) -> World(~S) -> U32 -> Author(~S,~mode) & (World(~S) & Exec.Invocation<String,String>):AuthorLeaf.dispatch(~S,~layout(~S),~resources(),~Unit,~path(~S),~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S),~author_compilation(~S,~mode))
def peer_dispatch(~S:Data) -> Peer(~S) -> World(~S) -> U32 -> Peer(~S) & (World(~S) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~layout(~S),~resources(),~Unit,~PeerOps(~S),~Readers.Captures<S>,~String,~String,~peer_kernel(~S),~peer_body(~S),~peer_compilation(~S))
def dispatch(~S:Data,~mode:Query.Mode) -> Nodes(~S,~mode) -> World(~S) -> U32 -> Nodes(~S,~mode) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~Author(~S,~mode),~Peer(~S),~String,~String,~author_dispatch(~S,~mode),~peer_dispatch(~S))
def author_pending(~S:Data,~mode:Query.Mode) -> List<&2,U32> -> World(~S) -> Author(~S,~mode) -> World(~S) & (Author(~S,~mode) & Bool):AuthorLeaf.pending(~S,~layout(~S),~resources(),~Unit,~path(~S),~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S))
def author_publish(~S:Data,~mode:Query.Mode) -> List<&2,U32> -> Tick.Tick -> World(~S) -> Author(~S,~mode) -> World(~S) & Author(~S,~mode):AuthorLeaf.publish(~S,~layout(~S),~resources(),~Unit,~path(~S),~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S),~{==},~Cmd.checked_relations(~S,~resources(),Cmd.compiled_permission(~S,~Store(~S),~Resources(~S),~layout(~S),~resources(),~path(~S),~Ops(~S),author_compilation(~S,~mode))),~Cmd.construction_selection(~S,~Store(~S),~Resources(~S),~layout(~S),~resources(),~path(~S),~Ops(~S),author_compilation(~S,~mode)))
def author_collect(~S:Data,~mode:Query.Mode) -> List<&2,U32> -> Author(~S,~mode) -> Author(~S,~mode) & List<&2,U32>:AuthorLeaf.collect(~S,~layout(~S),~resources(),~Unit,~path(~S),~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S))
def pending_nodes(~S:Data,~mode:Query.Mode,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S,~mode)) -> World(~S) & (Nodes(~S,~mode) & Bool):Retention.pending_pair(~World(~S),~Author(~S,~mode),~Peer(~S),~author_pending(~S,~mode),~Retention.pending_none(~World(~S),~Peer(~S)),ids,world,nodes)
def publish_nodes(~S:Data,~mode:Query.Mode,ids:List<&2,U32>,tick:Tick.Tick,world:World(~S),nodes:Nodes(~S,~mode)) -> World(~S) & Nodes(~S,~mode):Retention.publish_pair(~World(~S),~Author(~S,~mode),~Peer(~S),~author_publish(~S,~mode),~Retention.publish_none(~World(~S),~Peer(~S)),ids,tick,world,nodes)
def collect_nodes(~S:Data,~mode:Query.Mode,ids:List<&2,U32>,nodes:Nodes(~S,~mode)) -> Nodes(~S,~mode) & List<&2,U32>:Retention.collect_pair(~Author(~S,~mode),~Peer(~S),~author_collect(~S,~mode),~Retention.collect_none(~Peer(~S)),ids,nodes)
def apply(~S:Data,~mode:Query.Mode,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S,~mode)) -> World(~S) & (Nodes(~S,~mode) & List<&2,U32>):Publication.apply(~S,~Store(~S),~Resources(~S),~Unit,~Nodes(~S,~mode),~pending_nodes(~S,~mode),~publish_nodes(~S,~mode),~collect_nodes(~S,~mode),ids,world,nodes)
def author_facts(~S:Data,~mode:Query.Mode,node:Author(~S,~mode)) -> Registry.Facts<Reg.Registry<World(~S),Author(~S,~mode),String,String,author_dispatch(~S,~mode)>>:Registry.command(~World(~S),~Author(~S,~mode),~String,~String,~author_dispatch(~S,~mode),AuthorLeaf.facts(~S,~layout(~S),~resources(),~Unit,~path(~S),~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S),~author_compilation(~S,~mode),node))
def peer_facts(~S:Data,node:Peer(~S)) -> Registry.Facts<Reg.Registry<World(~S),Peer(~S),String,String,peer_dispatch(~S)>>:Registry.ordinary(~World(~S),~Peer(~S),~String,~String,~peer_dispatch(~S),Leaf.facts(~S,~layout(~S),~resources(),~Unit,~PeerOps(~S),~Readers.Captures<S>,~String,~String,~peer_kernel(~S),~peer_body(~S),~peer_compilation(~S),node))

def token_value(~S:Data,result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def handle_text(~S:Data,value:W.Handle<S>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Observe.key(key)
type Record is Data:
  Record{index:U32,token:U32,text:String}
def record_token(~S:Data,label:String,+handle:W.Handle<S>,value:U32,result:Array<U32> & U32) -> Record:
  match result:
    case (_, +token):Record{W.handle_index(~S,handle),token,label ++ handle_text(~S,handle) ++ ":" ++ U32.show(token) ++ ":" ++ U32.show(value)}
def payload_record(~S:Data,label:String,+handle:W.Handle<S>,owner:Maybe<&1,P.Output>) -> Record:
  match owner:
    case None{}:Record{W.handle_index(~S,handle),0,label ++ handle_text(~S,handle) ++ ":none"}
    case Some{P.Output{token,value}}:record_token(~S,label,handle,value,Array.get(U32,token,0))
def shared_record(value:Core.Record) -> Record:
  match value:
    case Core.Record{index,token,text}:Record{index,token,text}
def entry(~S:Data,value:Buffer.Entry<S,P.Output,Removed.Removed(layout(~S))>) -> Record:
  match value:
    case Buffer.Entry{handle,incoming}:payload_record(~S,"",handle,incoming)
    case Buffer.Despawn{handle}:payload_record(~S,"despawn:",handle,None{})
    case other:shared_record(Core.entry(~S,other))
def input_payload(value:Maybe<&1,P.Input>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:Observe.projected(~P.Input,P.input(owner))
def output_payload(value:Maybe<&1,P.Output>) -> String:
  match value:
    case None{}:"none"
    case Some{owner}:Observe.projected(~P.Output,P.output(owner))
def despawn_record(~S:Data,+handle:W.Handle<S>,removed:Removed.Removed(layout(~S))) -> Record:
  match removed:
    case Product.Owner{Product.Owner{Product.Owner{input,output},_},_}:Record{W.handle_index(~S,handle),0,"despawned:" ++ handle_text(~S,handle) ++ ":input=" ++ input_payload(input) ++ "/output=" ++ output_payload(output)}
def receipt(~S:Data,value:Buffer.Receipt<S,P.Output,Removed.Removed(layout(~S))>) -> Record:
  match value:
    case Buffer.Applied{handle,previous}:payload_record(~S,"applied:",handle,previous)
    case Buffer.Refused{handle,incoming}:payload_record(~S,"refused:",handle,incoming)
    case Buffer.Despawned{handle,removed}:despawn_record(~S,handle,removed)
    case Buffer.DespawnRefused{handle}:payload_record(~S,"despawn-refused:",handle,None{})
    case Buffer.LinkedDespawn{handle,status,_,_}:payload_record(~S,"linked-despawn:" ++ LinkedText.linked_status(status) ++ ":",handle,None{})
    case other:shared_record(Core.receipt(~S,other))
def record_before(~S:Data,left:Record,right:Record) -> Bool:
  match left right:
    case Record{+li,lt,_} Record{+ri,rt,_}:U32.is_lt(li,ri) || (U32.is_eq(li,ri) && U32.is_le(lt,rt))
def record_chosen(~S:Data,value:Record,head:Record,rest:List<&2,Record>,placed:List<&2,Record>,before:Bool) -> List<&2,Record>:
  match before:
    case True{}:value <> head <> rest
    case False{}:head <> placed
def record_insert(~S:Data,+value:Record,records:List<&2,Record>) -> List<&2,Record>:
  match records:
    case []:[value]
    case +head <> +rest:record_chosen(~S,value,head,rest,record_insert(~S,value,rest),record_before(~S,value,head))
def entries(~S:Data,values:List<Buffer.Entry<S,P.Output,Removed.Removed(layout(~S))>>) -> List<&2,Record>:
  match values:
    case []:[]
    case value <> rest:record_insert(~S,entry(~S,value),entries(~S,rest))
def receipt_records(~S:Data,values:List<Buffer.Receipt<S,P.Output,Removed.Removed(layout(~S))>>) -> List<&2,Record>:
  match values:
    case []:[]
    case value <> rest:record_insert(~S,receipt(~S,value),receipt_records(~S,rest))
def record_text(~S:Data,value:Record) -> String:
  match value:
    case Record{_,_,text}:text
def world(~S:Data,world:W.World<S,Store(~S),Resources(~S),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{store,_},Product.Owner{resource,_},events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};" ++ QueryObserve.store(~S,store) ++ ";resource=" ++ QueryObserve.resource(~S,resource) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<S,Store(~S),Resources(~S),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
def event(~S:Data,value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:"ran:" ++ U32.show(id) ++ ":" ++ out
    case Exec.BodyFailed{id,error,out}:"error:" ++ U32.show(id) ++ ":" ++ error ++ ":" ++ out
    case Exec.Skipped{id}:"skip:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"refused:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"condition-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"condition-refused:" ++ U32.show(id)
def report(~S:Data,value:DepApp.Report<String,String>) -> String:
  match value:
    case DepApp.Finished{events}:List.show(&2,Exec.Observation<String,String>,event(~S),events)
    case DepApp.Stopped{_,events}:"stopped:" ++ List.show(&2,Exec.Observation<String,String>,event(~S),events)
    case DepApp.Invalid{_}:"invalid"
def world_journal(~S:Data,namespace:U32,allocator:A.Allocator,store:Store(~S),resource:Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<W.World<S,Store(~S),Resources(~S),Unit>>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,result:Notice.Journal<S> & String) -> String:
  match result:
    case (journal,text):"journal={" ++ text ++ "};" ++ Core.world(~S,W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal})
def notice_world(~S:Data,world:W.World<S,Store(~S),Resources(~S),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal}:world_journal(~S,namespace,allocator,store,resource,events,pending,registrations,next,clock,NoticeObserve.journal(~S,journal))
def observed_owners(~S:Data,~mode:Query.Mode,prefix:String,owner:World(~S),author:AuthorOwner(~S,~mode),reader:PeerOwner(~S),handler:Array<U32>,errors:U32,unapplied:List<&2,U32>) -> String:
  match author reader:
    case Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{Decl.User{userToken,runs,handles},Buffer.Buffer{pending,receipts},permission}}} Sys.Owner{_,_,_,_,peerCursor,peer}:prefix ++ "|world=" ++ notice_world(~S,owner) ++ "|queue=" ++ List.show(&2,Record,record_text(~S),entries(~S,pending)) ++ "|receipts=" ++ List.show(&2,Record,record_text(~S),receipt_records(~S,receipts)) ++ "|handles=" ++ List.show(&2,W.Handle<S>,handle_text(~S),handles) ++ "|user=" ++ token_value(~S,Array.get(U32,userToken,0)) ++ ":" ++ U32.show(runs) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer={" ++ Readers.observed(~S,peer) ++ "}:" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(~S,Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def observed(~S:Data,~mode:Query.Mode,prefix:String,application:Application(~S,~mode)) -> String:
  match application:
    case Schedule.Scheduled{DepApp.State{owner,Reg.Product{author,peer,_},_,Handler{handler,errors},_},_,_,Schedule.Deferred{_,_,unapplied,_,_}}:observed_owners(~S,~mode,prefix,owner,Retained.owner(AuthorCompilation(~S),AuthorOwner(~S,~mode),author),Retained.owner(PeerCompilation(~S),PeerOwner(~S),peer),handler,errors,unapplied)
def pending_observed(~S:Data,~mode:Query.Mode,prefix:String,result:Application(~S,~mode) & Bool) -> String:
  match result:
    case (application,pending):observed(~S,~mode,prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(~S:Data,~mode:Query.Mode,app:Application(~S,~mode)) -> Application(~S,~mode) & DepApp.Report<String,String>:
  Root.run(~S,~layout(~S),~resources(),~Unit,~Nodes(~S,~mode),~Unit,~Handler,~String,~String,~dispatch(~S,~mode),~Reg.empty_dispatch(~World(~S),~String,~Bool),~handle(~S),~apply(~S,~mode),app)
def pending_returned(~S:Data,~mode:Query.Mode,restore:World(~S) -> Nodes(~S,~mode) -> Application(~S,~mode),result:World(~S) & (Nodes(~S,~mode) & Bool)) -> Application(~S,~mode) & Bool:
  match result:
    case (world,(nodes,active)):(restore(world,nodes),active)
def pending(~S:Data,~mode:Query.Mode,app:Application(~S,~mode)) -> Application(~S,~mode) & Bool:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{left,right,+ids},guards,handler,stateBindings},plan,bindings,deferred}:pending_returned(~S,~mode,world => nodes => Schedule.Scheduled{DepApp.State{world,nodes,guards,handler,stateBindings},plan,bindings,deferred},pending_nodes(~S,~mode,ids,world,Reg.Product{left,right,ids}))
def State(~S:Data,~mode:Query.Mode) -> Type:DepApp.State<World(~S),Nodes(~S,~mode),Unit,Handler>
def finished(~S:Data,~mode:Query.Mode,remaining:Nat,prefix:String,result:Application(~S,~mode) & DepApp.Report<String,String>) -> String:
  match remaining result:
    case 0n, (app,done):pending_observed(~S,~mode,prefix ++ report(~S,done),pending(~S,~mode,app))
    case 1n+rest, (app,done):finished(~S,~mode,rest,prefix ++ report(~S,done) ++ ";",selected(~S,~mode,app))
def first(~S:Data,~mode:Query.Mode,result:Application(~S,~mode) & DepApp.Report<String,String>) -> String:
  finished(~S,~mode,3n,"",result)
type Setup<-S:Data,-mode:Query.Mode> is Type:
  NoticeReady{application:Application(~S,~mode)}
  Failed{reason:String}
def setup_run(~S:Data,~mode:Query.Mode,result:Setup<S,mode>) -> String:
  match result:
    case NoticeReady{app}:first(~S,~mode,selected(~S,~mode,app))
    case Failed{reason}:reason
def built(~S:Data,~mode:Query.Mode,settings:Settings.Settings,world:W.World<S,Store(~S),Resources(~S),Unit>,author:Author(~S,~mode),peer:Peer(~S)) -> Setup<S,mode>:
  NoticeReady{Schedule.configure(~State(~S,~mode),settings,Root.build(~S,~layout(~S),~resources(),~Unit,~Nodes(~S,~mode),~Unit,~Handler,~String,~String,~dispatch(~S,~mode),~Reg.empty_dispatch(~World(~S),~String,~Bool),~(name => True{}),world,Registry.paired(~World(~S),~Author(~S,~mode),~Peer(~S),~String,~String,~author_dispatch(~S,~mode),~peer_dispatch(~S),author_facts(~S,~mode,author),peer_facts(~S,peer)),Reg.empty_conditions(~World(~S),~String),Handler{ALeaf{901},0},[Plan.Edge{1,2}],[]))}
def peer_defined(~S:Data,~mode:Query.Mode,settings:Settings.Settings,author:Author(~S,~mode),result:PeerCompilation(~S) & Sys.Defined<W.World<S,Store(~S),Resources(~S),Unit>,PeerOwner(~S),Readers.Captures<S>>) -> Setup<S,mode>:
  match result:
    case (compilation,Sys.Defined{world,peer}):built(~S,~mode,settings,world,author,Retained.pack(PeerCompilation(~S),PeerOwner(~S),compilation,peer))
    case (_,Sys.DefinitionRefused{_,_}):Failed{"ERROR: peer definition"}
def author_defined(~S:Data,~mode:Query.Mode,settings:Settings.Settings,readers:Readers.Captures<S>,result:AuthorCompilation(~S) & Sys.Defined<W.World<S,Store(~S),Resources(~S),Unit>,AuthorOwner(~S,~mode),Cmd.Captures(~S,~layout(~S),~resources(),~path(~S),~AuthorLocal(~S))>) -> Setup<S,mode>:
  match result:
    case (compilation,Sys.Defined{world,author}):peer_defined(~S,~mode,settings,Retained.pack(AuthorCompilation(~S),AuthorOwner(~S,~mode),compilation,author),Leaf.define_with_compilation(~S,~layout(~S),~resources(),~Unit,~PeerOps(~S),~Readers.Captures<S>,~String,~String,~peer_kernel(~S),~peer_body(~S),peer_compilation(~S),world,"reader",readers))
    case (_,Sys.DefinitionRefused{_,_}):Failed{"ERROR: author definition"}
def activated(~S:Data,result:W.World<S,Store(~S),Resources(~S),Unit> & W.Status) -> W.World<S,Store(~S),Resources(~S),Unit>:
  match result:
    case (world,_):world
def reserved(~S:Data,result:W.World<S,Store(~S),Resources(~S),Unit> & W.Reservation<S>) -> W.World<S,Store(~S),Resources(~S),Unit>:
  match result:
    case (world,W.Reserved{handle}):activated(~S,W.activate(~S,~Store(~S),~Resources(~S),~Unit,world,handle))
    case (world,_):world
def spawn(~S:Data,fuel:Nat,world:W.World<S,Store(~S),Resources(~S),Unit>) -> W.World<S,Store(~S),Resources(~S),Unit>:
  match fuel:
    case 0n:world
    case 1n+rest:spawn(~S,rest,reserved(~S,W.reserve_id(~S,~Store(~S),~Resources(~S),~Unit,world)))
def empty(~S:Data,_:Unit) -> Store(~S):Product.Owner{D.empty(~S,Unit{}),Unit{}}
def handles_ready(~S:Data,~mode:Query.Mode,settings:Settings.Settings,readers:Readers.Captures<S>,result:W.World<S,Store(~S),Resources(~S),Unit> & List<&2,W.Handle<S>>) -> Setup<S,mode>:
  match result:
    case (world,handles):author_defined(~S,~mode,settings,readers,AuthorLeaf.define_with_compilation(~S,~layout(~S),~resources(),~Unit,~path(~S),~Ops(~S),~AuthorLocal(~S),~String,~String,~author_declaration(~S,~mode),~Decl.body(~S),~{==},author_compilation(~S,~mode),world,"author",Decl.User{ALeaf{900},0,handles}))
def despawn_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,fast:Readers.OutputReader(~S),slow:Readers.OutputReader(~S),input:Readers.InputReader(~S),result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{despawn}):handles_ready(~S,~mode,settings,Readers.Captures{ALeaf{700},0,fast,slow,input,despawn,""},W.handles(~S,~Store(~S),~Resources(~S),~Unit,world))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: despawn reader"}
def input_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,fast:Readers.OutputReader(~S),slow:Readers.OutputReader(~S),result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Readers.input_origin(),Notice.Removed{"input"}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{input}):despawn_registered(~S,~mode,settings,fast,slow,input,Admin.register_despawn(~S,~Store(~S),~Resources(~S),~Unit,world,Notice.Retained{}))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: input reader"}
def slow_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,fast:Readers.OutputReader(~S),result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Readers.output_origin(),Notice.Removed{"output"}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{slow}):input_registered(~S,~mode,settings,fast,slow,Admin.register_removed(~S,~Store(~S),~Resources(~S),~Unit,~layout(~S),~Readers.input_route(),~{==},~{==},world,Notice.Retained{}))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: slow reader"}
def fast_registered(~S:Data,~mode:Query.Mode,settings:Settings.Settings,result:W.World<S,Store(~S),Resources(~S),Unit> & Notice.Registration<S,Readers.output_origin(),Notice.Removed{"output"}>) -> Setup<S,mode>:
  match result:
    case (world,Notice.Registered{fast}):slow_registered(~S,~mode,settings,fast,Admin.register_removed(~S,~Store(~S),~Resources(~S),~Unit,~layout(~S),~Readers.output_route(),~{==},~{==},world,Notice.Retained{}))
    case (_,Notice.RegistrationRefused{_}):Failed{"ERROR: fast reader"}
def admitted(~S:Data,~mode:Query.Mode,settings:Settings.Settings,world:W.World<S,Store(~S),Resources(~S),Unit>) -> Setup<S,mode>:
  fast_registered(~S,~mode,settings,Admin.register_removed(~S,~Store(~S),~Resources(~S),~Unit,~layout(~S),~Readers.output_route(),~{==},~{==},spawn(~S,18n,world),Notice.Retained{}))
def created(~S:Data,~mode:Query.Mode,settings:Settings.Settings,result:W.Creation<S,Store(~S),Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{_,world}:IO.pure(String,setup_run(~S,~mode,admitted(~S,~mode,settings,world)))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: creation")
type First is Data:First{}
def first_created(result:W.Creation<First,Store(~First),Resources(~First),Unit>) -> IO(String):
  created(~First,~Query.AllRows{},Settings.defaults(),result)
