import Base
import ./despawn.bend as D
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-lifecycle.bend as Life
import ../../src/ecs/execution-system-lifecycle.bend as SystemLife
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-registration.bend as Reg
import ../../test-fixtures/common/column-observation.bend as Observe

def World() -> Type:D.World()
type Held is Type:Held{peer:D.PeerNode(),handler:D.Handler}
type Mode is Data:
  RestoreMode{}
  RebindMode{}
  ExhaustedMode{}
def metadata(world:World()) -> World() & String:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,+registrations,+next,+clock,lifecycle}:(W.World{namespace,allocator,store,resource,events,pending,registrations,next,clock,lifecycle},"registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";next=" ++ U32.show(next) ++ ";clock=" ++ Observe.clock(clock))
def exhausted(world:World()) -> World():
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,_,clock,lifecycle}:W.World{namespace,allocator,store,resource,events,pending,registrations,4294967295,clock,lifecycle}
def owner_metadata(owner:D.Author()) -> D.Author() & String:
  match owner:
    case Cmd.Owner{Sys.Owner{a,+id,c,d,+cursor,Local.Local{user,queue,+permission}}}:(Cmd.Owner{Sys.Owner{a,id,c,d,cursor,Local.Local{user,queue,permission}}},"owner=" ++ U32.show(id) ++ ":" ++ Tick.cursor_show(cursor) ++ ":" ++ D.permission_text(permission))
def quiet_author(result:D.AuthorCompilation() & D.Author()) -> D.AuthorNode():
  match result:
    case (compilation,Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{D.AuthorLocal{capture,_},queue,permission}}}):Retained.pack(D.AuthorCompilation(),D.Author(),compilation,Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{D.AuthorLocal{capture,False{}},queue,permission}}})
def quiet(app:D.Application()) -> D.Application():
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{author,peer,ids},guards,handler,stateBindings},plan,bindings,deferred}:Schedule.Scheduled{DepApp.State{world,Reg.Product{quiet_author(Retained.unpack(D.AuthorCompilation(),D.Author(),author)),peer,ids},guards,handler,stateBindings},plan,bindings,deferred}
def finished(prefix:String,result:D.Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,report):D.pending_observed(prefix ++ ";final=" ++ D.report(report),D.exact_pending(app))
def rebuilt(prefix:String,result:D.Application() & Bool) -> IO(String):
  match result:
    case (Schedule.Scheduled{state,plan,bindings,Schedule.Deferred{systems,settings,+history,compiled,publicationIDs}},pending):IO.bind(D.Application() & DepApp.Report<String,Unit>,String,D.selected(quiet(Schedule.Scheduled{state,plan,bindings,Schedule.Deferred{systems,settings,history,compiled,publicationIDs}})),result => IO.pure(String,finished(prefix ++ ";rebuilt-pending=" ++ Bool.pick(String,pending,"true","false") ++ ";rebuilt-history=" ++ List.show(&2,U32,U32.show,history),result)))
def ready(prefix:String,world:World(),author:D.AuthorNode(),held:Held) -> IO(String):
  match held:
    case Held{peer,handler}:rebuilt(prefix,D.exact_pending(D.application(world,author,peer,handler)))
def owner_ready_world(prefix:String,compilation:D.AuthorCompilation(),world:World(),held:Held,result:D.Author() & String) -> IO(String):
  match result:
    case (author,text):ready(prefix ++ ";" ++ text,world,Retained.pack(D.AuthorCompilation(),D.Author(),compilation,author),held)
def owner_ready(prefix:String,compilation:D.AuthorCompilation(),author:D.Author(),held:Held,result:World() & String) -> IO(String):
  match result:
    case (world,text):owner_ready_world(prefix ++ ";" ++ text,compilation,world,held,owner_metadata(author))
def restored(prefix:String,held:Held,result:D.AuthorCompilation() & SystemLife.Restoration<World(),D.Author()>) -> IO(String):
  match result:
    case (compilation,SystemLife.Restored{world,owner}):owner_ready(prefix ++ ";restore=ok",compilation,owner,held,metadata(world))
    case (_,SystemLife.RestorationRefused{_,_}):IO.pure(String,"ERROR: restore refused")
def rebound(prefix:String,held:Held,result:D.AuthorCompilation() & Life.Rebinding<World(),D.Author()>) -> IO(String):
  match result:
    case (compilation,Life.Rebound{world,owner}):owner_ready(prefix ++ ";rebind=ok",compilation,owner,held,metadata(world))
    case (_,Life.RebindRefused{_,_}):IO.pure(String,"ERROR: rebind refused")
def restore(compilation:D.AuthorCompilation(),detached:SystemLife.Detached<D.Author()>,world:World()) -> D.AuthorCompilation() & SystemLife.Restoration<World(),D.Author()>:
  Life.restore_with_compilation(~D.Schema,~D.Store(),~D.Resources(),~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),compilation,detached,world)
def rebind(compilation:D.AuthorCompilation(),detached:SystemLife.Detached<D.Author()>,world:World()) -> D.AuthorCompilation() & Life.Rebinding<World(),D.Author()>:
  Life.rebind_with_compilation(~D.Schema,~D.Store(),~D.Resources(),~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),compilation,detached,world,"rebound")
def rebind_refused(prefix:String,held:Held,result:D.AuthorCompilation() & Life.Rebinding<World(),D.Author()>) -> IO(String):
  match result:
    case (_,Life.Rebound{_,_}):IO.pure(String,"ERROR: exhausted rebind succeeded")
    case (compilation,Life.RebindRefused{world,detached}):restored(prefix ++ ";rebind=refused",held,restore(compilation,detached,world))
def retired_metadata(mode:Mode,prefix:String,compilation:D.AuthorCompilation(),held:Held,detached:SystemLife.Detached<D.Author()>,result:World() & String) -> IO(String):
  match mode result:
    case RestoreMode{}, (world,text):restored(prefix ++ ";retired:" ++ text,held,restore(compilation,detached,world))
    case RebindMode{}, (world,text):rebound(prefix ++ ";retired:" ++ text,held,rebind(compilation,detached,world))
    case ExhaustedMode{}, (world,text):rebind_refused(prefix ++ ";retired:" ++ text,held,rebind(compilation,detached,exhausted(world)))
def retired(mode:Mode,prefix:String,compilation:D.AuthorCompilation(),held:Held,result:SystemLife.Retirement<World(),D.Author()>) -> IO(String):
  match result:
    case SystemLife.Retired{world,detached}:retired_metadata(mode,prefix,compilation,held,detached,metadata(world))
    case SystemLife.RetirementRefused{world,owner}:owner_ready(prefix ++ ";retire=refused",compilation,owner,held,metadata(world))
def retire(mode:Mode,prefix:String,world:World(),held:Held,result:D.AuthorCompilation() & D.Author()) -> IO(String):
  match result:
    case (compilation,author):retired(mode,prefix,compilation,held,Life.retire(~D.Schema,~D.Store(),~D.Resources(),~Unit,~D.layout(),~D.resources(),~D.path(),~D.CmdOps,~D.AuthorLocal,~String,~Unit,~D.author_declaration,~D.author_body,~D.Resources(),author,world))
def queued(mode:Mode,result:D.Application() & DepApp.Report<String,Unit>) -> IO(String):
  match result:
    case (Schedule.Scheduled{DepApp.State{world,Reg.Product{author,peer,_},_,handler,_},_,_,_},report):retire(mode,"initial=" ++ D.report(report),world,Held{peer,handler},Retained.unpack(D.AuthorCompilation(),D.Author(),author))
def setup(mode:Mode,result:D.Setup) -> IO(String):
  match result:
    case D.SetupReady{app}:IO.bind(D.Application() & DepApp.Report<String,Unit>,String,D.selected(app),result => queued(mode,result))
    case D.SetupFailed{message}:IO.pure(String,message)
def run(mode:Mode,valid:Bool) -> IO(String):
  setup(mode,D.setup(Settings.Settings{False{},False{},[],[]},valid))
def main() -> IO(Unit):
  IO.bind(String,Unit,run(RestoreMode{},True{}),restored => IO.bind(String,Unit,run(RebindMode{},True{}),rebound => IO.bind(String,Unit,run(ExhaustedMode{},True{}),refused => IO.bind(String,Unit,run(RestoreMode{},False{}),mismatch => IO.print("restore=" ++ restored ++ "\nrebind=" ++ rebound ++ "\nrebind-refused=" ++ refused ++ "\ncache-mismatch=" ++ mismatch)))))
