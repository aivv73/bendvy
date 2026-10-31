import Base
import ./execution.bend as Execution
import ./receiver.bend as Receiver
import ./scheduled.bend as Persistence
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Decl
import ./declarations.bend as Ordinary
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/entity-allocator.bend as A
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/deferred-command.bend as Deferred
import ../../src/ecs/world.bend as W

type Defined<-S:Data> is Type:
  Defined{app:Execution.Application(~S)}
  ReaderRefused{world:Receiver.World(~S),reason:Notice.Refusal}
  LeftRefused{world:Receiver.World(~S),local:Execution.Local,reader:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>}
  RightRefused{world:Receiver.World(~S),left:Execution.Left(~S),local:Execution.ReaderLocal<S>}
def right_defined(~S:Data,left:Execution.Left(~S),result:Decl.Compilation<S,Execution.Columns(~S),Execution.Columns(~S),Receiver.Resources(~S),Execution.RightOps(~S)> & Sys.Defined<Receiver.World(~S),Execution.RightOwner(~S),Execution.ReaderLocal<S>>) -> Defined<S>:
  match result:
    case (compilation,Sys.Defined{world,right}):Defined{Execution.build(~S,world,left,Retained.pack(Decl.Compilation<S,Execution.Columns(~S),Execution.Columns(~S),Receiver.Resources(~S),Execution.RightOps(~S)>,Execution.RightOwner(~S),compilation,right),Execution.Handler{ALeaf{303},0})}
    case (_,Sys.DefinitionRefused{world,local}):RightRefused{world,left,local}
def left_defined(~S:Data,reader:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>,result:Decl.Compilation<S,Execution.Columns(~S),Execution.Columns(~S),Receiver.Resources(~S),Execution.LeftOps(~S)> & Sys.Defined<Receiver.World(~S),Execution.LeftOwner(~S),Execution.Local>) -> Defined<S>:
  match result:
    case (compilation,Sys.Defined{world,left}):right_defined(~S,Retained.pack(Decl.Compilation<S,Execution.Columns(~S),Execution.Columns(~S),Receiver.Resources(~S),Execution.LeftOps(~S)>,Execution.LeftOwner(~S),compilation,left),Leaf.define_with_compilation(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~Execution.RightOps(~S),~Execution.ReaderLocal<S>,~String,~String,~Execution.right_program(~S),~Execution.right_body(~S),Execution.right_compilation(~S),world,"transient-resource",Execution.ReaderLocal{ALeaf{202},0,reader,0}))
    case (_,Sys.DefinitionRefused{world,local}):LeftRefused{world,local,reader}
def define(~S:Data,world:Receiver.World(~S),reader:Notice.Reader<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> Defined<S>:
  left_defined(~S,reader,Leaf.define_with_compilation(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,~Execution.LeftOps(~S),~Execution.Local,~String,~String,~Execution.left_program(~S),~Execution.left_body(~S),Execution.left_compilation(~S),world,"persisted-config",Execution.Local{ALeaf{101},0}))
def registered(~S:Data,namespace:U32,allocator:A.Allocator,store:Layout.columns(~S,Receiver.Components(~S)),resource:Receiver.Resources(~S),events:List<&2,Unit>,pending:List<Deferred.Command<Receiver.World(~S)>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,result:Notice.Journal<S> & Notice.Registration<S,Layout.EmptyLayout{},Notice.Despawned{}>) -> Defined<S>:
  match result:
    case (journal,Notice.Registered{reader}):define(~S,W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},reader)
    case (journal,Notice.RegistrationRefused{reason}):ReaderRefused{W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal},reason}
# Trusted ordinary bootstrap registers an actual reader and both actual system
# owners. Refusal retains the World and every owner created before that point.
def setup(~S:Data,world:Receiver.World(~S)) -> Defined<S>:
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,journal}:registered(~S,namespace,allocator,store,resource,events,pending,registrations,nextSystemId,clock,Notice.register(~S,~Layout.EmptyLayout{},~Notice.Despawned{},Notice.Retained{},journal))
