import Base
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-deferred-schedule.bend as DeferredSchedule
import ../../src/ecs/execution-trace-report.bend as TraceReport
import ../../src/ecs/execution-trace.bend as Trace
import ../common/trace-observation.bend as Observe
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ./app-a-systems.bend as Systems
import ./app-a-condition.bend as Condition
import ./app-a-captures.bend as Captures
import ./app-a-inspection.bend as Inspect
import ./app-a-group.bend as Group
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Root
import ../../src/ecs/execution-retained-system.bend as Scope
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/change-tick.bend as Tick

def Storage() -> Type:Systems.World()
def ApplicationState() -> Type:App.State<Storage(),Captures.Nodes(),Condition.Owner(),Unit>
def Application() -> Type:Root.Scheduled<ApplicationState()>
def dispatch() -> Captures.Nodes() -> Systems.World() -> U32 -> Captures.Nodes() & (Systems.World() & Exec.Invocation<String,String>):Group.run()

def publish(ids:List<&2,U32>,world:Systems.World(),nodes:Captures.Nodes()) -> Systems.World() & (Captures.Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(handler:Unit,_:String) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def run_observed(on:Bool,app:Application()) -> IO(Root.ObservedScheduled<ApplicationState(),String,String>):
  IO.pure(Root.ObservedScheduled<ApplicationState(),String,String>,General.run_observed(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Captures.Nodes(),~Condition.Owner(),~Unit,~String,~String,~dispatch(),~Condition.dispatch(),~handle,~publish,on,app))
def boundary_kind(value:DeferredSchedule.BoundaryKind) -> String:
  match value:
    case DeferredSchedule.Sync{ids}:"sync=" ++ List.show(&2,U32,U32.show,ids)
    case DeferredSchedule.Final{}:"final"
def boundary(value:DeferredSchedule.Boundary) -> String:
  match value:
    case DeferredSchedule.ApplyEntered{kind,requested}:boundary_kind(kind) ++ "/requested=" ++ List.show(&2,U32,U32.show,requested)
    case DeferredSchedule.ApplyReturned{kind,remaining}:boundary_kind(kind) ++ "/remaining=" ++ List.show(&2,U32,U32.show,remaining)
def trace_observed(application:Application(),boundaries:List<&2,DeferredSchedule.Boundary>,result:App.Report<String,String> & Trace.Batch<String>) -> IO(Application() & App.Report<String,String>):
  match result:
    case (report,batch):IO.bind(Unit,Application() & App.Report<String,String>,IO.print("AppA report trace|" ++ Observe.batch(batch)),_=>IO.bind(Unit,Application() & App.Report<String,String>,IO.print("AppA deferred boundaries|" ++ List.show(&2,DeferredSchedule.Boundary,boundary,boundaries)),_=>IO.pure(Application() & App.Report<String,String>,(application,report))))
def observed(on:Bool,result:Root.ObservedScheduled<ApplicationState(),String,String>) -> IO(Application() & App.Report<String,String>):
  match result:
    case Root.ObservedScheduled{Root.Scheduled{state,+plan,bindings,deferred},report,boundaries}:trace_observed(Root.Scheduled{state,plan,bindings,deferred},boundaries,TraceReport.read(~String,~String,on,plan,report))
# The existing application keeps the same returned owner between all three runs.
def run_mode(+on:Bool,app:Application()) -> IO(Application() & App.Report<String,String>):
  IO.bind(Root.ObservedScheduled<ApplicationState(),String,String>,Application() & App.Report<String,String>,run_observed(on,app),result=>observed(on,result))
def run(app:Application()) -> IO(Application() & App.Report<String,String>):
  run_mode(True{},app)
def facts(writer:Systems.WriterBinding(),query:Systems.QueryBinding(),reader:Systems.ReaderBinding()) -> Registry.Facts<Reg.Registry<Systems.World(),Captures.Nodes(),String,String,dispatch()>>:Group.facts(writer,query,reader)

type Definition is Type:
  DefinitionReady{application:Application()}
  RegistrationRefused{inventory:Systems.Registration}
  GuardRefused{world:Systems.World(),writer:Systems.WriterBinding(),query:Systems.QueryBinding(),reader:Systems.ReaderBinding(),local:Condition.Compilation() & U32}
def guard_defined(writer:Systems.WriterBinding(),query:Systems.QueryBinding(),reader:Systems.ReaderBinding(),writerId:U32,queryId:U32,readerId:U32,result:Condition.Compilation() & Sys.Defined<Systems.World(),Condition.RawOwner(),U32>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,Sys.Owner{namespace,+id,name,access,cursor,local}}):DefinitionReady{General.build(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Captures.Nodes(),~Condition.Owner(),~Unit,~String,~String,~dispatch(),~Condition.dispatch(),~available,world,facts(writer,query,reader),Condition.registry(Scope.pack(Condition.Compilation(),Condition.RawOwner(),compilation,Sys.Owner{namespace,id,name,access,cursor,local})),Unit{},[Plan.Edge{writerId,readerId}],[App.Binding{queryId,id}])}
    case (compilation,Sys.DefinitionRefused{world,local}):GuardRefused{world,writer,query,reader,(compilation,local)}
def WriterCompilation() -> Type:Decl.Compilation<P.AuditWorkshop,Systems.Columns(),Systems.C(),Systems.R(),Systems.WriterOps>
def ReaderCompilation() -> Type:Decl.Compilation<P.AuditWorkshop,Systems.Columns(),Systems.C(),Systems.R(),Systems.ReaderOps>
def QueryCompilation() -> Type:Decl.Compilation<P.AuditWorkshop,Systems.Columns(),Systems.C(),Systems.R(),Systems.QueryOps>
def writer_id_opened(pair:WriterCompilation() & Systems.Writer()) -> Systems.WriterBinding() & U32:
  match pair:
    case (compilation,Sys.Owner{namespace,+id,name,access,cursor,local}):(Scope.pack(WriterCompilation(),Systems.Writer(),compilation,Sys.Owner{namespace,id,name,access,cursor,local}),id)
def writer_id(binding:Systems.WriterBinding()) -> Systems.WriterBinding() & U32:writer_id_opened(Scope.unpack(WriterCompilation(),Systems.Writer(),binding))
def reader_id_opened(pair:ReaderCompilation() & Systems.Reader()) -> Systems.ReaderBinding() & U32:
  match pair:
    case (compilation,Sys.Owner{namespace,+id,name,access,cursor,local}):(Scope.pack(ReaderCompilation(),Systems.Reader(),compilation,Sys.Owner{namespace,id,name,access,cursor,local}),id)
def reader_id(binding:Systems.ReaderBinding()) -> Systems.ReaderBinding() & U32:reader_id_opened(Scope.unpack(ReaderCompilation(),Systems.Reader(),binding))
def ordered(world:Systems.World(),query:Systems.QueryBinding(),queryId:U32,writer:Systems.WriterBinding() & U32,reader:Systems.ReaderBinding() & U32) -> Definition:
  match writer reader:
    case (writer,writerId), (reader,readerId):guard_defined(writer,query,reader,writerId,queryId,readerId,Condition.define(world))
def query_opened(world:Systems.World(),writer:Systems.WriterBinding(),reader:Systems.ReaderBinding(),pair:QueryCompilation() & Systems.Query()) -> Definition:
  match pair:
    case (compilation,Sys.Owner{namespace,+id,name,access,cursor,local}):ordered(world,Scope.pack(QueryCompilation(),Systems.Query(),compilation,Sys.Owner{namespace,id,name,access,cursor,local}),id,writer_id(writer),reader_id(reader))
def registered(result:Systems.Registration) -> Definition:
  match result:
    case Systems.Registered{world,writer,query,reader}:query_opened(world,writer,reader,Scope.unpack(QueryCompilation(),Systems.Query(),query))
    case inventory:RegistrationRefused{inventory}
def define(world:Systems.World(),target:W.Handle<P.AuditWorkshop>) -> Definition:registered(Systems.define(world,target))
def guard_observed_opened(pair:Condition.Compilation() & Condition.RawOwner()) -> Condition.Owner() & String:
  match pair:
    case (compilation,Sys.Owner{+namespace,+id,name,access,+cursor,+local}):(Scope.pack(Condition.Compilation(),Condition.RawOwner(),compilation,Sys.Owner{namespace,id,name,access,cursor,local}),"condition-ns=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";calls=" ++ U32.show(local) ++ ";cursor=" ++ Tick.cursor_show(cursor))
def guard_observed(owner:Condition.Owner()) -> Condition.Owner() & String:guard_observed_opened(Scope.unpack(Condition.Compilation(),Condition.RawOwner(),owner))
def clock_observed(result:Systems.World() & Tick.Tick) -> Systems.World() & String:
  match result:
    case (world,tick):(world,"clock=" ++ Tick.show(tick))
def clock_named(namespace:U32,result:Systems.World() & String) -> Systems.World() & String:
  match result:
    case (world,text):(world,"world-ns=" ++ U32.show(namespace) ++ ";" ++ text)
def namespace_observed(result:Systems.World() & U32) -> Systems.World() & String:
  match result:
    case (world,namespace):clock_named(namespace,clock_observed(W.clock(~P.AuditWorkshop,~Systems.Columns(),~L.resources(~P.AuditWorkshop,Author.resources()),~Unit,world)))
def world_values(metadata:String,result:Systems.World() & String) -> Systems.World() & String:
  match result:
    case (world,text):(world,metadata ++ ";" ++ text)
def world_observed(target:W.Handle<P.AuditWorkshop>,result:Systems.World() & String) -> Systems.World() & String:
  match result:
    case (world,text):world_values(text,Inspect.paired(world,target))
def snapshot_returned(guardResult:Condition.Owner() & String,handler:Unit,stateBindings:List<&2,App.Binding>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,deferred:Root.Deferred,worldResult:Systems.World() & String,nodeResult:Captures.Nodes() & String) -> Application() & String:
  match guardResult worldResult nodeResult:
    case (guard,condition), (world,values), (nodes,captures):(Root.Scheduled{App.State{world,nodes,guard,handler,stateBindings},plan,bindings,deferred},values ++ ";" ++ captures ++ ";" ++ condition)
def snapshot(target:W.Handle<P.AuditWorkshop>,app:Application()) -> Application() & String:
  match app:
    case Root.Scheduled{App.State{world,nodes,guard,handler,stateBindings},plan,bindings,deferred}:snapshot_returned(guard_observed(guard),handler,stateBindings,plan,bindings,deferred,world_observed(target,namespace_observed(W.namespace(~P.AuditWorkshop,~Systems.Columns(),~L.resources(~P.AuditWorkshop,Author.resources()),~Unit,world))),Captures.nodes(nodes))
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/ran/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/body-error/" ++ error ++ "/" ++ out
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/admission-refused"
def report(value:App.Report<String,String>) -> String:
  match value:
    case App.Finished{events}:"finished:" ++ List.show(&2,Exec.Observation<String,String>,event,events)
    case App.Stopped{error,_}:"stopped:" ++ error
    case App.Invalid{_}:"invalid"
