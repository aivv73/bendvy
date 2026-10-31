import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as Resource
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-retained-system.bend as Scope
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf

def Columns() -> Type:Author.Columns()
def C() -> Type:L.columns(~P.AuditWorkshop,D.components())
def R() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
def World() -> Type:W.World<P.AuditWorkshop,Columns(),L.resources(~P.AuditWorkshop,Author.resources()),Unit>
def WriterOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Resource.Writer<H,Array<U32>,List<&2,U32>>
def ReaderOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Resource.Reader<H,List<&2,U32>>
def QueryOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Q.GeneralWriter<P.AuditWorkshop,H,U32,U32>
def any(_:Maybe<&2,U32>) -> Bool:True{}
def writer_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Columns(),~C(),~R(),~F,~H,~B),~life:Build.Lifecycle(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),book:B) -> B & WriterOps(Permit,F,H):
  Build.general_resource_write(~P.AuditWorkshop,~C(),~R(),~H,~B,~Author.resources(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~rw,book)
def reader_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Columns(),~C(),~R(),~F,~H,~B),~life:Build.Lifecycle(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),book:B) -> B & ReaderOps(Permit,F,H):
  Build.general_resource_read(~P.AuditWorkshop,~C(),~R(),~H,~B,~Author.resources(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~rr,book)
def query_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Columns(),~C(),~R(),~F,~H,~B),~life:Build.Lifecycle(~P.AuditWorkshop,~Columns(),~C(),~R(),~H,~B),book:B) -> B & QueryOps(Permit,F,H):
  Build.general_query(~P.AuditWorkshop,~Columns(),~C(),~R(),~F,~D.components(),~L.InRight{L.AtLeaf{}},~{==},~{==},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~q,book)
def writer_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & WriterOps(Permit,F,H):builder(WriterOps,writer_selection(~Permit,~F,~H,~B),book)
def reader_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & ReaderOps(Permit,F,H):builder(ReaderOps,reader_selection(~Permit,~F,~H,~B),book)
def query_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & QueryOps(Permit,F,H):builder(QueryOps,query_selection(~Permit,~F,~H,~B),book)
def writer_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<P.AuditWorkshop>),~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & WriterOps(Permit,F,H):Build.framework_program(~P.AuditWorkshop,~Columns(),~C(),~R(),~WriterOps,~writer_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def reader_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<P.AuditWorkshop>),~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & ReaderOps(Permit,F,H):Build.framework_program(~P.AuditWorkshop,~Columns(),~C(),~R(),~ReaderOps,~reader_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def query_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<P.AuditWorkshop>),~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & QueryOps(Permit,F,H):Build.framework_program(~P.AuditWorkshop,~Columns(),~C(),~R(),~QueryOps,~query_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)

type WriterLocal is Type:WriterLocal{returned:List<Array<U32>>,unused:List<(Array<U32> -> Array<U32> & Array<U32>)>}
def counter(owner:Array<U32>) -> Array<U32> & Array<U32>:(P.next_counter(),owner)
def written(~Permit:Data,~F:(Type -> Type),~H:Type,returned:List<Array<U32>>,unused:List<(Array<U32> -> Array<U32> & Array<U32>)>,result:H & ResourceStore.Edit<Array<U32>,Array<U32>>) -> H & (WriterLocal & Sys.Completion<String,String>):
  match result:
    case (scope,ResourceStore.Edited{output}):(scope,(WriterLocal{List.append(&1,Array<U32>,returned,[output]),unused},Sys.Success{"Counter=[21,22]"}))
    case (scope,ResourceStore.Unchanged{operation}):(scope,(WriterLocal{returned,operation <> unused},Sys.BodyError{"counter replacement refused","operation retained"}))
def writer_caps(~Permit:Data,~F:(Type -> Type),~H:Type,caps:WriterOps(Permit,F,H),scope:H,local:WriterLocal) -> H & (WriterLocal & Sys.Completion<String,String>):
  match caps local:
    case Resource.Writer{_,own,_} WriterLocal{returned,unused}:written(~Permit,~F,~H,returned,unused,own(Array<U32>,scope,counter))
    case _ local:(scope,(local,Sys.BodyError{"counter unsupported","local retained"}))
def writer_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:WriterOps(Permit,F,H),scope:H,local:WriterLocal) -> F(H & (WriterLocal & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (WriterLocal & Sys.Completion<String,String>)),effects,writer_caps(~Permit,~F,~H,caps,scope,local))
def read_resource(~Permit:Data,~F:(Type -> Type),~H:Type,capture:Array<U32>,result:H & ResourceStore.Lookup<List<&2,U32>>) -> H & (Array<U32> & Sys.Completion<String,String>):
  match result:
    case (scope,ResourceStore.Viewed{view,_}):(scope,(P.increment(U32.add(1,D.sum(view)),capture),Sys.Success{"Counter read"}))
    case (scope,ResourceStore.LookupRefused{}):(scope,(capture,Sys.BodyError{"Counter read refused","capture retained"}))
def reader_caps(~Permit:Data,~F:(Type -> Type),~H:Type,caps:ReaderOps(Permit,F,H),scope:H,capture:Array<U32>) -> H & (Array<U32> & Sys.Completion<String,String>):
  match caps:
    case Resource.Reader{get}:read_resource(~Permit,~F,~H,capture,get(scope))
    case Resource.UnsupportedReader{}:(scope,(capture,Sys.BodyError{"Counter unsupported","capture retained"}))
def reader_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:ReaderOps(Permit,F,H),scope:H,capture:Array<U32>) -> F(H & (Array<U32> & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (Array<U32> & Sys.Completion<String,String>)),effects,reader_caps(~Permit,~F,~H,caps,scope,capture))
type QueryLocal is Type:
  QueryReady{target:W.Handle<P.AuditWorkshop>,pack:P.QueryPack}
  QueryDeferred{target:W.Handle<P.AuditWorkshop>,unused:U32 -> U32 & P.QueryPack}
def query_edited(~Permit:Data,~F:(Type -> Type),~H:Type,target:W.Handle<P.AuditWorkshop>,result:H & Q.GeneralEdit<U32,P.QueryPack>) -> H & (QueryLocal & Sys.Completion<String,String>):
  match result:
    case (scope,Q.GeneralEdited{pack}):(scope,(QueryReady{target,pack},Sys.Success{"scalar += 4"}))
    case (scope,Q.GeneralUnchanged{unused}):(scope,(QueryDeferred{target,unused},Sys.BodyError{"scalar write refused","capture retained in operation"}))
def query_value(pack:P.QueryPack,+prior:U32,value:U32) -> U32 & P.QueryPack:(U32.add(value,4),P.update(prior,pack))
def query_read(~Permit:Data,~F:(Type -> Type),~H:Type,modify:@-Out:Type -> H -> W.Handle<P.AuditWorkshop> -> (U32 -> U32 & Out) -> H & Q.GeneralEdit<U32,Out>,+target:W.Handle<P.AuditWorkshop>,pack:P.QueryPack,result:H & Q.GeneralLookup<U32>) -> H & (QueryLocal & Sys.Completion<String,String>):
  match result:
    case (scope,Q.Matched{Some{value}}):query_edited(~Permit,~F,~H,target,modify(P.QueryPack,scope,target,query_value(pack,value)))
    case (scope,_):(scope,(QueryReady{target,pack},Sys.BodyError{"scalar query missed","capture retained"}))
def query_caps(~Permit:Data,~F:(Type -> Type),~H:Type,caps:QueryOps(Permit,F,H),scope:H,local:QueryLocal) -> H & (QueryLocal & Sys.Completion<String,String>):
  match caps local:
    case Q.GeneralWriter{Q.GeneralReader{_,get},modify} QueryReady{+target,pack}:query_read(~Permit,~F,~H,modify,target,pack,get(scope,target))
    case _ local:(scope,(local,Sys.BodyError{"scalar query unsupported","capture retained"}))
def query_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:QueryOps(Permit,F,H),scope:H,local:QueryLocal) -> F(H & (QueryLocal & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (QueryLocal & Sys.Completion<String,String>)),effects,query_caps(~Permit,~F,~H,caps,scope,local))
def writer_compiled() -> Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>:Program.compile_framework(~P.AuditWorkshop,~Columns(),~C(),~R(),~WriterOps,~writer_kernel)
def reader_compiled() -> Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>:Program.compile_framework(~P.AuditWorkshop,~Columns(),~C(),~R(),~ReaderOps,~reader_kernel)
def query_compiled() -> Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>:Program.compile_framework(~P.AuditWorkshop,~Columns(),~C(),~R(),~QueryOps,~query_kernel)
def Writer() -> Type:Sys.Owner<P.AuditWorkshop,Columns(),C(),R(),Unit,WriterOps,WriterLocal,String,String,writer_kernel,writer_body>
def Reader() -> Type:Sys.Owner<P.AuditWorkshop,Columns(),C(),R(),Unit,ReaderOps,Array<U32>,String,String,reader_kernel,reader_body>
def Query() -> Type:Sys.Owner<P.AuditWorkshop,Columns(),C(),R(),Unit,QueryOps,QueryLocal,String,String,query_kernel,query_body>

def WriterBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>,Writer()>
def QueryBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>,Query()>
def ReaderBinding() -> Type:Scope.CompiledBinding<Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>,Reader()>
type Registration is Type:
  Registered{world:World(),writer:WriterBinding(),query:QueryBinding(),reader:ReaderBinding()}
  WriterRefused{world:World(),compilation:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>,writer:WriterLocal,query:QueryLocal,reader:Array<U32>}
  QueryRefused{world:World(),writer:WriterBinding(),compilation:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>,query:QueryLocal,reader:Array<U32>}
  ReaderRefused{world:World(),writer:WriterBinding(),query:QueryBinding(),compilation:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>,reader:Array<U32>}
def reader_registered(writer:WriterBinding(),query:QueryBinding(),result:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps> & Sys.Defined<World(),Reader(),Array<U32>>) -> Registration:
  match result:
    case (compilation,Sys.Defined{world,reader}):Registered{world,writer,query,Scope.pack(Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),ReaderOps>,Reader(),compilation,reader)}
    case (compilation,Sys.DefinitionRefused{world,reader}):ReaderRefused{world,writer,query,compilation,reader}
def query_registered(writer:WriterBinding(),reader:Array<U32>,result:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps> & Sys.Defined<World(),Query(),QueryLocal>) -> Registration:
  match result:
    case (compilation,Sys.Defined{world,query}):reader_registered(writer,Scope.pack(Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),QueryOps>,Query(),compilation,query),Register.define_with_compilation(~P.AuditWorkshop,~Columns(),~C(),~R(),~Unit,~ReaderOps,~Array<U32>,~String,~String,~reader_kernel,~reader_body,~L.resources(~P.AuditWorkshop,Author.resources()),reader_compiled(),world,"CapturedCounterReader",reader))
    case (compilation,Sys.DefinitionRefused{world,query}):QueryRefused{world,writer,compilation,query,reader}
def writer_registered(query:QueryLocal,reader:Array<U32>,result:Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps> & Sys.Defined<World(),Writer(),WriterLocal>) -> Registration:
  match result:
    case (compilation,Sys.Defined{world,writer}):query_registered(Scope.pack(Decl.Compilation<P.AuditWorkshop,Columns(),C(),R(),WriterOps>,Writer(),compilation,writer),reader,Register.define_with_compilation(~P.AuditWorkshop,~Columns(),~C(),~R(),~Unit,~QueryOps,~QueryLocal,~String,~String,~query_kernel,~query_body,~L.resources(~P.AuditWorkshop,Author.resources()),query_compiled(),world,"CapturedScalarQuery",query))
    case (compilation,Sys.DefinitionRefused{world,writer}):WriterRefused{world,compilation,writer,query,reader}
def define(world:World(),target:W.Handle<P.AuditWorkshop>) -> Registration:
  writer_registered(QueryReady{target,P.initial_query()},P.initial_resource_capture(),Register.define_with_compilation(~P.AuditWorkshop,~Columns(),~C(),~R(),~Unit,~WriterOps,~WriterLocal,~String,~String,~writer_kernel,~writer_body,~L.resources(~P.AuditWorkshop,Author.resources()),writer_compiled(),world,"CounterFieldWriter",WriterLocal{[],[]}))
def WriterNode() -> Type:Leaf.Node(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~WriterOps,~WriterLocal,~String,~String,~writer_kernel,~writer_body)
def QueryNode() -> Type:Leaf.Node(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~QueryOps,~QueryLocal,~String,~String,~query_kernel,~query_body)
def ReaderNode() -> Type:Leaf.Node(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~ReaderOps,~Array<U32>,~String,~String,~reader_kernel,~reader_body)
