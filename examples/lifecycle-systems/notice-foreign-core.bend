import Base
import ./notice-scenario-core.bend as Core
import ./notice-readers.bend as Readers
import ./notice-writer.bend as Writer
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-lifecycle.bend as Lifecycle
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-generalized-root-application.bend as Root
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick

def S() -> Data:Core.First
def Runtime() -> Type:Core.World(~S())
def Author() -> Type:Core.Author(~S(),~Query.AllRows{})
def Peer() -> Type:Core.Peer(~S())
def Application() -> Type:Core.Application(~S(),~Query.AllRows{})
type Snapshot is Type:
  Snapshot{world:Runtime(),author:Author(),peer:Peer(),handler:Core.Handler,reports:String}
def captured(prefix:String,app:Application()) -> Snapshot:
  match app:
    case Schedule.Scheduled{App.State{world,Reg.Product{author,peer,_},_,handler,_},_,_,_}:Snapshot{world,author,peer,handler,prefix}
def completed(remaining:Nat,prefix:String,result:Application() & App.Report<String,String>) -> Snapshot:
  match remaining result:
    case 0n, (app,report):captured(prefix ++ Core.report(~S(),report),app)
    case 1n+rest, (app,report):completed(rest,prefix ++ Core.report(~S(),report) ++ ";",Core.selected(~S(),~Query.AllRows{},app))
def identity(value:Lifecycle.Identity) -> String:
  match value:
    case Lifecycle.Identity{namespace,id,name,access,cursor}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor)
def handler(value:Core.Handler) -> String:
  match value:
    case Core.Handler{token,errors}:Core.token_value(~S(),Array.get(U32,token,0)) ++ ":" ++ U32.show(errors)
def author_opened(value:Core.AuthorOwner(~S(),~Query.AllRows{})) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Writer.User{token,runs,handles},Buffer.Buffer{pending,receipts},_}}}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ";user=" ++ Core.token_value(~S(),Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ";handles=" ++ List.show(&2,W.Handle<S()>,Core.handle_text(~S()),handles) ++ ";pending=" ++ List.show(&2,Core.Record,Core.record_text(~S()),Core.entries(~S(),pending)) ++ ";receipts=" ++ List.show(&2,Core.Record,Core.record_text(~S()),Core.receipt_records(~S(),receipts))
def author(value:Author()) -> String:
  author_opened(Retained.owner(Core.AuthorCompilation(~S()),Core.AuthorOwner(~S(),~Query.AllRows{}),value))
type Retired is Type:
  Retired{world:Runtime(),compilation:Core.PeerCompilation(~S()),identity:Lifecycle.Identity,local:Readers.Captures<S()>}
  Refused{world:Runtime(),node:Peer()}
def released(world:Runtime(),compilation:Core.PeerCompilation(~S()),result:Lifecycle.Released<Readers.Captures<S()>>) -> Retired:
  match result:
    case Lifecycle.Released{identity,local}:Retired{world,compilation,identity,local}
def retired(compilation:Core.PeerCompilation(~S()),result:Lifecycle.Retirement<Runtime(),Core.PeerOwner(~S())>) -> Retired:
  match result:
    case Lifecycle.Retired{world,detached}:released(world,compilation,Lifecycle.release(~S(),~Core.Store(~S()),~Core.Store(~S()),~Core.Resources(~S()),~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_kernel(~S()),~Core.peer_body(~S()),detached))
    case Lifecycle.RetirementRefused{world,node}:Refused{world,Retained.pack(Core.PeerCompilation(~S()),Core.PeerOwner(~S()),compilation,node)}
def retire_opened(node:Core.PeerCompilation(~S()) & Core.PeerOwner(~S()),world:Runtime()) -> Retired:
  match node:
    case (compilation,owner):retired(compilation,Lifecycle.retire(~S(),~Core.Store(~S()),~Core.Store(~S()),~Core.Resources(~S()),~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_kernel(~S()),~Core.peer_body(~S()),~Core.Resources(~S()),~Unit,owner,world))
def retire(node:Peer(),world:Runtime()) -> Retired:
  retire_opened(Retained.unpack(Core.PeerCompilation(~S()),Core.PeerOwner(~S()),node),world)
type RetainedA is Type:
  RetainedA{world:Runtime(),author:Author(),handler:Core.Handler,reports:String,compilation:Core.PeerCompilation(~S()),identity:Lifecycle.Identity}
type RetainedB is Type:
  RetainedB{identity:Lifecycle.Identity,local:Readers.Captures<S()>,reports:String}
def observed(left:RetainedA,old:RetainedB,result:Application() & App.Report<String,String>) -> String:
  match left old result:
    case RetainedA{world,writer,errors,reports,_,retired} RetainedB{oldIdentity,oldLocal,oldReport}, (app,report):"A={world=" ++ Core.notice_world(~S(),world) ++ ";author=" ++ author(writer) ++ ";handler=" ++ handler(errors) ++ ";reports=" ++ reports ++ ";retired=" ++ identity(retired) ++ "};B-retired={identity=" ++ identity(oldIdentity) ++ ";local=" ++ Readers.observed(~S(),oldLocal) ++ ";reports=" ++ oldReport ++ "};B-rebound={" ++ Core.observed(~S(),~Query.AllRows{},Core.report(~S(),report),app) ++ "}"
def rebuilt(world:Runtime(),writer:Author(),reader:Peer(),errors:Core.Handler) -> Application():
  Root.build(~S(),~Core.layout(~S()),~Core.resources(),~Unit,~Core.Nodes(~S(),~Query.AllRows{}),~Unit,~Core.Handler,~String,~String,~Core.dispatch(~S(),~Query.AllRows{}),~Reg.empty_dispatch(~Runtime(),~String,~Bool),~(name => True{}),world,Registry.paired(~Runtime(),~Author(),~Peer(),~String,~String,~Core.author_dispatch(~S(),~Query.AllRows{}),~Core.peer_dispatch(~S()),Core.author_facts(~S(),~Query.AllRows{},writer),Core.peer_facts(~S(),reader)),Reg.empty_conditions(~Runtime(),~String),errors,[Plan.Edge{1,3}],[])
def rebound(left:RetainedA,old:RetainedB,writer:Author(),errors:Core.Handler,result:Core.PeerCompilation(~S()) & Sys.Defined<Runtime(),Core.PeerOwner(~S()),Readers.Captures<S()>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,reader}):observed(left,old,Core.selected(~S(),~Query.AllRows{},rebuilt(world,writer,Retained.pack(Core.PeerCompilation(~S()),Core.PeerOwner(~S()),compilation,reader),errors)))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR: B fresh registration"
def b_retired(left:RetainedA,local:Readers.Captures<S()>,writer:Author(),errors:Core.Handler,reports:String,result:Retired) -> String:
  match result:
    case Retired{world,compilation,identity,old}:rebound(left,RetainedB{identity,old,reports},writer,errors,Leaf.define_with_compilation(~S(),~Core.layout(~S()),~Core.resources(),~Unit,~Core.PeerOps(~S()),~Readers.Captures<S()>,~String,~String,~Core.peer_kernel(~S()),~Core.peer_body(~S()),compilation,world,"foreign-reader",local))
    case Refused{_,_}:"ERROR: B retire"
def a_retired(writer:Author(),errors:Core.Handler,reports:String,right:Snapshot,result:Retired) -> String:
  match right result:
    case Snapshot{other,otherWriter,otherPeer,otherErrors,otherReport} Retired{world,compilation,identity,local}:b_retired(RetainedA{world,writer,errors,reports,compilation,identity},local,otherWriter,otherErrors,otherReport,retire(otherPeer,other))
    case _ Refused{_,_}:"ERROR: A retire"
def transfer(left:Snapshot,right:Snapshot) -> String:
  match left:
    case Snapshot{world,writer,peer,errors,reports}:a_retired(writer,errors,reports,right,retire(peer,world))
def run(left:Core.Setup<S(),Query.AllRows{}>,right:Core.Setup<S(),Query.AllRows{}>) -> String:
  match left right:
    case Core.NoticeReady{first} Core.NoticeReady{second}:transfer(completed(1n,"",Core.selected(~S(),~Query.AllRows{},first)),completed(0n,"",Core.selected(~S(),~Query.AllRows{},second)))
    case _ _:"ERROR: setup"
