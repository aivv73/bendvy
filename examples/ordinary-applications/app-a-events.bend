import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./app-a-schema.bend as D
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View
import ../../src/ecs/execution-event-ops.bend as Ops
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-retained-system.bend as Held
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec

def C() -> Type:Author.Columns()
def resources() -> L.Layout:D.tail_resources(~Author.Receipts())
def R() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
def World() -> Type:W.World<P.AuditWorkshop,Author.Columns(),L.resources(~P.AuditWorkshop,Author.resources()),Unit>
def Family() -> Type:Event.Family<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">
def Cached() -> Data:View.View<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>
def Reader() -> Type:Event.Reader<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog">
def WriterOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Ops.Writer<H,Array<U32>>
def writer_granted(~H:Type,-B:Type,result:B & Access.ResourceWrite<H,Family(),Cached()>) -> B & Ops.Writer<H,Array<U32>>:
  match result:
    case (book,cap):(book,Ops.writer(~P.AuditWorkshop,~H,~Array<U32>,~"RecoveredCargoLog",~Cached(),cap))
def writer_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~F,~H,~B),~lifecycle:Build.Lifecycle(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~H,~B),book:B) -> B & WriterOps(Permit,F,H):
  writer_granted(~H,B,Build.basic_resource_write(~P.AuditWorkshop,~C(),~R(),~H,~B,~Author.resources(),~L.InRight{L.InRight{L.InRight{L.AtLeaf{}}}},~{==},~{==},~rw,book))
def writer_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & WriterOps(Permit,F,H):builder(WriterOps,writer_selection(~Permit,~F,~H,~B),book)
type WriterLocal is Type:WriterLocal{pending:Maybe<Array<U32>>,returned:List<Array<U32>>,history:List<&2,String>}
def publish(~H:Type,cap:Ops.Writer<H,Array<U32>>) -> Array<U32> -> H -> H & Event.Publication<Array<U32>>:
  match cap:
    case Ops.Writer{publish}:publish
def published(~Permit:Data,~F:(Type -> Type),~H:Type,returned:List<Array<U32>>,history:List<&2,String>,result:H & Event.Publication<Array<U32>>) -> H & (WriterLocal & Sys.Completion<String,String>):
  match result:
    case (scope,Event.Published{id}):(scope,(WriterLocal{None{},returned,List.append(&2,String,history,["published=" ++ Nat.show(id)])},Sys.Success{"owned cargo published"}))
    case (scope,Event.PublicationRefused{payload}):(scope,(WriterLocal{None{},List.append(&1,Array<U32>,returned,[payload]),history},Sys.BodyError{"publication refused","owner retained"}))
def writer_raw(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:WriterOps(Permit,F,H),scope:H,local:WriterLocal) -> H & (WriterLocal & Sys.Completion<String,String>):
  match local:
    case WriterLocal{None{},returned,history}:(scope,(WriterLocal{None{},returned,history},Sys.Success{"no pending cargo"}))
    case WriterLocal{Some{payload},returned,history}:published(~Permit,~F,~H,returned,history,publish(~H,caps)(payload,scope))
type ReaderCaps<-H:Type> is Type:ReaderCaps{events:Ops.Reader<P.AuditWorkshop,H,Array<U32>,"RecoveredCargoLog",U32>,scalar:Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>}
def writer_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:WriterOps(Permit,F,H),scope:H,local:WriterLocal) -> F(H & (WriterLocal & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (WriterLocal & Sys.Completion<String,String>)),effects,writer_raw(~Permit,~F,~effects,~H,~caps,scope,local))

def ReaderOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:ReaderCaps<H>
def reader_granted(~H:Type,-B:Type,scalar:Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>,result:B & Access.ResourceRead<H,Cached()>) -> B & ReaderCaps<H>:
  match result:
    case (book,cap):(book,ReaderCaps{Ops.reader(~P.AuditWorkshop,~H,~Array<U32>,~"RecoveredCargoLog",~U32,cap),scalar})
def scalar_granted(~H:Type,~B:Type,~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),result:B & Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>) -> B & ReaderCaps<H>:
  match result:
    case (book,scalar):reader_granted(~H,B,scalar,Build.basic_resource_read(~P.AuditWorkshop,~C(),~R(),~H,~B,~Author.resources(),~L.InRight{L.InRight{L.InRight{L.AtLeaf{}}}},~{==},~{==},~rr,book))
def reader_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~P.AuditWorkshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~P.AuditWorkshop,~C(),~R(),~H,~B),~q:Build.Query(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~F,~H,~B),~lifecycle:Build.Lifecycle(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~H,~B),book:B) -> B & ReaderOps(Permit,F,H):
  scalar_granted(~H,~B,~rr,cw(D.components(),L.InRight{L.AtLeaf{}},{==},{==},book))
def reader_declaration(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & ReaderOps(Permit,F,H):builder(ReaderOps,reader_selection(~Permit,~F,~H,~B),book)
type ReaderLocal is Type:ReaderLocal{reader:Reader(),target:Maybe<&2,W.Handle<P.AuditWorkshop>>,scratch:Array<U32>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool}
def events(~H:Type,caps:ReaderCaps<H>) -> Ops.Reader<P.AuditWorkshop,H,Array<U32>,"RecoveredCargoLog",U32>:
  match caps:
    case ReaderCaps{events,_}:events
def scalar(~H:Type,caps:ReaderCaps<H>) -> Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>:
  match caps:
    case ReaderCaps{_,scalar}:scalar
def next(~H:Type,cap:Ops.Reader<P.AuditWorkshop,H,Array<U32>,"RecoveredCargoLog",U32>) -> Reader() -> H -> H & Event.Reading<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>:
  match cap:
    case Ops.Reader{next}:next
def added(+delta:U32,value:U32) -> U32 & U32:
  +prior=value
  (U32.add(prior,delta),prior)
def updated(~Permit:Data,~F:(Type -> Type),~H:Type,reader:Reader(),target:W.Handle<P.AuditWorkshop>,scratch:Array<U32>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,result:H & Maybe<&2,U32>) -> H & (ReaderLocal & Sys.Completion<String,String>):
  match result:
    case (scope,None{}):(scope,(ReaderLocal{reader,Some{target},scratch,readings,values,lagged},Sys.BodyError{"scalar absent","reader retained"}))
    case (scope,Some{value}):(scope,(ReaderLocal{reader,None{},scratch,readings,List.append(&2,U32,values,[value]),lagged},Sys.Success{"cargo read and scalar updated"}))
def read(~Permit:Data,~F:(Type -> Type),~H:Type,~cap:Access.ComponentWrite<P.AuditWorkshop,H,U32,U32>,+target:W.Handle<P.AuditWorkshop>,scratch:Array<U32>,readings:List<&2,U32>,values:List<&2,U32>,lagged:Bool,result:H & Event.Reading<P.AuditWorkshop,Array<U32>,"RecoveredCargoLog",U32>) -> H & (ReaderLocal & Sys.Completion<String,String>):
  match result:
    case (scope,Event.Item{reader,_,+value,missed}):updated(~Permit,~F,~H,reader,target,P.increment(value,scratch),List.append(&2,U32,readings,[value]),values,Bool.or(lagged,Bool.not(Nat.is_eq(missed,0n))),Access.component_modify_field(~P.AuditWorkshop,~H,~U32,~U32,cap)(added(value),scope,target))
    case (scope,Event.Empty{reader,missed}):(scope,(ReaderLocal{reader,Some{target},scratch,readings,values,Bool.or(lagged,Bool.not(Nat.is_eq(missed,0n)))},Sys.Success{"no cargo"}))
    case (scope,Event.ReadRefused{reader,_}):(scope,(ReaderLocal{reader,Some{target},scratch,readings,values,lagged},Sys.BodyError{"reader refused","reader retained"}))
def reader_raw(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:ReaderOps(Permit,F,H),scope:H,local:ReaderLocal) -> H & (ReaderLocal & Sys.Completion<String,String>):
  match local:
    case ReaderLocal{reader,None{},scratch,readings,values,lagged}:(scope,(ReaderLocal{reader,None{},scratch,readings,values,lagged},Sys.Success{"reader idle"}))
    case ReaderLocal{reader,Some{target},scratch,readings,values,lagged}:read(~Permit,~F,~H,~scalar(~H,caps),target,scratch,readings,values,lagged,next(~H,events(~H,caps))(reader,scope))
def reader_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:ReaderOps(Permit,F,H),scope:H,local:ReaderLocal) -> F(H & (ReaderLocal & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (ReaderLocal & Sys.Completion<String,String>)),effects,reader_raw(~Permit,~F,~effects,~H,~caps,scope,local))

def writer_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<P.AuditWorkshop>),~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & WriterOps(Permit,F,H):Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~WriterOps,~writer_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def Writer() -> Type:Sys.Owner<P.AuditWorkshop,Author.Columns(),C(),R(),Unit,WriterOps,WriterLocal,String,String,writer_kernel,writer_body>
def WriterCompilation() -> Type:Decl.Compilation<P.AuditWorkshop,Author.Columns(),C(),R(),WriterOps>
def writer_compilation() -> WriterCompilation():Program.compile_framework(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~WriterOps,~writer_kernel)
def WriterNode() -> Type:Held.CompiledBinding<WriterCompilation(),Writer()>
def reader_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<P.AuditWorkshop>),~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & ReaderOps(Permit,F,H):Build.framework_program(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~ReaderOps,~reader_declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def Receiver() -> Type:Sys.Owner<P.AuditWorkshop,Author.Columns(),C(),R(),Unit,ReaderOps,ReaderLocal,String,String,reader_kernel,reader_body>
def ReceiverCompilation() -> Type:Decl.Compilation<P.AuditWorkshop,Author.Columns(),C(),R(),ReaderOps>
def reader_compilation() -> ReceiverCompilation():Program.compile_framework(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~ReaderOps,~reader_kernel)
def ReceiverNode() -> Type:Held.CompiledBinding<ReceiverCompilation(),Receiver()>
def RawOwners() -> Type:Product.Owner<Writer(),Receiver()>
def Owners() -> Type:Reg.Product<WriterNode(),ReceiverNode()>
def writer_dispatch() -> WriterNode() -> World() -> U32 -> WriterNode() & (World() & Exec.Invocation<String,String>):Leaf.dispatch(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~WriterOps,~WriterLocal,~String,~String,~writer_kernel,~writer_body,~writer_compilation())
def writer_facts(node:WriterNode()) -> Registry.Facts<Reg.Registry<World(),WriterNode(),String,String,writer_dispatch()>>:Registry.ordinary(~World(),~WriterNode(),~String,~String,~writer_dispatch(),Leaf.facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~WriterOps,~WriterLocal,~String,~String,~writer_kernel,~writer_body,~writer_compilation(),node))
def reader_dispatch() -> ReceiverNode() -> World() -> U32 -> ReceiverNode() & (World() & Exec.Invocation<String,String>):Leaf.dispatch(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~ReaderOps,~ReaderLocal,~String,~String,~reader_kernel,~reader_body,~reader_compilation())
def reader_facts(node:ReceiverNode()) -> Registry.Facts<Reg.Registry<World(),ReceiverNode(),String,String,reader_dispatch()>>:Registry.ordinary(~World(),~ReceiverNode(),~String,~String,~reader_dispatch(),Leaf.facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~ReaderOps,~ReaderLocal,~String,~String,~reader_kernel,~reader_body,~reader_compilation(),node))
def dispatch() -> Owners() -> World() -> U32 -> Owners() & (World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(),~WriterNode(),~ReceiverNode(),~String,~String,~writer_dispatch(),~reader_dispatch())
def facts(owners:Owners()) -> Registry.Facts<Reg.Registry<World(),Owners(),String,String,dispatch()>>:
  match owners:
    case Reg.Product{writer,reader,_}:Registry.paired(~World(),~WriterNode(),~ReceiverNode(),~String,~String,~writer_dispatch(),~reader_dispatch(),writer_facts(writer),reader_facts(reader))
type Definition is Type:
  DefinitionReady{world:World(),owners:Owners()}
  WriterRefused{world:World(),compilation:WriterCompilation(),local:WriterLocal,reader:Reader()}
  ReaderRefused{world:World(),writer:WriterNode(),compilation:ReceiverCompilation(),local:ReaderLocal}
def reader_defined(writer:WriterNode(),result:ReceiverCompilation() & Sys.Defined<World(),Receiver(),ReaderLocal>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,reader}):DefinitionReady{world,Reg.Product{writer,Held.pack(ReceiverCompilation(),Receiver(),compilation,reader),[]}}
    case (compilation,Sys.DefinitionRefused{world,local}):ReaderRefused{world,writer,compilation,local}
def writer_defined(reader:Reader(),result:WriterCompilation() & Sys.Defined<World(),Writer(),WriterLocal>) -> Definition:
  match result:
    case (compilation,Sys.Defined{world,writer}):reader_defined(Held.pack(WriterCompilation(),Writer(),compilation,writer),Register.define_with_compilation(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Unit,~ReaderOps,~ReaderLocal,~String,~String,~reader_kernel,~reader_body,~R(),reader_compilation(),world,"RecoveredCargoReader",ReaderLocal{reader,None{},P.scratch(),[],[],False{}}))
    case (compilation,Sys.DefinitionRefused{world,local}):WriterRefused{world,compilation,local,reader}
def define(world:World(),reader:Reader()) -> Definition:writer_defined(reader,Register.define_with_compilation(~P.AuditWorkshop,~Author.Columns(),~C(),~R(),~Unit,~WriterOps,~WriterLocal,~String,~String,~writer_kernel,~writer_body,~R(),writer_compilation(),world,"RecoveredCargoPublisher",WriterLocal{None{},[],[]}))
def raw_accept(owners:RawOwners(),target:W.Handle<P.AuditWorkshop>,payload:Array<U32>) -> RawOwners() & Maybe<Array<U32>>:
  match owners:
    case Product.Owner{Sys.Owner{wn,wi,wname,wa,wc,WriterLocal{None{},returned,history}},Sys.Owner{rn,ri,rname,ra,rc,ReaderLocal{reader,oldTarget,scratch,readings,values,lagged}}}:(Product.Owner{Sys.Owner{wn,wi,wname,wa,wc,WriterLocal{Some{payload},returned,history}},Sys.Owner{rn,ri,rname,ra,rc,ReaderLocal{reader,Some{target},scratch,readings,values,lagged}}},None{})
    case owners:(owners,Some{payload})
def scratch_observed(writer:Writer(),+namespace:U32,+id:U32,name:String,access:List<&2,String>,+cursor:Maybe<&2,Tick.Tick>,reader:Reader(),target:Maybe<&2,W.Handle<P.AuditWorkshop>>,+readings:List<&2,U32>,+values:List<&2,U32>,+lagged:Bool,result:Array<U32> & List<&2,U32>) -> RawOwners() & String:
  match reader result:
    case Event.Reader{+identity,+readerId,+readCursor}, (scratch,view):(Product.Owner{writer,Sys.Owner{namespace,id,name,access,cursor,ReaderLocal{Event.Reader{identity,readerId,readCursor},target,scratch,readings,values,lagged}}},"event-reader-system-ns=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";system-cursor=" ++ Tick.cursor_show(cursor) ++ ";family-identity=" ++ U32.show(identity) ++ ";reader-id=" ++ U32.show(readerId) ++ ";reader-cursor=" ++ Nat.show(readCursor) ++ ";lagged=" ++ Bool.show(lagged) ++ ";readings=" ++ List.show(&2,U32,U32.show,readings) ++ ";prior-scalars=" ++ List.show(&2,U32,U32.show,values) ++ ";scratch=" ++ List.show(&2,U32,U32.show,view))
def raw_observed(owners:RawOwners()) -> RawOwners() & String:
  match owners:
    case Product.Owner{writer,Sys.Owner{namespace,id,name,access,cursor,ReaderLocal{reader,target,scratch,readings,values,lagged}}}:scratch_observed(writer,namespace,id,name,access,cursor,reader,target,readings,values,lagged,P.project(scratch))
def accepted(writerCompilation:WriterCompilation(),readerCompilation:ReceiverCompilation(),ids:List<&2,U32>,result:RawOwners() & Maybe<Array<U32>>) -> Owners() & Maybe<Array<U32>>:
  match result:
    case (Product.Owner{writer,reader},out):(Reg.Product{Held.pack(WriterCompilation(),Writer(),writerCompilation,writer),Held.pack(ReceiverCompilation(),Receiver(),readerCompilation,reader),ids},out)
def accept_opened(ids:List<&2,U32>,target:W.Handle<P.AuditWorkshop>,payload:Array<U32>,writer:WriterCompilation() & Writer(),reader:ReceiverCompilation() & Receiver()) -> Owners() & Maybe<Array<U32>>:
  match writer reader:
    case (wc,writer), (rc,reader):accepted(wc,rc,ids,raw_accept(Product.Owner{writer,reader},target,payload))
def accept(owners:Owners(),target:W.Handle<P.AuditWorkshop>,payload:Array<U32>) -> Owners() & Maybe<Array<U32>>:
  match owners:
    case Reg.Product{writer,reader,ids}:accept_opened(ids,target,payload,Held.unpack(WriterCompilation(),Writer(),writer),Held.unpack(ReceiverCompilation(),Receiver(),reader))
def observation_returned(writerCompilation:WriterCompilation(),readerCompilation:ReceiverCompilation(),ids:List<&2,U32>,result:RawOwners() & String) -> Owners() & String:
  match result:
    case (Product.Owner{writer,reader},text):(Reg.Product{Held.pack(WriterCompilation(),Writer(),writerCompilation,writer),Held.pack(ReceiverCompilation(),Receiver(),readerCompilation,reader),ids},text)
def observed_opened(ids:List<&2,U32>,writer:WriterCompilation() & Writer(),reader:ReceiverCompilation() & Receiver()) -> Owners() & String:
  match writer reader:
    case (wc,writer), (rc,reader):observation_returned(wc,rc,ids,raw_observed(Product.Owner{writer,reader}))
def observed(owners:Owners()) -> Owners() & String:
  match owners:
    case Reg.Product{writer,reader,ids}:observed_opened(ids,Held.unpack(WriterCompilation(),Writer(),writer),Held.unpack(ReceiverCompilation(),Receiver(),reader))
