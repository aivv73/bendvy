import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./scheduled.bend as Existing
import ./failure-scheduled.bend as Scheduled
import ./failure-reader.bend as Reader
import ../../src/ecs/execution-relation-failure-registration.bend as Registration
import ../../src/ecs/execution-relation-failure-local.bend as Local
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-world-publication.bend as Publication
import ../../src/ecs/execution-schedule.bend as Root
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

type Definition<-S:Data> is Type:
  DefinitionReady{bound:Scheduled.Bound(~S)}
  RegistrationRefused{context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,world:Existing.World(~S),actor:Actor.Node(~S),peer:Existing.PeerNode(~S),user:Reader.User<S>}
  DefinitionRefused{context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,world:Existing.World(~S),actor:Actor.Node(~S),peer:Existing.PeerNode(~S),local:Reader.State(~S)}
def defined(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,actor:Actor.Node(~S),peer:Existing.PeerNode(~S),result:Decl.Compilation<S,Actor.C(~S),Actor.C(~S),Actor.R(~S),Reader.Ops(~S)> & Sys.Defined<Existing.World(~S),Reader.Owner(~S),Reader.State(~S)>) -> Definition<S>:
  match result:
    case (compilation,Sys.Defined{world,reader}):DefinitionReady{Scheduled.build(~S,context,world,actor,Retained.pack(Decl.Compilation<S,Actor.C(~S),Actor.C(~S),Actor.R(~S),Reader.Ops(~S)>,Reader.Owner(~S),compilation,reader),peer)}
    case (_,Sys.DefinitionRefused{world,local}):DefinitionRefused{context,world,actor,peer,local}
def registered(~S:Data,context:Context.Context<S,Existing.Resources(~S),Actor.resources(~S),{==}>,actor:Actor.Node(~S),peer:Existing.PeerNode(~S),user:Reader.User<S>,frame:Publication.Frame<S,Existing.Columns(~S),Existing.Resources(~S),Unit>,allocator:Allocator.Allocator,result:Registration.Registration<S,Actor.resources(~S),Actor.route(),Scene.hierarchy(~S)>) -> Definition<S>:
  match frame result:
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle} Registration.Refused{resources}:RegistrationRefused{context,W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},actor,peer,user}
    case Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle} Registration.Registered{resources,reader}:defined(~S,context,actor,peer,Leaf.define_with_compilation(~S,~Actor.components(),~Actor.resources(~S),~Unit,~Reader.Ops(~S),~Reader.State(~S),~String,~String,~Reader.kernel(~S),~Reader.body(~S),Reader.compilation(~S),W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},"scene failure reader",Local.Local{reader,user}))
def attach(~S:Data,bound:Existing.Bound(~S),user:Reader.User<S>) -> Definition<S>:
  match bound:
    case Context.Bound{context,Root.Scheduled{App.State{W.World{namespace,allocator,columns,resources,events,pending,registrations,nextSystem,clock,lifecycle},Reg.Product{actor,peer,_},_,_,_},_,_,_}}:registered(~S,context,actor,peer,user,Publication.Frame{namespace,columns,events,pending,registrations,nextSystem,clock,lifecycle},allocator,Registration.register(~S,~Actor.resources(~S),~Actor.route(),~{==},~Scene.hierarchy(~S),~{==},~{==},~{==},resources))
