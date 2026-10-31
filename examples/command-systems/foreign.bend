import Base
import ./visibility.bend as V
import ./controls/positive.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/owner-product.bend as Product

def World() -> Type:W.World<V.Schema,V.Store(),V.Resources(),Unit>
# Trusted fixture provisioning swaps actual owners to exercise namespace refusal.
# The same affine Factory creates both Worlds; no namespaces are fabricated.
def exchange(app:V.Application(),replacement:World()) -> V.Application() & World():
  match app:
    case Schedule.Scheduled{DepApp.State{world,owners,guards,handler,stateBindings},plan,bindings,deferred}:(Schedule.Scheduled{DepApp.State{replacement,owners,guards,handler,stateBindings},plan,bindings,deferred},world)
def final_enabled(app:V.Application()) -> V.Application():
  Schedule.configure(~V.State(),Settings.Settings{False{},True{},[],[]},app)
def author_quiet_raw(owner:V.AuthorOwner()) -> V.AuthorOwner() & Unit:
  match owner:
    case Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{V.AuthorLocal{capture,_},queue,permission}}}:(Cmd.Owner{Sys.Owner{a,b,c,d,cursor,Local.Local{V.AuthorLocal{capture,False{}},queue,permission}}},Unit{})
def author_quiet_returned(result:V.Author() & Unit) -> V.Author():
  match result:
    case (owner,_):owner
def author_quiet(owner:V.Author()) -> V.Author():
  author_quiet_returned(Retained.map_owner(V.AuthorCompilation(),V.AuthorOwner(),Unit,author_quiet_raw,owner))
def quiet(app:V.Application()) -> V.Application():
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{Reg.Product{author,reader,leftIds},peer,ids},guards,handler,stateBindings},plan,bindings,deferred}:Schedule.Scheduled{DepApp.State{world,Reg.Product{Reg.Product{author_quiet(author),reader,leftIds},peer,ids},guards,handler,stateBindings},plan,bindings,deferred}
def finished(prefix:String,result:V.Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,report):V.pending_observed(prefix ++ ";retry=" ++ V.report(report),V.exact_pending(app))
def restored(prefix:String,result:V.Application() & World()) -> String:
  match result:
    case (app,foreign):finished(prefix ++ "|foreign=" ++ V.world(foreign),V.selected(quiet(app)))
def pending_checked(original:World(),prefix:String,result:V.Application() & Bool) -> String:
  match result:
    case (app,pending):restored(prefix ++ ";foreign-pending=" ++ Bool.pick(String,pending,"true","false"),exchange(app,original))
def refused(original:World(),prefix:String,result:V.Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,report):pending_checked(original,prefix ++ ";foreign-run=" ++ V.report(report),V.exact_pending(app))
def replaced(prefix:String,result:V.Application() & World()) -> String:
  match result:
    case (app,original):refused(original,prefix,V.selected(final_enabled(app)))
def queued(foreign:World(),result:V.Application() & DepApp.Report<String,Unit>) -> String:
  match result:
    case (app,report):replaced("initial=" ++ V.report(report),exchange(app,foreign))
def setup(foreign:World(),result:V.Setup) -> String:
  match result:
    case V.SetupReady{app}:queued(foreign,V.selected(app))
    case V.SetupFailed{message}:message
def created(result:W.Creation<V.Schema,V.Store(),V.Resources(),Unit>) -> String:
  match result:
    case W.Created{factory,foreign}:setup(foreign,V.created(Settings.Settings{False{},False{},[],[]},True{},W.create(~V.Schema,~V.Store(),~V.Resources(),~Unit,~V.empty,factory,Product.Owner{Unit{},Unit{}})))
    case W.CreateRejected{_,_}:"ERROR: foreign creation"
def main() -> IO(Unit):
  IO.print(created(W.create(~V.Schema,~V.Store(),~V.Resources(),~Unit,~V.empty,W.factory(),Product.Owner{Unit{},Unit{}})))
