import Base
import ./schema.bend as S
import ./body.bend as B
import ./audit.bend as Audit
import ./payload.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-schedule.bend as Root
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan

def Nodes() -> Type:Reg.Product<Audit.Node(),B.Node()>
def State() -> Type:App.State<S.World(~S.Workshop),Nodes(),Unit,Unit>
def Application() -> Type:Root.Scheduled<State()>
def audit_dispatch() -> Audit.Node() -> S.World(~S.Workshop) -> U32 -> Audit.Node() & (S.World(~S.Workshop) & Exec.Invocation<B.Error,String>):
  Leaf.dispatch(~S.Workshop,~S.components(),~S.resources(),~Unit,~Audit.Ops,~Unit,~B.Error,~String,~Audit.kernel,~Audit.body,~Audit.compiled())
def query_dispatch() -> B.Node() -> S.World(~S.Workshop) -> U32 -> B.Node() & (S.World(~S.Workshop) & Exec.Invocation<B.Error,String>):
  Leaf.dispatch(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Ops,~B.Local,~B.Error,~String,~B.kernel,~B.body,~B.compiled())
def dispatch() -> Nodes() -> S.World(~S.Workshop) -> U32 -> Nodes() & (S.World(~S.Workshop) & Exec.Invocation<B.Error,String>):
  Reg.paired_dispatch(~S.World(~S.Workshop),~Audit.Node(),~B.Node(),~B.Error,~String,~audit_dispatch(),~query_dispatch())
def publish(ids:List<&2,U32>,world:S.World(~S.Workshop),nodes:Nodes()) -> S.World(~S.Workshop) & (Nodes() & List<&2,U32>):(world,(nodes,ids))
def handle(handler:Unit,_:B.Error) -> Unit & Exec.Handling:(handler,Exec.Continue{})
def available(_:String) -> Bool:True{}
def run(app:Application()) -> Application() & App.Report<B.Error,String>:General.run(~S.Workshop,~S.components(),~S.resources(),~Unit,~Nodes(),~Unit,~Unit,~B.Error,~String,~dispatch(),~Reg.empty_dispatch(~S.World(~S.Workshop),~B.Error,~Bool),~handle,~publish,app)
def AuditBinding() -> Type:Audit.Node()
def QueryBinding() -> Type:B.Node()
type Definition is Type:
  DefinitionReady{app:Application()}
  AuditRefused{world:S.World(~S.Workshop),compilation:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,local:Unit}
  QueryRefused{world:S.World(~S.Workshop),audit:AuditBinding(),compilation:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,local:B.Local}
def audit_facts(node:Audit.Node()) -> Registry.Facts<Reg.Registry<S.World(~S.Workshop),Audit.Node(),B.Error,String,audit_dispatch()>>:
  Registry.ordinary(~S.World(~S.Workshop),~Audit.Node(),~B.Error,~String,~audit_dispatch(),Leaf.facts(~S.Workshop,~S.components(),~S.resources(),~Unit,~Audit.Ops,~Unit,~B.Error,~String,~Audit.kernel,~Audit.body,~Audit.compiled(),node))
def query_facts(node:B.Node()) -> Registry.Facts<Reg.Registry<S.World(~S.Workshop),B.Node(),B.Error,String,query_dispatch()>>:
  Registry.ordinary(~S.World(~S.Workshop),~B.Node(),~B.Error,~String,~query_dispatch(),Leaf.facts(~S.Workshop,~S.components(),~S.resources(),~Unit,~B.Ops,~B.Local,~B.Error,~String,~B.kernel,~B.body,~B.compiled(),node))
def built_unpacked(world:S.World(~S.Workshop),left:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops> & Audit.Owner(),right:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops> & B.Owner()) -> Definition:
  match left right:
    case (ac,Sys.Owner{an,+aid,at,aa,ar,al}) (bc,Sys.Owner{bn,+bid,bt,ba,br,bl}):DefinitionReady{General.build(~S.Workshop,~S.components(),~S.resources(),~Unit,~Nodes(),~Unit,~Unit,~B.Error,~String,~dispatch(),~Reg.empty_dispatch(~S.World(~S.Workshop),~B.Error,~Bool),~available,world,Registry.paired(~S.World(~S.Workshop),~Audit.Node(),~B.Node(),~B.Error,~String,~audit_dispatch(),~query_dispatch(),audit_facts(Retained.pack(Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,Audit.Owner(),ac,Sys.Owner{an,aid,at,aa,ar,al})),query_facts(Retained.pack(Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,B.Owner(),bc,Sys.Owner{bn,bid,bt,ba,br,bl}))),Reg.empty_conditions(~S.World(~S.Workshop),~B.Error),Unit{},[Plan.Edge{aid,bid}],[])}
def built(world:S.World(~S.Workshop),left:AuditBinding(),right:QueryBinding()) -> Definition:
  built_unpacked(world,Retained.unpack(Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,Audit.Owner(),left),Retained.unpack(Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,B.Owner(),right))
def query_defined(audit:AuditBinding(),result:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops> & Sys.Defined<S.World(~S.Workshop),B.Owner(),B.Local>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):built(world,audit,Retained.pack(Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),B.Ops>,B.Owner(),compilation,owner))
    case (compilation,Sys.DefinitionRefused{world,local}):QueryRefused{world,audit,compilation,local}
def audit_defined(result:Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops> & Sys.Defined<S.World(~S.Workshop),Audit.Owner(),Unit>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,owner}):query_defined(Retained.pack(Decl.Compilation<S.Workshop,S.Store(~S.Workshop),B.C(),B.R(),Audit.Ops>,Audit.Owner(),compilation,owner),Register.define_with_compilation(~S.Workshop,~S.Store(~S.Workshop),~B.C(),~B.R(),~Unit,~B.Ops,~B.Local,~B.Error,~String,~B.kernel,~B.body,~Unit,B.compiled(),world,"captured-query",B.Local{P.initial(1),B.Args{1},[],[]}))
    case (compilation,Sys.DefinitionRefused{world,local}):AuditRefused{world,compilation,local}
def define(world:S.World(~S.Workshop)) -> Definition:audit_defined(Register.define_with_compilation(~S.Workshop,~S.Store(~S.Workshop),~B.C(),~B.R(),~Unit,~Audit.Ops,~Unit,~B.Error,~String,~Audit.kernel,~Audit.body,~Unit,Audit.compiled(),world,"audit",Unit{}))
