import Base
import ./declarations.bend as D
import ./bodies.bend as Body
import ./observe.bend as Observe
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-effects.bend as Effects
import ../../src/ecs/execution-declaration.bend as Declaration
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/change-tick.bend as Tick

def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def left_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & D.LeftOps(~S,Permit,F)(H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.LeftOps(~S),~D.left(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def right_program(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & D.RightOps(~S,Permit,F)(H):
  Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.RightOps(~S),~D.right(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def left_compilation(~S:Data) -> Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>:
  Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.LeftOps(~S),~left_program(~S))
def right_compilation(~S:Data) -> Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>:
  Build.compile_framework(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.RightOps(~S),~right_program(~S))
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,left_program(~S),Body.left(~S)>
def RightOwner(~S:Data) -> Type:Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,right_program(~S),Body.right(~S)>
def Left(~S:Data) -> Type:Leaf.Node(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~left_program(~S),~Body.left(~S))
def Right(~S:Data) -> Type:Leaf.Node(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~right_program(~S),~Body.right(~S))
def RunResult(~S:Data) -> Type:World(~S) & (Left(~S) & (Right(~S) & (Exec.Invocation<String,String> & Exec.Invocation<String,String>)))
def right_ran(~S:Data,left:Left(~S),leftDone:Exec.Invocation<String,String>,result:Right(~S) & (World(~S) & Exec.Invocation<String,String>)) -> RunResult(~S):
  match result:
    case (right,(world,rightDone)):(world,(left,(right,(leftDone,rightDone))))
def left_ran(~S:Data,right:Right(~S),result:Left(~S) & (World(~S) & Exec.Invocation<String,String>)) -> RunResult(~S):
  match result:
    case (left,(world,leftDone)):right_ran(~S,left,leftDone,Leaf.run(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~right_program(~S),~Body.right(~S),~right_compilation(~S),right,world))
def run_owners(~S:Data,world:World(~S),left:Left(~S),right:Right(~S)) -> RunResult(~S):
  left_ran(~S,right,Leaf.run(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~left_program(~S),~Body.left(~S),~left_compilation(~S),left,world))
def status(value:Exec.Invocation<String,String>) -> String:
  match value:
    case Exec.Completed{out}:"success/" ++ out
    case Exec.BodyError{error,out}:"error/" ++ error ++ "/" ++ out
    case Exec.AdmissionRefused{}:"refused"
def foreign_finished_owners(~S:Data,original:World(~S),trace:String,foreign:World(~S),leftOwner:LeftOwner(~S),rightOwner:RightOwner(~S),left:Exec.Invocation<String,String>,right:Exec.Invocation<String,String>) -> String:
  match leftOwner rightOwner:
    case Sys.Owner{_,_,_,_,lc,ll} Sys.Owner{_,_,_,_,rc,lr}:trace ++ "|foreign=" ++ status(left) ++ "," ++ status(right) ++ "|world=" ++ Observe.world(~S,original) ++ "|locals=" ++ Observe.local(~S,ll) ++ "," ++ Observe.local(~S,lr) ++ "|cursors=" ++ Tick.cursor_show(lc) ++ "," ++ Tick.cursor_show(rc) ++ "|foreign-world=" ++ Observe.world(~S,foreign)
def foreign_finished(~S:Data,original:World(~S),trace:String,result:RunResult(~S)) -> String:
  match result:
    case (foreign,(leftOwner,(rightOwner,(left,right)))):foreign_finished_owners(~S,original,trace,foreign,Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,LeftOwner(~S),leftOwner),Retained.owner(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,RightOwner(~S),rightOwner),left,right)
def foreign_created(~S:Data,original:World(~S),left:Left(~S),right:Right(~S),trace:String,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{_,world}:foreign_finished(~S,original,trace,run_owners(~S,world,left,right))
    case W.CreateRejected{_,_}:"ERROR:create foreign"
def third(~S:Data,factory:W.Factory,trace:String,result:RunResult(~S)) -> String:
  match result:
    case (world,(left,(right,(lo,ro)))):foreign_created(~S,world,left,right,trace ++ "|" ++ status(lo) ++ "," ++ status(ro),W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),factory,D.resources(~S)))
def second(~S:Data,factory:W.Factory,trace:String,result:RunResult(~S)) -> String:
  match result:
    case (world,(left,(right,(lo,ro)))):third(~S,factory,trace ++ "|" ++ status(lo) ++ "," ++ status(ro),run_owners(~S,world,left,right))
def first(~S:Data,factory:W.Factory,result:RunResult(~S)) -> String:
  match result:
    case (world,(left,(right,(lo,ro)))):second(~S,factory,status(lo) ++ "," ++ status(ro),run_owners(~S,world,left,right))
def right_defined(~S:Data,factory:W.Factory,left:Left(~S),result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)> & Sys.Defined<World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,right_program(~S),Body.right(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,right}):first(~S,factory,run_owners(~S,world,left,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.RightOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.RightOps(~S),Body.Local<S>,String,String,right_program(~S),Body.right(~S)>,compilation,right)))
    case _:"ERROR:right define"
def left_defined(~S:Data,factory:W.Factory,+handle:W.Handle<S>,result:Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)> & Sys.Defined<World(~S),Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,left_program(~S),Body.left(~S)>,Body.Local<S>>) -> String:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,factory,Retained.pack(Declaration.Compilation<S,D.Store(~S),D.Store(~S),D.Resources(~S),D.LeftOps(~S)>,Sys.Owner<S,D.Store(~S),D.Store(~S),D.Resources(~S),Unit,D.LeftOps(~S),Body.Local<S>,String,String,left_program(~S),Body.left(~S)>,compilation,left),Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.RightOps(~S),~Body.Local<S>,~String,~String,~right_program(~S),~Body.right(~S),right_compilation(~S),world,"right",Body.Local{ALeaf{601},0,handle}))
    case _:"ERROR:left define"
def ready(~S:Data,factory:W.Factory,result:World(~S) & W.Handle<S>) -> String:
  match result:
    case (world,+handle):left_defined(~S,factory,handle,Leaf.define_with_compilation(~S,~D.components_layout(),~D.resources_layout(),~Unit,~D.LeftOps(~S),~Body.Local<S>,~String,~String,~left_program(~S),~Body.left(~S),left_compilation(~S),world,"left",Body.Local{ALeaf{501},0,handle}))
def more_activated(~S:Data,first:W.Handle<S>,result:World(~S) & W.Status) -> World(~S) & W.Handle<S>:
  match result:
    case (world,_):(world,first)
def more_reserved(~S:Data,first:W.Handle<S>,result:World(~S) & W.Reservation<S>) -> World(~S) & W.Handle<S>:
  match result:
    case (world,W.Reserved{handle}):more_activated(~S,first,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):(world,first)
def spawn_more(~S:Data,fuel:Nat,result:World(~S) & W.Handle<S>) -> World(~S) & W.Handle<S>:
  match fuel result:
    case 0n result:result
    case 1n++rest, (world,first):spawn_more(~S,rest,more_reserved(~S,first,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world)))
def activated(~S:Data,factory:W.Factory,first:W.Handle<S>,result:World(~S) & W.Status) -> String:
  match result:
    case (world,W.Accepted{}):ready(~S,factory,spawn_more(~S,16n,(world,first)))
    case _:"ERROR:activate"
def reserved(~S:Data,factory:W.Factory,result:World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):activated(~S,factory,handle,W.activate(~S,~D.Store(~S),~D.Resources(~S),~Unit,world,handle))
    case _:"ERROR:reserve"
def created(~S:Data,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> String:
  match result:
    case W.Created{factory,world}:reserved(~S,factory,W.reserve_id(~S,~D.Store(~S),~D.Resources(~S),~Unit,world))
    case W.CreateRejected{_,_}:"ERROR:create"
def run(~S:Data) -> String:
  created(~S,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resources(~S)))
