import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-lifetime-scope-description.bend as LinkedText
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ./controls/positive.bend as P
import ./controls/registered.bend as Registered
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-access.bend as A
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/execution-condition-registry.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-registration.bend as Common
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-command-leaf.bend as AuthorLeaf
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/chunk-column.bend as Column
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/deferred-command.bend as Deferred
import ../../test-fixtures/common/column-observation.bend as Observe

type Schema is Data:
  Schema{}
def layout() -> Layout.Layout:Layout.LayoutPair{Registered.layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.AtLeaf{}}
def Left() -> Type:Layout.columns(~Schema,Registered.layout())
def Store() -> Type:Layout.columns(~Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def resources() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def World() -> Type:W.World<Schema,Store(),Resources(),Unit>

def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def CmdOps(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Unit
def author_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,Schema,P.Token>,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~Schema,~layout(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~Schema,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~Schema,~resources(),~Q,~K),book:B,permission:K) -> B & (K & Unit):
  (book,(permission,Unit{}))
def peer_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> F(H & (Array<U32> & Sys.Completion<String,Unit>)):
  Effects.pure(~F,(H & (Array<U32> & Sys.Completion<String,Unit>)),effects,(scope,(token,Sys.Success{Unit{}})))
type AuthorLocal is Type:
  AuthorLocal{capture:P.Capture<Schema>,enabled:Bool}
def author_returned(~H:Type,~Q:Type,enabled:Bool,result:H & (Q & (P.Capture<Schema> & Sys.Completion<String,Unit>))) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match result:
    case (scope,(queue,(capture,done))):(scope,(queue,(AuthorLocal{capture,enabled},done)))
def author_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:Unit,~commands:Local.Commands<Q,Schema,P.Token>,scope:H,queue:Q,local:AuthorLocal) -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))):
  match local:
    case AuthorLocal{P.Capture{+handle},True{}}:Effects.pure(~F,(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,author_returned(~H,~Q,True{},P.body_sync(~Schema,~H,~Q,~caps,~commands,scope,Local.remove_field(~Q,~Schema,~P.Token,commands)(queue,handle),P.Capture{handle})))
    case AuthorLocal{capture,False{}}:Effects.pure(~F,(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,(scope,(queue,(AuthorLocal{capture,False{}},Sys.Success{Unit{}}))))
def author_compilation() -> AuthorLeaf.Compilation(~Schema,~layout(),~resources(),~path(),~CmdOps):Build.compile_framework(~Schema,~Store(),~Store(),~Resources(),~Cmd.ScopedOps(~Schema,~layout(),~resources(),~path(),~CmdOps),~Cmd.program_for_buffer(~Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,~author_declaration))

def AuthorOwner() -> Type:AuthorLeaf.Owner(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def AuthorCompilation() -> Type:AuthorLeaf.Compilation(~Schema,~layout(),~resources(),~path(),~CmdOps)
def Author() -> Type:AuthorLeaf.Node(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def peer_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema>),~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):
  Build.framework_program(~Schema,~Store(),~Store(),~Resources(),~Ops,~peer_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)

def peer_compilation() -> Decl.Compilation<Schema,Store(),Store(),Resources(),Ops>:Build.compile_framework(~Schema,~Store(),~Store(),~Resources(),~Ops,~peer_kernel)

def PeerOwner() -> Type:Sys.Owner<Schema,Store(),Store(),Resources(),Unit,Ops,Array<U32>,String,Unit,peer_kernel,peer_body>
def Peer() -> Type:Leaf.Node(~Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body)
def ReadOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:A.ComponentRead<Schema,H,U32>
def reader_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~read:Build.ComponentRead(~Schema,~Store(),~Resources(),~H,~B),~write:Build.ComponentWrite(~Schema,~Store(),~Resources(),~H,~B),~rread:Build.ResourceRead(~Schema,~Store(),~Resources(),~H,~B),~rwrite:Build.ResourceWrite(~Schema,~Store(),~Resources(),~H,~B),~query:Build.Query(~Schema,~Store(),~Store(),~Resources(),~F,~H,~B),~lifecycle:Build.Lifecycle(~Schema,~Store(),~Store(),~Resources(),~H,~B),book:B) -> B & ReadOps(Permit,F,H):
  read(layout(),path(),{==},{==},book)
def reader_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & ReadOps(Permit,F,H):
  builder(ReadOps,reader_selection(~Permit,~F,~H,~B),book)
def guard_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~read:Build.ComponentRead(~Schema,~Store(),~Resources(),~H,~B),~write:Build.ComponentWrite(~Schema,~Store(),~Resources(),~H,~B),~rread:Build.ResourceRead(~Schema,~Store(),~Resources(),~H,~B),~rwrite:Build.ResourceWrite(~Schema,~Store(),~Resources(),~H,~B),~query:Build.Query(~Schema,~Store(),~Store(),~Resources(),~F,~H,~B),~lifecycle:Build.Lifecycle(~Schema,~Store(),~Store(),~Resources(),~H,~B),book:B) -> B & ReadOps(Permit,F,H):
  read(layout(),path(),{==},{==},book)
def guard_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & ReadOps(Permit,F,H):
  builder(ReadOps,guard_selection(~Permit,~F,~H,~B),book)
type Seen is Type:
  Seen{token:Array<U32>,runs:U32,handle:W.Handle<Schema>,last:Maybe<&2,U32>}
def ready_value(value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:False{}
    case Some{value}:U32.is_eq(value,71)
def reader_returned(~H:Type,token:Array<U32>,runs:U32,handle:W.Handle<Schema>,result:H & Maybe<&2,U32>) -> H & (Seen & Sys.Completion<String,Unit>):
  match result:
    case (scope,value):(scope,(Seen{token,U32.add(runs,1),handle,value},Sys.Success{Unit{}}))
def reader_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:ReadOps(Permit,F,H),scope:H,local:Seen) -> F(H & (Seen & Sys.Completion<String,Unit>)):
  match local:
    case Seen{token,runs,+handle,_}:Effects.pure(~F,(H & (Seen & Sys.Completion<String,Unit>)),effects,reader_returned(~H,token,runs,handle,A.component_read_field(~Schema,~H,~U32,caps)(scope,handle)))
def guard_returned(~H:Type,token:Array<U32>,runs:U32,handle:W.Handle<Schema>,result:H & Maybe<&2,U32>) -> H & (Seen & Sys.Completion<String,Bool>):
  match result:
    case (scope,+value):(scope,(Seen{token,U32.add(runs,1),handle,value},Sys.Success{ready_value(value)}))
def guard_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:ReadOps(Permit,F,H),scope:H,local:Seen) -> F(H & (Seen & Sys.Completion<String,Bool>)):
  match local:
    case Seen{token,runs,+handle,_}:Effects.pure(~F,(H & (Seen & Sys.Completion<String,Bool>)),effects,guard_returned(~H,token,runs,handle,A.component_read_field(~Schema,~H,~U32,caps)(scope,handle)))
def reader_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema>),~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & ReadOps(Permit,F,H):
  Build.framework_program(~Schema,~Store(),~Store(),~Resources(),~ReadOps,~reader_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)

def reader_compilation() -> Decl.Compilation<Schema,Store(),Store(),Resources(),ReadOps>:Build.compile_framework(~Schema,~Store(),~Store(),~Resources(),~ReadOps,~reader_kernel)

def ReaderOwner() -> Type:Sys.Owner<Schema,Store(),Store(),Resources(),Unit,ReadOps,Seen,String,Unit,reader_kernel,reader_body>
def Reader() -> Type:Leaf.Node(~Schema,~layout(),~resources(),~Unit,~ReadOps,~Seen,~String,~Unit,~reader_kernel,~reader_body)
def guard_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema>),~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & ReadOps(Permit,F,H):
  Build.framework_program(~Schema,~Store(),~Store(),~Resources(),~ReadOps,~guard_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)


def GuardOwner() -> Type:Sys.Owner<Schema,Store(),Store(),Resources(),Unit,ReadOps,Seen,String,Bool,guard_kernel,guard_body>
def GuardCompilation() -> Type:Decl.Compilation<Schema,Store(),Store(),Resources(),ReadOps>
def guard_construction() -> GuardCompilation():Build.compile_framework(~Schema,~Store(),~Store(),~Resources(),~ReadOps,~guard_kernel)
def Guard() -> Type:Retained.CompiledBinding<GuardCompilation(),GuardOwner()>
def guard_dispatch() -> Reg.Dispatch(~World(),~Guard(),~String):Reg.retained_leaf_dispatch(~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~guard_kernel,~guard_body,~guard_construction())
def guard_registry(guard:Guard()) -> Common.ConditionRegistry<World(),Guard(),String,guard_dispatch()>:Reg.compile_retained_leaf(~String,~Schema,~Store(),~Resources(),~Unit,~ReadOps,~Seen,~guard_kernel,~guard_body,~guard_construction(),guard)
def LeftTree() -> Type:Common.Product<Author(),Reader()>
def Nodes() -> Type:Common.Product<LeftTree(),Peer()>


type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def State() -> Type:DepApp.State<World(),Nodes(),Guard(),Handler>
def Application() -> Type:Schedule.Scheduled<State()>
def token_value(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def token(owner:P.Token) -> String:
  match owner:
    case P.Token{owner}:token_value(Array.get(U32,owner,0))
def maybe_token(owner:Maybe<&1,P.Token>) -> String:
  match owner:
    case None{}:"none"
    case Some{owner}:token(owner)
def handle_text(value:W.Handle<Schema>) -> String:
  match value:
    case W.Handle{namespace,key}:U32.show(namespace) ++ ":" ++ Observe.key(key)
def entry(value:Buffer.Entry<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match value:
    case Buffer.Entry{handle,incoming}:handle_text(handle) ++ ":" ++ maybe_token(incoming)
    case Buffer.Despawn{handle}:"despawn:" ++ handle_text(handle)
    case Buffer.Spawn{handle,_}:"spawn:" ++ handle_text(handle)
    case Buffer.Relation{_,_}:"relation"
    case Buffer.LifetimeScope{_,_}:"lifetime-scope"
def receipt(value:Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>) -> String:
  match value:
    case Buffer.Applied{handle,previous}:"applied:" ++ handle_text(handle) ++ ":" ++ maybe_token(previous)
    case Buffer.Refused{handle,incoming}:"refused:" ++ handle_text(handle) ++ ":" ++ maybe_token(incoming)
    case Buffer.Despawned{handle,Product.Owner{removed,_}}:"despawned:" ++ handle_text(handle) ++ ":" ++ maybe_token(removed)
    case Buffer.DespawnRefused{handle}:"despawn-refused:" ++ handle_text(handle)
    case Buffer.LinkedDespawn{handle,status,_,_}:"linked-despawn:" ++ handle_text(handle) ++ ":" ++ LinkedText.linked_status(status)
    case Buffer.Spawned{handle,_}:"spawned:" ++ handle_text(handle)
    case Buffer.SpawnRefused{handle,_,_}:"spawn-refused:" ++ handle_text(handle)
    case Buffer.RelationPublished{_,_}:"relation-published"
    case Buffer.RelationUndeclared{_,_}:"relation-undeclared"
    case Buffer.ScopePublished{_,_,status,_,_}:"scope-published:" ++ LinkedText.status(status)
    case Buffer.ScopeStoreApplied{_,_,_}:"scope-store-applied"
def viewed_result(+cache:U32,result:Array<U32> & U32) -> Layout.Viewed<P.Token,U32> & String:
  match result:
    case (owner,+value):(Layout.Viewed{P.Token{owner},cache},U32.show(value) ++ "/cache=" ++ U32.show(cache))
def viewed(value:Layout.Viewed<P.Token,U32>) -> Layout.Viewed<P.Token,U32> & String:
  match value:
    case Layout.Viewed{P.Token{owner},cache}:viewed_result(cache,Array.get(U32,owner,0))
def world(world:W.World<Schema,Store(),Resources(),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{Layout.ColumnSlot{column},_},_,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};column=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<P.Token,U32>,~viewed,Column.capacity(~Schema,~Layout.Viewed<P.Token,U32>,column)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Resources(),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
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
def seen_value(value:Maybe<&2,U32>) -> String:
  match value:
    case None{}:"never"
    case Some{value}:U32.show(value)
def seen(value:Seen) -> String:
  match value:
    case Seen{token,runs,handle,last}:token_value(Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ":" ++ handle_text(handle) ++ ":" ++ seen_value(last)
def observed_values(prefix:String,owner:World(),author:AuthorOwner(),readerOwner:ReaderOwner(),peerOwner:PeerOwner(),guardOwner:GuardOwner(),handlerOwner:Handler,unapplied:List<&2,U32>) -> String:
  match author readerOwner peerOwner guardOwner handlerOwner:
    case Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{AuthorLocal{P.Capture{handle},_},Buffer.Buffer{pending,receipts},_}}} Sys.Owner{_,_,_,_,readerCursor,reader} Sys.Owner{_,_,_,_,peerCursor,peer} Sys.Owner{_,_,_,_,guardCursor,guard} Handler{handler,errors}:prefix ++ "|world=" ++ world(owner) ++ "|queue=" ++ List.show(&1,Buffer.Entry<Schema,P.Token,Removed.Removed(layout())>,entry,pending) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>,receipt,receipts) ++ "|handle=" ++ handle_text(handle) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|reader=" ++ seen(reader) ++ ":" ++ Tick.cursor_show(readerCursor) ++ "|guard=" ++ seen(guard) ++ ":" ++ Tick.cursor_show(guardCursor) ++ "|peer=" ++ token_value(Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def observed(prefix:String,application:Application()) -> String:
  match application:
    case Schedule.Scheduled{DepApp.State{owner,Common.Product{Common.Product{author,reader,_},peer,_},guard,handler,_},_,_,Schedule.Deferred{_,_,unapplied,_,_}}:observed_values(prefix,owner,Retained.owner(AuthorCompilation(),AuthorOwner(),author),Retained.owner(Decl.Compilation<Schema,Store(),Store(),Resources(),ReadOps>,ReaderOwner(),reader),Retained.owner(Decl.Compilation<Schema,Store(),Store(),Resources(),Ops>,PeerOwner(),peer),Retained.owner(GuardCompilation(),GuardOwner(),guard),handler,unapplied)
def pending_observed(prefix:String,result:Application() & Bool) -> String:
  match result:
    case (application,pending):observed(prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def author_dispatch() -> Author() -> World() -> U32 -> Author() & (World() & Exec.Invocation<String,Unit>):AuthorLeaf.dispatch(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~author_compilation())
def author_facts(node:Author()) -> Registry.Facts<Common.Registry<World(),Author(),String,Unit,author_dispatch()>>:Registry.command(~World(),~Author(),~String,~Unit,~author_dispatch(),AuthorLeaf.facts(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~author_compilation(),node))
def reader_dispatch() -> Reader() -> World() -> U32 -> Reader() & (World() & Exec.Invocation<String,Unit>):Leaf.dispatch(~Schema,~layout(),~resources(),~Unit,~ReadOps,~Seen,~String,~Unit,~reader_kernel,~reader_body,~reader_compilation())
def reader_facts(node:Reader()) -> Registry.Facts<Common.Registry<World(),Reader(),String,Unit,reader_dispatch()>>:Registry.ordinary(~World(),~Reader(),~String,~Unit,~reader_dispatch(),Leaf.facts(~Schema,~layout(),~resources(),~Unit,~ReadOps,~Seen,~String,~Unit,~reader_kernel,~reader_body,~reader_compilation(),node))

def peer_dispatch() -> Peer() -> World() -> U32 -> Peer() & (World() & Exec.Invocation<String,Unit>):Leaf.dispatch(~Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~peer_compilation())
def peer_facts(node:Peer()) -> Registry.Facts<Common.Registry<World(),Peer(),String,Unit,peer_dispatch()>>:Registry.ordinary(~World(),~Peer(),~String,~Unit,~peer_dispatch(),Leaf.facts(~Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~peer_compilation(),node))

def left_dispatch() -> LeftTree() -> World() -> U32 -> LeftTree() & (World() & Exec.Invocation<String,Unit>):Common.paired_dispatch(~World(),~Author(),~Reader(),~String,~Unit,~author_dispatch(),~reader_dispatch())
def dispatch() -> Nodes() -> World() -> U32 -> Nodes() & (World() & Exec.Invocation<String,Unit>):Common.paired_dispatch(~World(),~LeftTree(),~Peer(),~String,~Unit,~left_dispatch(),~peer_dispatch())
def author_pending() -> List<&2,U32> -> World() -> Author() -> World() & (Author() & Bool):AuthorLeaf.pending(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def author_publish() -> List<&2,U32> -> Tick.Tick -> World() -> Author() -> World() & Author():AuthorLeaf.publish(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~{==},~Cmd.checked_relations(~Schema,~resources(),Cmd.compiled_permission(~Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,author_compilation())),~Cmd.construction_selection(~Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,author_compilation()))
def author_collect() -> List<&2,U32> -> Author() -> Author() & List<&2,U32>:AuthorLeaf.collect(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def left_pending() -> List<&2,U32> -> World() -> LeftTree() -> World() & (LeftTree() & Bool):Retention.pending_pair(~World(),~Author(),~Reader(),~author_pending(),~Retention.pending_none(~World(),~Reader()))
def left_publish() -> List<&2,U32> -> Tick.Tick -> World() -> LeftTree() -> World() & LeftTree():Retention.publish_pair(~World(),~Author(),~Reader(),~author_publish(),~Retention.publish_none(~World(),~Reader()))
def left_collect() -> List<&2,U32> -> LeftTree() -> LeftTree() & List<&2,U32>:Retention.collect_pair(~Author(),~Reader(),~author_collect(),~Retention.collect_none(~Reader()))
def pending() -> List<&2,U32> -> World() -> Nodes() -> World() & (Nodes() & Bool):Retention.pending_pair(~World(),~LeftTree(),~Peer(),~left_pending(),~Retention.pending_none(~World(),~Peer()))
def publish() -> List<&2,U32> -> Tick.Tick -> World() -> Nodes() -> World() & Nodes():Retention.publish_pair(~World(),~LeftTree(),~Peer(),~left_publish(),~Retention.publish_none(~World(),~Peer()))
def collect() -> List<&2,U32> -> Nodes() -> Nodes() & List<&2,U32>:Retention.collect_pair(~LeftTree(),~Peer(),~left_collect(),~Retention.collect_none(~Peer()))
def apply(ids:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & List<&2,U32>):Publication.apply(~Schema,~Store(),~Resources(),~Unit,~Nodes(),~pending(),~publish(),~collect(),ids,world,nodes)

def selected(app:Application()) -> Application() & DepApp.Report<String,Unit>:General.run(~Schema,~layout(),~resources(),~Unit,~Nodes(),~Guard(),~Handler,~String,~Unit,~dispatch(),~guard_dispatch(),~handle,~apply,app)
def pending_returned(guards:Guard(),handler:Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred,result:World() & (Nodes() & Bool)) -> Application() & Bool:
  match result:
    case (world,(nodes,found)):(Schedule.Scheduled{DepApp.State{world,nodes,guards,handler,stateBindings},plan,bindings,deferred},found)
def pending_with_deferred(guards:Guard(),handler:Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred,inspected:Schedule.Deferred,world:World(),nodes:Nodes()) -> Application() & Bool:
  match inspected:
    case Schedule.Deferred{systems,_,_,_,_}:pending_returned(guards,handler,stateBindings,plan,bindings,deferred,pending()(systems,world,nodes))

def exact_pending(app:Application()) -> Application() & Bool:
  match app:
    case Schedule.Scheduled{DepApp.State{world,nodes,guards,handler,stateBindings},plan,bindings,+deferred}:pending_with_deferred(guards,handler,stateBindings,plan,bindings,deferred,deferred,world,nodes)
def second(prefix:String,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):pending_observed(prefix ++ ";" ++ report(done),exact_pending(app))
def first(result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):second(report(done),selected(app))
type Setup is Type:
  SetupReady{application:Application()}
  SetupFailed{message:String}
def built(settings:Settings.Settings,world:World(),author:Author(),reader:Reader(),peer:Peer(),guard:Guard()) -> Setup:
  SetupReady{Schedule.configure(~State(),settings,General.build(~Schema,~layout(),~resources(),~Unit,~Nodes(),~Guard(),~Handler,~String,~Unit,~dispatch(),~guard_dispatch(),~(name => True{}),world,Registry.paired(~World(),~LeftTree(),~Peer(),~String,~Unit,~left_dispatch(),~peer_dispatch(),Registry.paired(~World(),~Author(),~Reader(),~String,~Unit,~author_dispatch(),~reader_dispatch(),author_facts(author),reader_facts(reader)),peer_facts(peer)),guard_registry(guard),Handler{ALeaf{901},0},[Plan.Edge{1,2}],[DepApp.Binding{2,4}]))}
def guard_defined(settings:Settings.Settings,author:Author(),reader:Reader(),peer:Peer(),result:GuardCompilation() & Sys.Defined<World(),GuardOwner(),Seen>) -> Setup:
  match result:
    case (compilation,Sys.Defined{world,guard}):built(settings,world,author,reader,peer,Retained.pack(GuardCompilation(),GuardOwner(),compilation,guard))
    case (_,Sys.DefinitionRefused{_,_}):SetupFailed{"ERROR: guard definition"}
def peer_defined(settings:Settings.Settings,handle:W.Handle<Schema>,author:Author(),reader:Reader(),result:Decl.Compilation<Schema,Store(),Store(),Resources(),Ops> & Sys.Defined<World(),PeerOwner(),Array<U32>>) -> Setup:
  match result:
    case (compilation,Sys.Defined{world,peer}):guard_defined(settings,author,reader,Retained.pack(Decl.Compilation<Schema,Store(),Store(),Resources(),Ops>,PeerOwner(),compilation,peer),Register.define_with_compilation(~Schema,~Store(),~Store(),~Resources(),~Unit,~ReadOps,~Seen,~String,~Bool,~guard_kernel,~guard_body,~Resources(),guard_construction(),world,"guard",Seen{ALeaf{601},0,handle,None{}}))
    case (_,Sys.DefinitionRefused{_,_}):SetupFailed{"ERROR: peer definition"}
def reader_defined(settings:Settings.Settings,handle:W.Handle<Schema>,author:Author(),result:Decl.Compilation<Schema,Store(),Store(),Resources(),ReadOps> & Sys.Defined<World(),ReaderOwner(),Seen>) -> Setup:
  match result:
    case (compilation,Sys.Defined{world,reader}):peer_defined(settings,handle,author,Retained.pack(Decl.Compilation<Schema,Store(),Store(),Resources(),ReadOps>,ReaderOwner(),compilation,reader),Leaf.define_with_compilation(~Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,peer_compilation(),world,"peer",ALeaf{801}))
    case (_,Sys.DefinitionRefused{_,_}):SetupFailed{"ERROR: reader definition"}
def author_defined(settings:Settings.Settings,+handle:W.Handle<Schema>,result:AuthorLeaf.Compilation(~Schema,~layout(),~resources(),~path(),~CmdOps) & Sys.Defined<World(),AuthorOwner(),Cmd.Captures(~Schema,~layout(),~resources(),~path(),~AuthorLocal)>) -> Setup:
  match result:
    case (compilation,Sys.Defined{world,author}):reader_defined(settings,handle,Retained.pack(AuthorCompilation(),AuthorOwner(),compilation,author),Leaf.define_with_compilation(~Schema,~layout(),~resources(),~Unit,~ReadOps,~Seen,~String,~Unit,~reader_kernel,~reader_body,reader_compilation(),world,"reader",Seen{ALeaf{501},0,handle,None{}}))
    case (_,Sys.DefinitionRefused{_,_}):SetupFailed{"ERROR: author definition"}
def activated(settings:Settings.Settings,enabled:Bool,+handle:W.Handle<Schema>,result:World() & W.Status) -> Setup:
  match result:
    case (world,W.Accepted{}):author_defined(settings,handle,AuthorLeaf.define_with_compilation(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~{==},author_compilation(),world,"author",AuthorLocal{P.Capture{handle},enabled}))
    case (_,_):SetupFailed{"ERROR: activation"}
def reserved(settings:Settings.Settings,enabled:Bool,result:W.World<Schema,Store(),Resources(),Unit> & W.Reservation<Schema>) -> Setup:
  match result:
    case (world,W.Reserved{+handle}):activated(settings,enabled,handle,W.activate(~Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):SetupFailed{"ERROR: reservation"}
def column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def empty(_:Unit) -> Store():
  Product.Owner{Layout.ColumnSlot{column(Column.swap(~Schema,~Layout.Viewed<P.Token,U32>,Column.empty(~Schema,~Layout.Viewed<P.Token,U32>),0,Some{Layout.Viewed{P.Token{ALeaf{1}},1}}))},Unit{}}
def created(settings:Settings.Settings,enabled:Bool,result:W.Creation<Schema,Store(),Resources(),Unit>) -> Setup:
  match result:
    case W.Created{_,world}:reserved(settings,enabled,W.reserve_id(~Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:SetupFailed{"ERROR: creation"}
def setup(settings:Settings.Settings,enabled:Bool) -> Setup:
  created(settings,enabled,W.create(~Schema,~Store(),~Resources(),~Unit,~empty,W.factory(),Product.Owner{Unit{},Unit{}}))
def setup_run(result:Setup) -> String:
  match result:
    case SetupReady{app}:first(selected(app))
    case SetupFailed{message}:message
def run(settings:Settings.Settings,enabled:Bool) -> String:setup_run(setup(settings,enabled))
def main() -> IO(Unit):
  IO.print("auto=" ++ run(Settings.defaults(),True{}) ++ "\nignored=" ++ run(Settings.Settings{True{},True{},[Plan.Edge{1,2}],[]},True{}) ++ "\nexplicit=" ++ run(Settings.Settings{False{},True{},[Plan.Edge{1,2}],[Settings.Explicit{2,None{}}]},True{}) ++ "\ndisabled=" ++ run(Settings.Settings{False{},True{},[],[]},True{}) ++ "\nfinaloff=" ++ run(Settings.Settings{True{},False{},[Plan.Edge{1,2}],[]},True{}))
