import Base
import ./notice-observation.bend as NoticeObserve
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/dependency-executor.bend as Exec
import ../query-systems/commands-core.bend as Core
import ../query-systems/command-body.bend as Body
import ../query-systems/payloads.bend as P
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-generalized-command-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/world.bend as W

type First is Data:
  First{}
type Second is Data:
  Second{}
def Runtime(~S:Data) -> Type:W.World<S,Core.Store(~S),Core.Resources(~S),Unit>
def Owner(~S:Data) -> Type:Core.AuthorOwner(~S,~Query.AllRows{})
def Node(~S:Data) -> Type:Core.Author(~S,~Query.AllRows{})
def invoke(~S:Data,node:Node(~S),world:Runtime(~S),id:U32) -> Node(~S) & (Runtime(~S) & Exec.Invocation<String,String>):
  Core.author_dispatch(~S,~Query.AllRows{},node,world,id)
def owner_token(~S:Data,+namespace:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,+runs:U32,commands:Buffer.Buffer<S,P.Output,Removed.Removed(Core.layout(~S))>,permission:Permission.Permission,pending:Bool,result:Array<U32> & U32) -> Owner(~S) & String:
  match result:
    case (token,value):(Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Body.User{token,runs},commands,permission}}},U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ U32.show(value) ++ ":" ++ U32.show(runs) ++ ":" ++ Bool.pick(String,pending,"true","false"))
def owner_pending(~S:Data,namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,token:Array<U32>,runs:U32,permission:Permission.Permission,result:Buffer.Buffer<S,P.Output,Removed.Removed(Core.layout(~S))> & Bool) -> Owner(~S) & String:
  match result:
    case (commands,pending):owner_token(~S,namespace,id,name,access,cursor,runs,commands,permission,pending,Array.get(U32,token,0))
def owner_observed(~S:Data,value:Owner(~S)) -> Owner(~S) & String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Body.User{token,runs},commands,permission}}}:owner_pending(~S,namespace,id,name,access,cursor,token,runs,permission,Buffer.pending(~S,~P.Output,~Removed.Removed(Core.layout(~S)),commands))
def observe_node(~S:Data,value:Node(~S)) -> Node(~S) & String:
  Retained.map_owner(Core.AuthorCompilation(~S),Owner(~S),String,owner_observed(~S),value)
def invocation_text(value:Exec.Invocation<String,String>) -> String:
  match value:
    case Exec.Completed{out}:"done:" ++ out
    case Exec.BodyError{error,out}:"error:" ++ error ++ ":" ++ out
    case Exec.AdmissionRefused{}:"admission-refused"
def world_returned(~S:Data,namespace:U32,allocator:Allocator.Allocator,store:Core.Store(~S),resource:Core.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Runtime(~S)>>,registrations:List<&2,W.RegistrationMeta>,next:U32,clock:Clock.State,result:Notice.Journal<S> & String) -> String:
  match result:
    case (journal,text):Core.world(~S,W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal}) ++ ";journal={" ++ text ++ "}"
def observed_world(~S:Data,value:Runtime(~S)) -> String:
  match value:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,journal}:world_returned(~S,namespace,allocator,store,resource,events,pending,registrations,next,clock,NoticeObserve.journal(~S,journal))
def final_owner_opened(~S:Data,prefix:String,world:Runtime(~S),foreign:Runtime(~S),value:Owner(~S)) -> String:
  match value:
    case Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,Local.Local{Body.User{token,runs},Buffer.Buffer{pending,receipts},_}}}:prefix ++ ";owner=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ Core.token_value(~S,Array.get(U32,token,0)) ++ ":" ++ U32.show(runs) ++ ";queue=" ++ List.show(&2,Core.Record,Core.record_text(~S),Core.entries(~S,pending)) ++ ";receipts=" ++ List.show(&2,Core.Record,Core.record_text(~S),Core.receipt_records(~S,receipts)) ++ ";original={" ++ observed_world(~S,world) ++ "};foreign={" ++ observed_world(~S,foreign) ++ "}"
def final_owner(~S:Data,prefix:String,world:Runtime(~S),foreign:Runtime(~S),value:Node(~S)) -> String:
  final_owner_opened(~S,prefix,world,foreign,Retained.owner(Core.AuthorCompilation(~S),Owner(~S),value))
def retried(~S:Data,prefix:String,foreign:Runtime(~S),result:Node(~S) & (Runtime(~S) & Exec.Invocation<String,String>)) -> String:
  match result:
    case (node,(world,status)):final_owner(~S,prefix ++ ";retry-status=" ++ invocation_text(status),world,foreign,node)
def retry_observed(~S:Data,prefix:String,id:U32,world:Runtime(~S),foreign:Runtime(~S),result:Node(~S) & String) -> String:
  match result:
    case (node,text):retried(~S,prefix ++ ";retained=" ++ text,foreign,invoke(~S,node,world,id))
def foreign_returned(~S:Data,id:U32,world:Runtime(~S),result:Node(~S) & (Runtime(~S) & Exec.Invocation<String,String>)) -> String:
  match result:
    case (node,(foreign,status)):retry_observed(~S,"foreign-status=" ++ invocation_text(status),id,world,foreign,observe_node(~S,node))
def defined(~S:Data,foreign:Runtime(~S),result:Core.AuthorCompilation(~S) & Sys.Defined<Runtime(~S),Owner(~S),Cmd.Captures(~S,~Core.layout(~S),~Core.resources(),~Core.path(~S),~Core.AuthorLocal(~S))>) -> String:
  match result:
    case (compilation,Sys.Defined{world,Cmd.Owner{Sys.Owner{namespace,+id,name,access,cursor,local}}}):foreign_returned(~S,id,world,invoke(~S,Retained.pack(Core.AuthorCompilation(~S),Owner(~S),compilation,Cmd.Owner{Sys.Owner{namespace,id,name,access,cursor,local}}),foreign,id))
    case _:"ERROR: definition"
def run(~S:Data,world:Runtime(~S),foreign:Runtime(~S)) -> String:
  defined(~S,Core.spawn(~S,18n,foreign),Leaf.define_with_compilation(~S,~Core.layout(~S),~Core.resources(),~Unit,~Core.path(~S),~Core.Ops(~S),~Core.AuthorLocal(~S),~String,~String,~Core.author_declaration(~S,~Query.AllRows{}),~Body.run(~S),~{==},Core.author_compilation(~S,~Query.AllRows{}),Core.spawn(~S,18n,world),"prepared-author",Body.User{ALeaf{900},0}))
