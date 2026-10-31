import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ./application.bend as Ordinary
import ./overlap.bend as Overlap
import ./scheduled.bend as Common
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/dependency-application.bend as DepApp
def refused(~S:Data,original:String,result:Overlap.Application(~S) & DepApp.Report<String,String>) -> String:
  match result:
    case (app,status):original ++ "|foreign=" ++ Overlap.observed(~S,Overlap.report(status),app)
def foreign_created(~S:Data,original:Ordinary.World(~S),left:Ordinary.Left(~S),right:Ordinary.Right(~S),other:Ordinary.Left(~S),result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:refused(~S,"original=" ++ Observe.world(~S,original),Overlap.run_application(~S,Overlap.application(~S,world,left,right,other)))
    case _:"ERROR:foreign"
def other_defined(~S:Data,factory:W.Factory,left:Ordinary.Left(~S),right:Ordinary.Right(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<Ordinary.World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,other}):foreign_created(~S,world,left,right,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,compilation,other),W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resources(~S)))
    case _:"ERROR:other"
def right_defined(~S:Data,factory:W.Factory,+handle:W.Handle<S>,left:Ordinary.Left(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)> & Sys.Defined<Ordinary.World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,Ordinary.right_program(~S),Body.right(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,right}):other_defined(~S,factory,left,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,Ordinary.right_program(~S),Body.right(~S)>,compilation,right),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~Ordinary.left_program(~S),~Body.left(~S),Ordinary.left_compilation(~S),world,"other",Body.Local{ALeaf{801},0,handle}))
    case _:"ERROR:right"
def left_defined(~S:Data,factory:W.Factory,+handle:W.Handle<S>,result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<Ordinary.World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,factory,handle,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,Ordinary.left_program(~S),Body.left(~S)>,compilation,left),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~Ordinary.right_program(~S),~Body.right(~S),Ordinary.right_compilation(~S),world,"right",Body.Local{ALeaf{601},0,handle}))
    case _:"ERROR:left"
def activated(~S:Data,factory:W.Factory,+handle:W.Handle<S>,result:Ordinary.World(~S) & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):left_defined(~S,factory,handle,Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~Ordinary.left_program(~S),~Body.left(~S),Ordinary.left_compilation(~S),world,"left",Body.Local{ALeaf{501},0,handle}))
    case _:"ERROR:activate"
def reserved(~S:Data,factory:W.Factory,result:Ordinary.World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,factory,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case _:"ERROR:reserve"
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{factory,world}:reserved(~S,factory,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case _:"ERROR:create"
def run(~S:Data) -> String:created(~S,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
def main() -> IO(Unit):IO.print("A=" ++ run(~Common.SchemaA) ++ "\nB=" ++ run(~Common.SchemaB))
