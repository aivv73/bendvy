import Base
import ./actor.bend as Actor
import ./setup.bend as Scene
import ./retained-failure-reader.bend as Reader
import ./failure-reader.bend as Existing
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Root
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-relation-context.bend as Context
import ../../src/ecs/execution-relation-store.bend as Store
import ../../src/ecs/execution-relation-failure-retention.bend as Retention
import ../../src/ecs/execution-relation-failure-root-completion.bend as Completion
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec

def Resources() -> Type:L.resources(~Reader.Schema,Actor.resources(~Reader.Schema))
def World() -> Type:W.World<Reader.Schema,Reader.WC(),Resources(),Unit>
def Nodes() -> Type:Reg.Product<Reader.Node(),Reader.Node()>
type Handler is Type:
  Handler{factory:W.Factory,receipts:List<&2,Store.Receipt<Reader.Schema>>}
def State() -> Type:App.State<World(),Nodes(),Unit,Handler>
def Scheduled() -> Type:Root.Scheduled<State()>
def Application() -> Type:Context.Bound<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==},Scheduled()>
def leaf_dispatch() -> Reader.Node() -> World() -> U32 -> Reader.Node() & (World() & Exec.Invocation<String,String>):Leaf.dispatch(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Existing.Ops(~Reader.Schema),~Reader.Local(),~String,~String,~Existing.kernel(~Reader.Schema),~Existing.body(~Reader.Schema),~Existing.compilation(~Reader.Schema))
def dispatch() -> Nodes() -> World() -> U32 -> Nodes() & (World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(),~Reader.Node(),~Reader.Node(),~String,~String,~leaf_dispatch(),~leaf_dispatch())
def publish(_:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(handler:Handler,_:String) -> Handler & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def catalogue() -> Retention.Catalogue<Reader.Schema,Actor.resources(~Reader.Schema)>:
  Retention.add(~Reader.Schema,~Actor.resources(~Reader.Schema),~Actor.route(),~{==},~Scene.hierarchy(~Reader.Schema),~{==},~{==},~{==},Retention.none(~Reader.Schema,~Actor.resources(~Reader.Schema)))
type Run is Type:
  Returned{app:Application(),report:Context.RunReport<App.Report<String,String>>}
  CatalogueRefused{app:Application(),catalogue:Retention.Catalogue<Reader.Schema,Actor.resources(~Reader.Schema)>}
def returned(result:Application() & Context.RunReport<App.Report<String,String>>) -> Run:
  match result:
    case (app,report):Returned{app,report}
def admitted(app:Application(),admission:Retention.Admission<Reader.Schema,Actor.resources(~Reader.Schema)>) -> Run:
  match admission:
    case Retention.Refused{catalogue}:CatalogueRefused{app,catalogue}
    case Retention.Accepted{program}:returned(General.run_bound_with_completion(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,~dispatch(),~Reg.empty_dispatch(~World(),~String,~Bool),~handle,~publish,Completion.completed(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,program),app))
def run(app:Application()) -> Run:admitted(app,Retention.prepare(~Reader.Schema,~Actor.resources(~Reader.Schema),catalogue()))
def Binding() -> Type:Reader.Node()
type Definition is Type:
  DefinitionReady{app:Application()}
  FirstRefused{context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,compilation:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Existing.Ops(~Reader.Schema)>,first:Reader.Local(),second:Reader.Local()}
  SecondRefused{context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,first:Binding(),compilation:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Existing.Ops(~Reader.Schema)>,local:Reader.Local()}
def facts(node:Reader.Node()) -> Registry.Facts<Reg.Registry<World(),Reader.Node(),String,String,leaf_dispatch()>>:Registry.ordinary(~World(),~Reader.Node(),~String,~String,~leaf_dispatch(),Leaf.facts(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Existing.Ops(~Reader.Schema),~Reader.Local(),~String,~String,~Existing.kernel(~Reader.Schema),~Existing.body(~Reader.Schema),~Existing.compilation(~Reader.Schema),node))
def built(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,left:Binding(),right:Binding()) -> Definition:
  DefinitionReady{Context.Bound{context,General.build(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Nodes(),~Unit,~Handler,~String,~String,~dispatch(),~Reg.empty_dispatch(~World(),~String,~Bool),~available,world,Registry.paired(~World(),~Reader.Node(),~Reader.Node(),~String,~String,~leaf_dispatch(),~leaf_dispatch(),facts(left),facts(right)),Reg.empty_conditions(~World(),~String),handler,[],[])}}
def second_defined(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,handler:Handler,first:Binding(),result:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Existing.Ops(~Reader.Schema)> & Sys.Defined<World(),Reader.Owner(),Reader.Local()>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):built(context,world,handler,first,Retained.pack(Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Existing.Ops(~Reader.Schema)>,Reader.Owner(),compilation,owner))
    case (compilation,Sys.DefinitionRefused{world,local}):SecondRefused{context,world,handler,first,compilation,local}
def first_defined(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,handler:Handler,second:Reader.Local(),result:Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Existing.Ops(~Reader.Schema)> & Sys.Defined<World(),Reader.Owner(),Reader.Local()>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):second_defined(context,handler,Retained.pack(Decl.Compilation<Reader.Schema,Reader.WC(),Reader.C(),Reader.R(),Existing.Ops(~Reader.Schema)>,Reader.Owner(),compilation,owner),Leaf.define_with_compilation(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Existing.Ops(~Reader.Schema),~Reader.Local(),~String,~String,~Existing.kernel(~Reader.Schema),~Existing.body(~Reader.Schema),Existing.compilation(~Reader.Schema),world,"sparse-reader-right",second))
    case (compilation,Sys.DefinitionRefused{world,first}):FirstRefused{context,world,handler,compilation,first,second}
def define(context:Context.Context<Reader.Schema,Resources(),Actor.resources(~Reader.Schema),{==}>,world:World(),handler:Handler,first:Reader.Local(),second:Reader.Local()) -> Definition:
  first_defined(context,handler,second,Leaf.define_with_compilation(~Reader.Schema,~Actor.components(),~Actor.resources(~Reader.Schema),~Unit,~Existing.Ops(~Reader.Schema),~Reader.Local(),~String,~String,~Existing.kernel(~Reader.Schema),~Existing.body(~Reader.Schema),Existing.compilation(~Reader.Schema),world,"sparse-reader-left",first))
