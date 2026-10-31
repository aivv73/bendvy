import Base
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/execution-effects.bend as Effects
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./reports.bend as Common
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-application.bend as DepApp
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick

def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def left_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & D.LeftOps(~S,Permit,F,H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.LeftOps(~S),~D.left(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def right_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & D.RightOps(~S,Permit,F,H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.RightOps(~S),~D.right(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def left_compilation(~S:Data) -> Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>:
  Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.LeftOps(~S),~left_program(~S))
def right_compilation(~S:Data) -> Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>:
  Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.RightOps(~S),~right_program(~S))
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.LeftLocal(),String,String,left_program(~S),Body.left(~S)>
def RightOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.RightLocal(),String,String,right_program(~S),Body.right(~S)>
def LeftNode(~S:Data) -> Type:Leaf.Node(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~left_program(~S),~Body.left(~S))
def RightNode(~S:Data) -> Type:Leaf.Node(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~right_program(~S),~Body.right(~S))
def RightNodes(~S:Data) -> Type:Reg.Product<RightNode(~S),LeftNode(~S)>
def Nodes(~S:Data) -> Type:Reg.Product<LeftNode(~S),RightNodes(~S)>
def left_dispatch(~S:Data) -> LeftNode(~S) -> World(~S) -> U32 -> LeftNode(~S) & (World(~S) & Exec.Invocation<String,String>):
  Leaf.dispatch(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~left_program(~S),~Body.left(~S),~left_compilation(~S))
def right_dispatch(~S:Data) -> RightNode(~S) -> World(~S) -> U32 -> RightNode(~S) & (World(~S) & Exec.Invocation<String,String>):
  Leaf.dispatch(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~right_program(~S),~Body.right(~S),~right_compilation(~S))
def rights_dispatch(~S:Data) -> RightNodes(~S) -> World(~S) -> U32 -> RightNodes(~S) & (World(~S) & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~World(~S),~RightNode(~S),~LeftNode(~S),~String,~String,~right_dispatch(~S),~left_dispatch(~S))
def dispatch(~S:Data) -> Nodes(~S) -> World(~S) -> U32 -> Nodes(~S) & (World(~S) & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~World(~S),~LeftNode(~S),~RightNodes(~S),~String,~String,~left_dispatch(~S),~rights_dispatch(~S))
def Application(~S:Data) -> Type:Schedule.Scheduled<DepApp.State<World(~S),Nodes(~S),Unit,Common.Handler>>
def left_facts(~S:Data,node:LeftNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),LeftNode(~S),String,String,left_dispatch(~S)>>:
  Registry.ordinary(~World(~S),~LeftNode(~S),~String,~String,~left_dispatch(~S),Leaf.facts(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~left_program(~S),~Body.left(~S),~left_compilation(~S),node))
def right_facts(~S:Data,node:RightNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),RightNode(~S),String,String,right_dispatch(~S)>>:
  Registry.ordinary(~World(~S),~RightNode(~S),~String,~String,~right_dispatch(~S),Leaf.facts(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~right_program(~S),~Body.right(~S),~right_compilation(~S),node))
def publish(~S:Data,ids:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):
  (world,(nodes,ids))
def run_application(~S:Data,app:Application(~S)) -> Application(~S) & DepApp.Report<String,String>:
  General.run(~S,~D.components_layout(),~D.resources_layout(),~Unit,~Nodes(~S),~Unit,~Common.Handler,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~World(~S),~String,~Bool),~Common.handle,~publish(~S),app)
def observed_values(~S:Data,trace:String,world:World(~S),left:LeftOwner(~S),right:RightOwner(~S),other:LeftOwner(~S),handler:Common.Handler) -> String:
  match left right other:
    case Sys.Owner{_,_,_,_,lc,ll} Sys.Owner{_,_,_,_,rc,rl} Sys.Owner{_,_,_,_,oc,ol}:trace ++ "|world=" ++ Observe.world(~S,world) ++ "|locals=" ++ Body.observe_left(ll) ++ "," ++ Body.observe_right(rl) ++ "," ++ Body.observe_left(ol) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "," ++ Tick.cursor_show(oc) ++ "|handler=" ++ Common.handler(handler)
def observed(~S:Data,trace:String,app:Application(~S)) -> String:
  match app:
    case Schedule.Scheduled{DepApp.State{world,Reg.Product{left,Reg.Product{right,other,_},_},_,handler,_},_,_,_}:observed_values(~S,trace,world,Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,LeftOwner(~S),left),Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,RightOwner(~S),right),Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,LeftOwner(~S),other),handler)
def third(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):observed(~S,trace ++ "|" ++ Common.report(status),app)
def second(~S:Data,trace:String,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):third(~S,trace ++ "|" ++ Common.report(status),run_application(~S,app))
def first(~S:Data,result:Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):second(~S,Common.report(status),run_application(~S,app))
def application(~S:Data,world:World(~S),left:LeftNode(~S),right:RightNode(~S),other:LeftNode(~S)) -> Application(~S):
  General.build(~S,~D.components_layout(),~D.resources_layout(),~Unit,~Nodes(~S),~Unit,~Common.Handler,~String,~String,~dispatch(~S),~Reg.empty_dispatch(~World(~S),~String,~Bool),~Common.available,world,Registry.paired(~World(~S),~LeftNode(~S),~RightNodes(~S),~String,~String,~left_dispatch(~S),~rights_dispatch(~S),left_facts(~S,left),Registry.paired(~World(~S),~RightNode(~S),~LeftNode(~S),~String,~String,~right_dispatch(~S),~left_dispatch(~S),right_facts(~S,right),left_facts(~S,other))),Reg.empty_conditions(~World(~S),~String),Common.Handler{ALeaf{701},0},[],[])
def built(~S:Data,world:World(~S),left:LeftNode(~S),right:RightNode(~S),other:LeftNode(~S)) -> String:
  first(~S,run_application(~S,application(~S,world,left,right,other)))
def other_defined(~S:Data,left:LeftNode(~S),right:RightNode(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<World(~S),LeftOwner(~S),Body.LeftLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,other}):built(~S,world,left,right,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,LeftOwner(~S),compilation,other))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:other"
def right_defined(~S:Data,left:LeftNode(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)> & Sys.Defined<World(~S),RightOwner(~S),Body.RightLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,right}):other_defined(~S,left,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,RightOwner(~S),compilation,right),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~left_program(~S),~Body.left(~S),left_compilation(~S),world,"other",Body.left_local(801,203)))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:right"
def left_defined(~S:Data,result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<World(~S),LeftOwner(~S),Body.LeftLocal()>) -> String:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,LeftOwner(~S),compilation,left),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.RightLocal(),~String,~String,~right_program(~S),~Body.right(~S),right_compilation(~S),world,"right",Body.right_local()))
    case (_,Sys.DefinitionRefused{_,_}):"ERROR:left"
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:left_defined(~S,Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.LeftLocal(),~String,~String,~left_program(~S),~Body.left(~S),left_compilation(~S),world,"left",Body.left_local(501,201)))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data) -> IO(String):
  IO.pure(String,created(~S,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S))))
type SchemaA is Data:
  SchemaA{}
type SchemaB is Data:
  SchemaB{}
def main() -> IO(Unit):
  IO.bind(String,Unit,run(~SchemaA),a => IO.bind(String,Unit,run(~SchemaB),b => IO.print("A=" ++ a ++ "\nB=" ++ b)))
