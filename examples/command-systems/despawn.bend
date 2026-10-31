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
import ./controls/removed-positive.bend as Fixture
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

type Schema is Data:
  Schema{}
def layout() -> Layout.Layout:Layout.LayoutPair{Fixture.layout(),Layout.EmptyLayout{}}
def path() -> Layout.Route:Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}}
def Left() -> Type:Layout.columns(~Schema,Fixture.layout())
def Store() -> Type:Layout.columns(~Schema,layout())
def Resources() -> Type:Product.Owner<Unit,Unit>
def resources() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def World() -> Type:W.World<Schema,Store(),Resources(),Unit>
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def CmdOps(Permit:Data,F:(Type -> Type),H:Type,Q:Type) -> Type:Permission.EntityCommands<Q,Schema,layout(),Permit,F>
def author_granted(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,~B:Type,~K:Type,book:B,result:K & CmdOps(Permit,F,H,Q)) -> B & (K & CmdOps(Permit,F,H,Q)):
  match result:
    case (permission,ops):(book,(permission,ops))
def author_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~commands:Local.Commands<Q,Schema,P.Token>,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),~K:Type,~entity:Permission.Grant(~Schema,~layout(),~Permit,~F,~Q,~K),~relations:Permission.RelationGrant(~Schema,~resources(),~Q,~K),~scopes:Permission.ScopeGrant(~Schema,~resources(),~Q,~K),book:B,permission:K) -> B & (K & CmdOps(Permit,F,H,Q)):
  author_granted(~Permit,~F,~H,~Q,~B,~K,book,Permission.entity(~Schema,~layout(),~Permit,~F,~Q,~K,~entity,permission))
def peer_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Unit:
  (book,Unit{})
def peer_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,token:Array<U32>) -> F(H & (Array<U32> & Sys.Completion<String,Unit>)):
  Effects.pure(~F,(H & (Array<U32> & Sys.Completion<String,Unit>)),effects,(scope,(token,Sys.Success{Unit{}})))
type AuthorLocal is Type:
  AuthorLocal{capture:P.Capture<Schema>,enabled:Bool}
def author_returned(~Permit:Data,~F:(Type -> Type),~H:Type,~Q:Type,enabled:Bool,result:H & (Q & (P.Capture<Schema> & Sys.Completion<String,Unit>))) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match result:
    case (scope,(queue,(capture,done))):(scope,(queue,(AuthorLocal{capture,enabled},done)))
def despawned_sync(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:CmdOps(Permit,F,H,Q),scope:H,queue:Q,capture:P.Capture<Schema>) -> H & (Q & (P.Capture<Schema> & Sys.Completion<String,Unit>)):
  match capture:
    case P.Capture{+handle}:P.authored(~Schema,~H,~Q,scope,Permission.despawn_field(~Q,~Schema,~layout(),~Permit,~F,caps)(queue,handle),handle)
def author_body_sync(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:CmdOps(Permit,F,H,Q),~commands:Local.Commands<Q,Schema,P.Token>,scope:H,queue:Q,local:AuthorLocal) -> H & (Q & (AuthorLocal & Sys.Completion<String,Unit>)):
  match local:
    case AuthorLocal{capture,True{}}:author_returned(~Permit,~F,~H,~Q,True{},despawned_sync(~Permit,~F,~effects,~H,~Q,~caps,scope,queue,capture))
    case AuthorLocal{capture,False{}}:(scope,(queue,(AuthorLocal{capture,False{}},Sys.Success{Unit{}})))
def author_body(~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~Q:Type,~caps:CmdOps(Permit,F,H,Q),~commands:Local.Commands<Q,Schema,P.Token>,scope:H,queue:Q,local:AuthorLocal) -> F(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))):
  Effects.pure(~F,(H & (Q & (AuthorLocal & Sys.Completion<String,Unit>))),effects,author_body_sync(~Permit,~F,~effects,~H,~Q,~caps,~commands,scope,queue,local))
def Author() -> Type:Command.Owner(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def peer_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema>),~H:Type,~B:Type,~builder:Build.Builder(~Schema,~Store(),~Store(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Unit:Build.framework_program(~Schema,~Store(),~Store(),~Resources(),~Ops,~peer_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def Peer() -> Type:Sys.Owner<Schema,Store(),Store(),Resources(),Unit,Ops,Array<U32>,String,Unit,peer_kernel,peer_body>


def PeerCompilation() -> Type:Decl.Compilation<Schema,Store(),Store(),Resources(),Ops>
def peer_compilation() -> PeerCompilation():Program.compile_framework(~Schema,~Store(),~Store(),~Resources(),~Ops,~peer_kernel)
def PeerNode() -> Type:Held.CompiledBinding<PeerCompilation(),Peer()>
def AuthorCompilation() -> Type:Command.Compilation(~Schema,~layout(),~resources(),~path(),~CmdOps)
def author_compilation() -> AuthorCompilation():Program.compile_framework(~Schema,~Store(),~Store(),~Resources(),~Cmd.ScopedOps(~Schema,~layout(),~resources(),~path(),~CmdOps),~Cmd.program_for_buffer(~Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,~author_declaration))
def AuthorNode() -> Type:Held.CompiledBinding<AuthorCompilation(),Author()>
def Owners() -> Type:Common.Product<AuthorNode(),PeerNode()>
def author_dispatch() -> AuthorNode() -> World() -> U32 -> AuthorNode() & (World() & Exec.Invocation<String,Unit>):Command.dispatch(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~author_compilation())
def peer_dispatch() -> PeerNode() -> World() -> U32 -> PeerNode() & (World() & Exec.Invocation<String,Unit>):Leaf.dispatch(~Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~peer_compilation())
def dispatch() -> Owners() -> World() -> U32 -> Owners() & (World() & Exec.Invocation<String,Unit>):Common.paired_dispatch(~World(),~AuthorNode(),~PeerNode(),~String,~Unit,~author_dispatch(),~peer_dispatch())
def facts(author:AuthorNode(),peer:PeerNode()) -> Registry.Facts<Common.Registry<World(),Owners(),String,Unit,dispatch()>>:
  Registry.paired(~World(),~AuthorNode(),~PeerNode(),~String,~Unit,~author_dispatch(),~peer_dispatch(),Registry.command(~World(),~AuthorNode(),~String,~Unit,~author_dispatch(),Command.facts(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~author_compilation(),author)),Registry.ordinary(~World(),~PeerNode(),~String,~Unit,~peer_dispatch(),Leaf.facts(~Schema,~layout(),~resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~peer_compilation(),peer)))
def author_pending() -> List<&2,U32> -> World() -> AuthorNode() -> World() & (AuthorNode() & Bool):Command.pending(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def author_publish() -> List<&2,U32> -> Tick.Tick -> World() -> AuthorNode() -> World() & AuthorNode():Command.publish(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~{==},~Cmd.checked_relations(~Schema,~resources(),Cmd.compiled_permission(~Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,author_compilation())),~Cmd.construction_selection(~Schema,~Store(),~Resources(),~layout(),~resources(),~path(),~CmdOps,author_compilation()))
def author_collect() -> List<&2,U32> -> AuthorNode() -> AuthorNode() & List<&2,U32>:Command.collect(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body)
def pending(ids:List<&2,U32>,world:World(),owners:Owners()) -> World() & (Owners() & Bool):Retention.pending_pair(~World(),~AuthorNode(),~PeerNode(),~author_pending(),~Retention.pending_none(~World(),~PeerNode()),ids,world,owners)
def publish(ids:List<&2,U32>,tick:Tick.Tick,world:World(),owners:Owners()) -> World() & Owners():Retention.publish_pair(~World(),~AuthorNode(),~PeerNode(),~author_publish(),~Retention.publish_none(~World(),~PeerNode()),ids,tick,world,owners)
def collect(ids:List<&2,U32>,owners:Owners()) -> Owners() & List<&2,U32>:Retention.collect_pair(~AuthorNode(),~PeerNode(),~author_collect(),~Retention.collect_none(~PeerNode()),ids,owners)
def publication(ids:List<&2,U32>,world:World(),owners:Owners()) -> World() & (Owners() & List<&2,U32>):Publication.apply(~Schema,~Store(),~Resources(),~Unit,~Owners(),~pending,~publish,~collect,ids,world,owners)

type Handler is Type:
  Handler{token:Array<U32>,errors:U32}
def handle(handler:Handler,error:String) -> Handler & Exec.Handling:
  match handler:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def State() -> Type:DepApp.State<World(),Owners(),Unit,Handler>
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
    case Buffer.Despawned{handle,Product.Owner{removed,_}}:"despawned:" ++ handle_text(handle) ++ ":" ++ Fixture.receipt(removed)
    case Buffer.DespawnRefused{handle}:"despawn-refused:" ++ handle_text(handle)
    case Buffer.LinkedDespawn{handle,status,_,_}:"linked-despawn:" ++ handle_text(handle) ++ ":" ++ LinkedText.linked_status(status)
    case Buffer.Spawned{handle,_}:"spawned:" ++ handle_text(handle)
    case Buffer.SpawnRefused{handle,_,_}:"spawn-refused:" ++ handle_text(handle)
    case Buffer.RelationPublished{_,_}:"relation-published"
    case Buffer.RelationUndeclared{_,_}:"relation-undeclared"
    case Buffer.ScopePublished{_,_,status,_,_}:"scope-published:" ++ LinkedText.status(status)
    case Buffer.ScopeStoreApplied{_,_,_}:"scope-store-applied"
def world(world:W.World<Schema,Store(),Resources(),Unit>) -> String:
  match world:
    case W.World{namespace,allocator,Product.Owner{Product.Owner{Layout.ColumnSlot{left},Layout.ColumnSlot{right}},_},_,events,pending,registrations,next,clock,lifecycle}:"namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};left=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<P.Token,U32>,~Fixture.token_project,Column.capacity(~Schema,~Layout.Viewed<P.Token,U32>,left)) ++ ";right=" ++ Observe.capacity_done(~Schema,~Layout.Viewed<Fixture.Other,U32>,~Fixture.other_project,Column.capacity(~Schema,~Layout.Viewed<Fixture.Other,U32>,right)) ++ ";events=" ++ Nat.show(List.length(&2,Unit,events)) ++ ";legacy-pending=" ++ Nat.show(List.length(&1,Deferred.Command<W.World<Schema,Store(),Resources(),Unit>>,pending)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock)
def permission_text(value:Permission.Permission) -> String:
  match value:
    case Permission.FamilyOnly{}:"family"
    case Permission.EntityStructural{}:"entity"
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
def observed_owners(prefix:String,owner:World(),handler:Handler,unapplied:List<&2,U32>,author:AuthorCompilation() & Author(),peer:PeerCompilation() & Peer()) -> String:
  match handler author peer:
    case Handler{handler,errors}, (_,Cmd.Owner{Sys.Owner{_,_,_,_,cursor,Local.Local{AuthorLocal{P.Capture{handle},_},Buffer.Buffer{pending,receipts},permission}}}), (_,Sys.Owner{_,_,_,_,peerCursor,peer}):prefix ++ "|world=" ++ world(owner) ++ "|permission=" ++ permission_text(permission) ++ "|queue=" ++ List.show(&1,Buffer.Entry<Schema,P.Token,Removed.Removed(layout())>,entry,pending) ++ "|receipts=" ++ List.show(&1,Buffer.Receipt<Schema,P.Token,Removed.Removed(layout())>,receipt,receipts) ++ "|handle=" ++ handle_text(handle) ++ "|cursor=" ++ Tick.cursor_show(cursor) ++ "|peer=" ++ token_value(Array.get(U32,peer,0)) ++ ":" ++ Tick.cursor_show(peerCursor) ++ "|handler=" ++ token_value(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|unapplied=" ++ List.show(&2,U32,U32.show,unapplied)
def observed(prefix:String,application:Application()) -> String:
  match application:
    case Schedule.Scheduled{DepApp.State{owner,Common.Product{author,peer,_},_,handler,_},_,_,Schedule.Deferred{_,_,unapplied,_,_}}:observed_owners(prefix,owner,handler,unapplied,Held.unpack(AuthorCompilation(),Author(),author),Held.unpack(PeerCompilation(),Peer(),peer))
def pending_observed(prefix:String,result:Application() & Bool) -> String:
  match result:
    case (application,pending):observed(prefix ++ ";exact-pending=" ++ Bool.pick(String,pending,"true","false"),application)
def selected(app:Application()) -> IO(Application() & DepApp.Report<String,Unit>):IO.pure(Application() & DepApp.Report<String,Unit>,General.run(~Schema,~layout(),~resources(),~Unit,~Owners(),~Unit,~Handler,~String,~Unit,~dispatch(),~Common.empty_dispatch(~World(),~String,~Bool),~handle,~publication,app))
def pending_returned(guards:Unit,handler:Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred,result:World() & (Owners() & Bool)) -> Application() & Bool:
  match result:
    case (world,(owners,found)):(Schedule.Scheduled{DepApp.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred},found)
def pending_with_deferred(guards:Unit,handler:Handler,stateBindings:List<&2,DepApp.Binding>,plan:Plan.Build<String>,bindings:List<&2,DepApp.Binding>,deferred:Schedule.Deferred,inspected:Schedule.Deferred,world:World(),owners:Owners()) -> Application() & Bool:
  match inspected:
    case Schedule.Deferred{systems,_,_,_,_}:pending_returned(guards,handler,stateBindings,plan,bindings,deferred,pending(systems,world,owners))
def exact_pending(app:Application()) -> Application() & Bool:
  match app:
    case Schedule.Scheduled{DepApp.State{world,owners,guards,handler,stateBindings},plan,bindings,+deferred}:pending_with_deferred(guards,handler,stateBindings,plan,bindings,deferred,deferred,world,owners)
def second(prefix:String,result:Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,done):pending_observed(prefix ++ ";" ++ report(done),exact_pending(app))
def first(result:Application() & DepApp.Report<String,Unit>) -> IO(String):
  match result:
    case (app,done):IO.bind(Application() & DepApp.Report<String,Unit>,String,selected(app),result => IO.pure(String,second(report(done),result)))
type Setup is Type:
  SetupReady{application:Application()}
  SetupFailed{message:String}
def application(world:World(),author:AuthorNode(),peer:PeerNode(),handler:Handler) -> Application():
  General.build(~Schema,~layout(),~resources(),~Unit,~Owners(),~Unit,~Handler,~String,~Unit,~dispatch(),~Common.empty_dispatch(~World(),~String,~Bool),~(name=>True{}),world,facts(author,peer),Common.empty_conditions(~World(),~String),handler,[],[])
def built(settings:Settings.Settings,world:World(),author:AuthorNode(),peer:PeerNode()) -> Setup:
  SetupReady{Schedule.configure(~State(),settings,application(world,author,peer,Handler{ALeaf{901},0}))}
def peer_defined(settings:Settings.Settings,author:AuthorNode(),result:PeerCompilation() & Sys.Defined<World(),Peer(),Array<U32>>) -> Setup:
  match result:
    case (compilation,Sys.Defined{world,peer}):built(settings,world,author,Held.pack(PeerCompilation(),Peer(),compilation,peer))
    case (_,Sys.DefinitionRefused{_,_}):SetupFailed{"ERROR: peer definition"}
def author_defined(settings:Settings.Settings,result:AuthorCompilation() & Sys.Defined<World(),Author(),Cmd.Captures(~Schema,~layout(),~resources(),~path(),~AuthorLocal)>) -> Setup:
  match result:
    case (compilation,Sys.Defined{world,author}):peer_defined(settings,Held.pack(AuthorCompilation(),Author(),compilation,author),Register.define_with_compilation(~Schema,~Store(),~Store(),~Resources(),~Unit,~Ops,~Array<U32>,~String,~Unit,~peer_kernel,~peer_body,~Resources(),peer_compilation(),world,"peer",ALeaf{801}))
    case (_,Sys.DefinitionRefused{_,_}):SetupFailed{"ERROR: author definition"}
def cache_selected(valid:Bool,owner:Author()) -> Author():
  match valid owner:
    case True{} owner:owner
    case False{} Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{user,queue,_}}}:Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{user,queue,Permission.FamilyOnly{}}}}
def cache_defined(valid:Bool,result:AuthorCompilation() & Sys.Defined<World(),Author(),Cmd.Captures(~Schema,~layout(),~resources(),~path(),~AuthorLocal)>) -> AuthorCompilation() & Sys.Defined<World(),Author(),Cmd.Captures(~Schema,~layout(),~resources(),~path(),~AuthorLocal)>:
  match result:
    case (compilation,Sys.Defined{world,owner}):(compilation,Sys.Defined{world,cache_selected(valid,owner)})
    case (compilation,Sys.DefinitionRefused{world,local}):(compilation,Sys.DefinitionRefused{world,local})
def activated(settings:Settings.Settings,enabled:Bool,handle:W.Handle<Schema>,result:W.World<Schema,Store(),Resources(),Unit> & W.Status) -> Setup:
  match result:
    case (world,W.Accepted{}):author_defined(settings,cache_defined(enabled,Command.define_with_compilation(~Schema,~layout(),~resources(),~Unit,~path(),~CmdOps,~AuthorLocal,~String,~Unit,~author_declaration,~author_body,~{==},author_compilation(),world,"author",AuthorLocal{P.Capture{handle},True{}})))
    case (_,_):SetupFailed{"ERROR: activation"}
def reserved(settings:Settings.Settings,enabled:Bool,result:W.World<Schema,Store(),Resources(),Unit> & W.Reservation<Schema>) -> Setup:
  match result:
    case (world,W.Reserved{+handle}):activated(settings,enabled,handle,W.activate(~Schema,~Store(),~Resources(),~Unit,world,handle))
    case (_,_):SetupFailed{"ERROR: reservation"}
def token_column(result:Column.SwapOutcome<Schema,Layout.Viewed<P.Token,U32>>) -> Column.Column<Schema,Layout.Viewed<P.Token,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def other_column(result:Column.SwapOutcome<Schema,Layout.Viewed<Fixture.Other,U32>>) -> Column.Column<Schema,Layout.Viewed<Fixture.Other,U32>>:
  match result:
    case Column.Accepted{column,_}:column
    case Column.Rejected{column,_}:column
def empty(_:Unit) -> Store():
  Product.Owner{Product.Owner{Layout.ColumnSlot{token_column(Column.swap(~Schema,~(Layout.Viewed<P.Token,U32>),Column.empty(~Schema,~(Layout.Viewed<P.Token,U32>)),0,Some{Layout.initialize(Fixture.layout(),Layout.InLeft{Layout.AtLeaf{}},P.Token{ALeaf{71}})}))},Layout.ColumnSlot{other_column(Column.swap(~Schema,~(Layout.Viewed<Fixture.Other,U32>),Column.empty(~Schema,~(Layout.Viewed<Fixture.Other,U32>)),0,Some{Layout.initialize(Fixture.layout(),Layout.InRight{Layout.AtLeaf{}},Fixture.Other{ALeaf{80}})}))}},Unit{}}
def created(settings:Settings.Settings,enabled:Bool,result:W.Creation<Schema,Store(),Resources(),Unit>) -> Setup:
  match result:
    case W.Created{_,world}:reserved(settings,enabled,W.reserve_id(~Schema,~Store(),~Resources(),~Unit,world))
    case W.CreateRejected{_,_}:SetupFailed{"ERROR: creation"}
def setup(settings:Settings.Settings,enabled:Bool) -> Setup:
  created(settings,enabled,W.create(~Schema,~Store(),~Resources(),~Unit,~empty,W.factory(),Product.Owner{Unit{},Unit{}}))
def setup_run(result:Setup) -> IO(String):
  match result:
    case SetupReady{app}:IO.bind(Application() & DepApp.Report<String,Unit>,String,selected(app),result => first(result))
    case SetupFailed{message}:IO.pure(String,message)
def run(settings:Settings.Settings,enabled:Bool) -> IO(String):
  setup_run(setup(settings,enabled))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(Settings.defaults(),True{}),final => IO.bind(String,Unit,run(Settings.Settings{True{},False{},[],[]},True{}),retained => IO.bind(String,Unit,run(Settings.defaults(),False{}),mismatch => IO.print("final=" ++ final ++ "\nretained=" ++ retained ++ "\ncache-mismatch=" ++ mismatch))))
