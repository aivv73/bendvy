import Base
import ../captured-systems/scheduled.bend as Existing
import ../captured-systems/declarations.bend as D
import ../captured-systems/bodies.bend as Body
import ../captured-systems/reports.bend as Common
import ./scheduled-observation.bend as Observe
import ../common/trace-observation.bend as TraceObserve
import ../../src/ecs/inspector.bend as I
import ../../src/ecs/execution-inspector.bend as Modern
import ../../src/ecs/execution-inspector-application.bend as Inspect
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-schedule.bend as App
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-application.bend as State
import ../../src/ecs/execution-trace.bend as Trace
import ../../src/ecs/execution-trace-report.bend as TraceReport

def Ops(H:Type) -> Type:Cap.Bundle<Cap.ValueRead<H,String>,Cap.ValueRead<H,String>>
def plan(~S:Data) -> I.Plan<S,D.Store(~S),D.Resources(~S),Unit,Ops>:
  I.Plan{Cap.Bundle{Modern.resource_grant(~I.Frame<S,D.Store(~S),D.Resources(~S),Unit>,~String,Modern.resource(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.resources_layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==})),Modern.resource_grant(~I.Frame<S,D.Store(~S),D.Resources(~S),Unit>,~String,Modern.resource(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.resources_layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==}))}}
def right_read(~H:Type,left:String,result:H & String) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,right):(owner,Done{left ++ "," ++ right})
def left_read(~H:Type,~right:Cap.ValueRead<H,String>,result:H & String) -> H & Result<&2,&2,String,String>:
  match result:
    case (owner,left):right_read(~H,left,Cap.value_read(~H,~String,~right,owner))
def left_cap(~H:Type,caps:Ops(H)) -> Cap.ValueRead<H,String>:
  match caps:
    case Cap.Bundle{left,_}:left
def right_cap(~H:Type,caps:Ops(H)) -> Cap.ValueRead<H,String>:
  match caps:
    case Cap.Bundle{_,right}:right
def body(~H:Type,~caps:Ops(H),_:Unit,owner:H) -> H & Result<&2,&2,String,String>:
  left_read(~H,~right_cap(~H,caps),Cap.value_read(~H,~String,~left_cap(~H,caps),owner))
def inspected_observed(~S:Data,before:String,outcome:Result<&2,&2,String,String>,instance:I.Instance<S> & String,observed:Existing.Application(~S) & String) -> Existing.Application(~S) & String:
  match instance observed:
    case (_,instanceText), (app,after):(app,before ++ "/instanceAfter=" ++ instanceText ++ "/result=" ++ Observe.result(outcome) ++ "/after={" ++ after ++ "}")
def inspected(~S:Data,before:String,result:Existing.Application(~S) & (I.Instance<S> & Result<&2,&2,String,String>)) -> Existing.Application(~S) & String:
  match result:
    case (app,(instance,outcome)):inspected_observed(~S,before,outcome,Observe.instance(~S,instance),Observe.application(~S,app))
def passive_instance(~S:Data,before:String,app:Existing.Application(~S),result:I.Instance<S> & String) -> Existing.Application(~S) & String:
  match result:
    case (instance,text):inspected(~S,"before={" ++ before ++ "}/instanceBefore=" ++ text,Inspect.passive(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Existing.Nodes(~S),~Unit,~Common.Handler,~Ops,~Unit,~String,~String,~plan(~S),~body,app,instance,Unit{}))
def passive_before(~S:Data,result:Existing.Application(~S) & String) -> Existing.Application(~S) & String:
  match result:
    case (app,before):passive_instance(~S,before,app,Observe.instance(~S,I.Fresh{}))
def passive(~S:Data,app:Existing.Application(~S)) -> Existing.Application(~S) & String:
  passive_before(~S,Observe.application(~S,app))
def selected_returned(~S:Data,passive:String,result:Existing.Application(~S) & State.Report<String,String>) -> Existing.Application(~S) & (State.Report<String,String> & String):
  match result:
    case (app,status):(app,(status,passive))
def selected(~S:Data,result:Existing.Application(~S) & String) -> Existing.Application(~S) & (State.Report<String,String> & String):
  match result:
    case (app,passive):selected_returned(~S,passive,Existing.run_application(~S,app))
def run_selected(~S:Data,enabled:Bool,app:Existing.Application(~S)) -> Existing.Application(~S) & (State.Report<String,String> & String):
  match enabled:
    case False{}:selected(~S,(app,"passive-disabled"))
    case True{}:selected(~S,passive(~S,app))
def reported(~S:Data,trace:String,passive:String,result:State.Report<String,String> & Trace.Batch<String>,observed:Existing.Application(~S) & String) -> String:
  match result observed:
    case (status,batch), (_,app):trace ++ "/passive2={" ++ passive ++ "}/report2=" ++ Observe.report(status) ++ "/after2={" ++ app ++ "}/trace=" ++ TraceObserve.batch(batch)
def traced(~S:Data,on:Bool,trace:String,passive:String,app:Existing.Application(~S),status:State.Report<String,String>) -> String:
  match app:
    case App.Scheduled{state,+plan,bindings,deferred}:reported(~S,trace,passive,TraceReport.read(~String,~String,on,plan,status),Observe.application(~S,App.Scheduled{state,plan,bindings,deferred}))
def finished(~S:Data,on:Bool,trace:String,result:Existing.Application(~S) & (State.Report<String,String> & String)) -> String:
  match result:
    case (app,(status,passive)):traced(~S,on,trace,passive,app,status)
def second_observed(~S:Data,+enabled:Bool,trace:String,status:State.Report<String,String>,passive:String,result:Existing.Application(~S) & String) -> String:
  match result:
    case (app,observed):finished(~S,enabled,trace ++ "/passive1={" ++ passive ++ "}/report1=" ++ Observe.report(status) ++ "/after1={" ++ observed ++ "}",run_selected(~S,enabled,app))
def second(~S:Data,enabled:Bool,trace:String,result:Existing.Application(~S) & (State.Report<String,String> & String)) -> String:
  match result:
    case (app,(status,passive)):second_observed(~S,enabled,trace,status,passive,Observe.application(~S,app))
def started(~S:Data,+enabled:Bool,result:Existing.Application(~S) & String) -> String:
  match result:
    case (app,initial):second(~S,enabled,"initial={" ++ initial ++ "}",run_selected(~S,enabled,app))
def other_defined(~S:Data,enabled:Bool,left:Existing.LeftNode(~S),right:Existing.RightNode(~S),result:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<Existing.World(~S),Existing.LeftOwner(~S),Body.LeftLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,other}):started(~S,enabled,Observe.application(~S,Existing.application(~S,world,left,right,Retained.pack(Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Existing.LeftOwner(~S),compilation,other))))
    case (_,Sys.DefinitionRefused{_,_}):"other-refused"
def right_defined(~S:Data,enabled:Bool,left:Existing.LeftNode(~S),result:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)> & Sys.Defined<Existing.World(~S),Existing.RightOwner(~S),Body.RightLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,right}):other_defined(~S,enabled,left,Retained.pack(Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,Existing.RightOwner(~S),compilation,right),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~Existing.left_program(~S),~Body.left(~S),Existing.left_compilation(~S),world,"other",Body.left_local(801,203)))
    case (_,Sys.DefinitionRefused{_,_}):"right-refused"
def left_defined(~S:Data,enabled:Bool,result:Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<Existing.World(~S),Existing.LeftOwner(~S),Body.LeftLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,enabled,Retained.pack(Decl.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Existing.LeftOwner(~S),compilation,left),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~Existing.right_program(~S),~Body.right(~S),Existing.right_compilation(~S),world,"right",Body.right_local()))
    case (_,Sys.DefinitionRefused{_,_}):"left-refused"
def created(~S:Data,enabled:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:left_defined(~S,enabled,Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~Existing.left_program(~S),~Body.left(~S),Existing.left_compilation(~S),world,"left",Body.left_local(501,201)))
    case W.CreateRejected{_,_}:"create-refused"
def run(~S:Data,enabled:Bool) -> String:created(~S,enabled,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
type SchemaA is Data:SchemaA{}
type SchemaB is Data:SchemaB{}
def main() -> IO(Unit):
  IO.print("A=" ++ run(~SchemaA,False{}) ++ "\nA-inspected=" ++ run(~SchemaA,True{}) ++ "\nB=" ++ run(~SchemaB,False{}) ++ "\nB-inspected=" ++ run(~SchemaB,True{}))
