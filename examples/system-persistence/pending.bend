import Base
import ./declarations.bend as O
import ./receiver.bend as R
import ./execution.bend as E
import ./scheduled.bend as P
import ./setup.bend as Setup
import ./pending-command.bend as Author
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ./observation.bend as Observe
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-generalized-publication.bend as Publication
import ../../src/ecs/execution-command-retention.bend as Retention
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-retained-system.bend as Held
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-command-system.bend as Cmd
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-command-buffer.bend as Buffer
import ../../src/ecs/execution-command-removed.bend as Removed
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-deferred-settings.bend as Settings
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/world.bend as W

def Nodes(~S:Data) -> Type:Reg.Product<Author.Node(~S),E.Right(~S)>
def Application(~S:Data) -> Type:P.Application(~S,~Nodes(~S),~Unit,~E.Handler)
def dispatch(~S:Data) -> Nodes(~S) -> R.World(~S) -> U32 -> Nodes(~S) & (R.World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~R.World(~S),~Author.Node(~S),~E.Right(~S),~String,~String,~Author.dispatch(~S),~E.right_dispatch(~S))
def pending(~S:Data) -> List<&2,U32> -> R.World(~S) -> Nodes(~S) -> R.World(~S) & (Nodes(~S) & Bool):Retention.pending_pair(~R.World(~S),~Author.Node(~S),~E.Right(~S),~Author.pending(~S),~Retention.pending_none(~R.World(~S),~E.Right(~S)))
def publish(~S:Data,ids:List<&2,U32>,world:R.World(~S),nodes:Nodes(~S)) -> R.World(~S) & (Nodes(~S) & List<&2,U32>):Publication.apply(~S,~E.Columns(~S),~R.Resources(~S),~Unit,~Nodes(~S),~pending(~S),~Retention.publish_pair(~R.World(~S),~Author.Node(~S),~E.Right(~S),~Author.publish(~S),~Retention.publish_none(~R.World(~S),~E.Right(~S))),~Retention.collect_pair(~Author.Node(~S),~E.Right(~S),~Author.collect(~S),~Retention.collect_none(~E.Right(~S))),ids,world,nodes)
type Outcome<-S:Data> is Type:
  Refused{app:Application(~S),receipt:Receipt.Receipt<S>,savePending:Bool}
  SetupRefused{result:Setup.Defined<S>,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
  AuthorRefused{world:R.World(~S),local:Cmd.Captures(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Author.route(),~Author.Capture<S>),right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
  NoHandle{app:E.Application(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>}
  InitialRefused{world:R.World(~S),schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,reason:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
def restored(~S:Data,savePending:Bool,result:Application(~S) & Receipt.Receipt<S>) -> Outcome<S>:
  match result:
    case (app,receipt):Refused{app,receipt,savePending}
def saved(~S:Data,input:Saved.Snapshot<S>,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & (Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Outcome<S>:
  match result:
    case (schema,(app,Gate.RefusedPending{})):restored(~S,True{},P.restore(~S,~Nodes(~S),~Unit,~E.Handler,~pending(~S),schema,input,app))
    case (schema,(app,_)):restored(~S,False{},P.restore(~S,~Nodes(~S),~Unit,~E.Handler,~pending(~S),schema,input,app))
def ran(~S:Data,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Application(~S) & App.Report<String,String>) -> Outcome<S>:
  match result:
    case (app,_):saved(~S,input,P.save(~S,~Nodes(~S),~Unit,~E.Handler,~pending(~S),schema,app))
def built(~S:Data,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,app:Application(~S)) -> Outcome<S>:
  ran(~S,schema,input,General.run(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~Nodes(~S),~Unit,~E.Handler,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~R.World(~S),~String,~Bool),~E.handle,~publish(~S),app))
def defined(~S:Data,right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Author.Compilation(~S) & Sys.Defined<R.World(~S),Author.Owner(~S),Cmd.Captures(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Author.route(),~Author.Capture<S>)>) -> Outcome<S>:
  match result:
    case (_,Sys.DefinitionRefused{world,local}):AuthorRefused{world,local,right,handler,schema,input}
    case (compilation,Sys.Defined{world,author}):built(~S,schema,input,Schedule.configure(~App.State<R.World(~S),Nodes(~S),Unit,E.Handler>,Settings.Settings{False{},False{},[],[]},General.build(~S,~R.Components(~S),~Plan.layout(O.resources(~S)),~Unit,~Nodes(~S),~Unit,~E.Handler,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~R.World(~S),~String,~Bool),~(name=>True{}),world,Registry.paired(~R.World(~S),~Author.Node(~S),~E.Right(~S),~String,~String,~Author.dispatch(~S),~E.right_dispatch(~S),Author.facts(~S,Held.pack(Author.Compilation(~S),Author.Owner(~S),compilation,author)),E.right_facts(~S,right)),Reg.empty_conditions(~R.World(~S),~String),handler,[],[])))
def handles(~S:Data,left:E.Left(~S),right:E.Right(~S),handler:E.Handler,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:R.World(~S) & List<&2,W.Handle<S>>) -> Outcome<S>:
  match result:
    case (world,handle <> _):defined(~S,right,handler,schema,input,Author.define(~S,world,handle,left))
    case (world,[]):NoHandle{E.build(~S,world,left,right,handler),schema,input}
def setup(~S:Data,schema:Plan.Schema<S,O.components(~S),O.resources(~S)>,input:Saved.Snapshot<S>,result:Setup.Defined<S>) -> Outcome<S>:
  match result:
    case Setup.Defined{Schedule.Scheduled{App.State{world,Reg.Product{left,right,_},_,handler,_},_,_,_}}:handles(~S,left,right,handler,schema,input,W.handles(~S,~Layout.columns(~S,R.Components(~S)),~R.Resources(~S),~Unit,world))
    case other:SetupRefused{other,schema,input}
def initial(~S:Data,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & (R.World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Outcome<S>:
  match result:
    case (schema,(world,Gate.Saved{input})):setup(~S,schema,input,Setup.setup(~S,world))
    case (schema,(world,reason)):InitialRefused{world,schema,reason}
def run(~S:Data,world:R.World(~S)) -> Outcome<S>:initial(~S,Save.save(~S,~O.components(~S),~O.resources(~S),~Unit,O.schema(~S),world))
def refused_observed(~S:Data,app:Application(~S),savePending:Bool,result:Plan.Schema<S,O.components(~S),O.resources(~S)> & String) -> String:
  match result:
    case (actualSchema,receiptText):"savePending=" ++ Bool.show(savePending) ++ "/receipt=" ++ receiptText ++ "/schema=" ++ Observe.schema(~S,actualSchema) ++ "/application=" ++ Observe.scheduled(~S,~Nodes(~S),~Observe.pending_owners(~S),app)
def observed(~S:Data,result:Outcome<S>) -> String:
  match result:
    case Refused{app,receipt,savePending}:refused_observed(~S,app,savePending,Observe.receipt_for_save(~S,receipt))
    case SetupRefused{result,schema,input}:"setup-refused/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input) ++ "/result=" ++ Observe.setup(~S,result)
    case AuthorRefused{world,local,right,handler,schema,input}:"author-refused/world=" ++ Observe.world(~S,world) ++ "/local=" ++ Observe.command_local(~S,local) ++ "/right=" ++ Observe.right_owner(~S,right) ++ "/handler=" ++ Observe.handler(handler) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input)
    case NoHandle{app,schema,input}:"no-handle/application=" ++ Observe.scheduled(~S,~E.Nodes(~S),~Observe.basic_owners(~S),app) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/input=" ++ Observe.snapshot(~S,input)
    case InitialRefused{world,schema,reason}:"initial-refused/world=" ++ Observe.world(~S,world) ++ "/schema=" ++ Observe.schema(~S,schema) ++ "/save=" ++ Observe.save_result(~S,reason)
