import Base
import ../../src/ecs/execution-effects.bend as Effects
import ../query-systems/declarations.bend as D
import ../query-systems/observation.bend as Observe
import ./notice-observation.bend as NoticeObserve
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-lifecycle-access.bend as Life
import ../../src/ecs/execution-lifecycle-administration.bend as Admin
import ../../src/ecs/execution-lifecycle-notices.bend as Notice
import ../../src/ecs/execution-app.bend as Execute
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/world.bend as W

type First is Data:
  First{}
type Second is Data:
  Second{}
def route() -> Layout.Route:Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}}
def origin() -> Layout.Layout:Layout.origin(D.layout(),route())
def Reader(~S:Data) -> Type:Notice.Reader<S,origin(),Notice.Removed{"output"}>
def Ops(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Life.Next<S,H,origin(),Notice.Removed{"output"}>
def selection(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~cw:Build.ComponentWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rr:Build.ResourceRead(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~rw:Build.ResourceWrite(~S,~D.Store(~S),~D.Resources(~S),~H,~B),~query:Build.Query(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~H,~B),book:B) -> B & Ops(~S,Permit,F,H):
  Build.removed_lifecycle(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~D.layout(),~route(),~{==},~{==},~H,~B,~lifecycle,book)
def declaration(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Ops(~S,Permit,F,H):
  builder(Ops(~S),selection(~S,~Permit,~F,~H,~B),book)
def read_returned(~S:Data,~H:Type,result:H & Notice.Reading<S,origin(),Notice.Removed{"output"}>) -> H & (Reader(~S) & Sys.Completion<String,String>):
  match result:
    case (owner,Notice.Empty{reader,missed}):(owner,(reader,Sys.Success{"empty/" ++ Nat.show(missed)}))
    case (owner,Notice.Item{reader,Notice.Row{sequence,_,_},missed}):(owner,(reader,Sys.Success{"item/" ++ Nat.show(sequence) ++ "/" ++ Nat.show(missed)}))
    case (owner,Notice.ReadRefused{reader,_}):(owner,(reader,Sys.BodyError{"reader-refused","refused"}))
def body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~cap:Ops(~S,Permit,F,H),owner:H,reader:Reader(~S)) -> F(H & (Reader(~S) & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (Reader(~S) & Sys.Completion<String,String>)),effects,read_returned(~S,~H,Life.next(~S,~H,~origin(),~(Notice.Removed{"output"}),cap,owner,reader)))
def kernel(~S:Data,~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Permit,~F,~H,~B),book:B) -> B & Ops(~S,Permit,F,H):Build.framework_program(~S,~D.Store(~S),~D.Store(~S),~D.Resources(~S),~Ops(~S),~declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def Runtime(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def Application(~S:Data) -> Type:Execute.Application<S,D.Store(~S),D.Resources(~S),Unit,Ops(~S),Reader(~S),String,String,kernel(~S),body(~S)>
def status(value:Execute.Status<String,String>) -> String:
  match value:
    case Execute.Ran{Sys.Success{out}}:out
    case Execute.Ran{Sys.BodyError{error,out}}:error ++ "/" ++ out
    case Execute.AdmissionRefused{}:"admission-refused"
def observed(~S:Data,result:Application(~S) & Execute.Status<String,String>) -> String:
  match result:
    case (Execute.Application{world,Sys.Owner{namespace,id,name,access,cursor,Notice.Reader{readerNamespace,readerId,readerCursor}}},done):status(done) ++ ";reader=" ++ U32.show(readerNamespace) ++ ":" ++ U32.show(readerId) ++ ":" ++ Nat.show(readerCursor) ++ ";system=" ++ U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(&2,String,x=>x,access) ++ ":" ++ Observe.maybe_tick(cursor) ++ ";world={" ++ NoticeObserve.world(~S,world) ++ "}"
def defined(~S:Data,result:Execute.Built<Application(~S),Runtime(~S),Reader(~S)>) -> IO(String):
  match result:
    case Execute.Built{application}:IO.pure(String,observed(~S,Execute.run(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Ops(~S),~Reader(~S),~String,~String,~kernel(~S),~body(~S),application)))
    case Execute.BuildRefused{_,_}:IO.pure(String,"definition-refused")
def registered(~S:Data,result:Runtime(~S) & Notice.Registration<S,origin(),Notice.Removed{"output"}>) -> IO(String):
  match result:
    case (world,Notice.Registered{reader}):defined(~S,Execute.define_framework(~S,~D.Store(~S),~D.Resources(~S),~Unit,~Ops(~S),~Reader(~S),~String,~String,~kernel(~S),~body(~S),world,"notice-positive",reader))
    case (_,Notice.RegistrationRefused{_}):IO.pure(String,"reader-registration-refused")
def first(world:Runtime(~First),reader:Reader(~First)) -> IO(String):
  defined(~First,Execute.define_framework(~First,~D.Store(~First),~D.Resources(~First),~Unit,~Ops(~First),~Reader(~First),~String,~String,~kernel(~First),~body(~First),world,"notice-positive",reader))
def second(world:Runtime(~Second),reader:Reader(~Second)) -> IO(String):
  defined(~Second,Execute.define_framework(~Second,~D.Store(~Second),~D.Resources(~Second),~Unit,~Ops(~Second),~Reader(~Second),~String,~String,~kernel(~Second),~body(~Second),world,"notice-positive",reader))
