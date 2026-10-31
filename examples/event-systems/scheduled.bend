import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-retained-system.bend as Scope
import ../../src/ecs/deferred-command.bend as Deferred
import ../query-systems/observation.bend as Observe
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ./scenario.bend as D
import ../../src/ecs/execution-event-family.bend as Event
import ../../src/ecs/execution-event-view.bend as View
import ../../src/ecs/execution-event-io.bend as EventIO
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/owned-event-log.bend as Log
import ../../src/ecs/world.bend as W
import ../../src/ecs/change-tick.bend as Tick

import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-generalized-root-application.bend as General
import ../../src/ecs/execution-registry.bend as Facts
import ../../src/ecs/dependency-registration.bend as Reg
def components() -> Layout.Layout:Layout.LayoutPair{Layout.EmptyLayout{},Layout.EmptyLayout{}}
def resources(~S:Data,~P:Type,~project:P -> P & U32) -> Layout.Layout:D.layout(~S,~P,~project)
def Store() -> Type:Product.Owner<Unit,Unit>
def Resources(~S:Data,~P:Type,~project:P -> P & U32) -> Type:D.Resources(~S,~P,~project)
def World(~S:Data,~P:Type,~project:P -> P & U32) -> Type:W.World<S,Store(),Resources(~S,~P,~project),Unit>
def NoOps(Permit:Data,F:Type -> Type,H:Type) -> Type:Unit
def peer_program(~S:Data,~P:Type,~project:P -> P & U32,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Permit,~F,~H,~B),book:B) -> B & Unit:(book,Unit{})
def peer_body(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,runs:U32) -> F(H & (U32 & Sys.Completion<String,String>)):Effects.pure(~F,(H & (U32 & Sys.Completion<String,String>)),effects,(scope,(U32.add(runs,1),Sys.Success{"peer"})))
def Writer(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Store(),Resources(~S,~P,~project),Unit,D.WriterOps(~P),D.WriterLocal<P>,String,String,D.writer(~S,~Store(),~P,~project),D.writer_body(~S,~P)>
def WriterCompilation(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),D.WriterOps(~P)>
def writer_compilation(~S:Data,~P:Type,~project:P -> P & U32) -> WriterCompilation(~S,~P,~project):Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.WriterOps(~P),~D.writer(~S,~Store(),~P,~project))
def WriterNode(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Scope.CompiledBinding<WriterCompilation(~S,~P,~project),Writer(~S,~P,~project)>
def writer_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> WriterNode(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> WriterNode(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~components(),~resources(~S,~P,~project),~Unit,~D.WriterOps(~P),~D.WriterLocal<P>,~String,~String,~D.writer(~S,~Store(),~P,~project),~D.writer_body(~S,~P),~writer_compilation(~S,~P,~project))
def writer_facts(~S:Data,~P:Type,~project:P -> P & U32,node:WriterNode(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),WriterNode(~S,~P,~project),String,String,writer_dispatch(~S,~P,~project)>>:Facts.ordinary(~World(~S,~P,~project),~WriterNode(~S,~P,~project),~String,~String,~writer_dispatch(~S,~P,~project),Leaf.facts(~S,~components(),~resources(~S,~P,~project),~Unit,~D.WriterOps(~P),~D.WriterLocal<P>,~String,~String,~D.writer(~S,~Store(),~P,~project),~D.writer_body(~S,~P),~writer_compilation(~S,~P,~project),node))
def Reader(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Store(),Resources(~S,~P,~project),Unit,D.ReaderOps(~S,~P),D.ReaderLocal<S,P>,String,String,D.reader(~S,~Store(),~P,~project),D.reader_body(~S,~P)>
def ReaderCompilation(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),D.ReaderOps(~S,~P)>
def reader_compilation(~S:Data,~P:Type,~project:P -> P & U32) -> ReaderCompilation(~S,~P,~project):Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.ReaderOps(~S,~P),~D.reader(~S,~Store(),~P,~project))
def ReaderNode(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Scope.CompiledBinding<ReaderCompilation(~S,~P,~project),Reader(~S,~P,~project)>
def reader_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> ReaderNode(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> ReaderNode(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~components(),~resources(~S,~P,~project),~Unit,~D.ReaderOps(~S,~P),~D.ReaderLocal<S,P>,~String,~String,~D.reader(~S,~Store(),~P,~project),~D.reader_body(~S,~P),~reader_compilation(~S,~P,~project))
def reader_facts(~S:Data,~P:Type,~project:P -> P & U32,node:ReaderNode(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),ReaderNode(~S,~P,~project),String,String,reader_dispatch(~S,~P,~project)>>:Facts.ordinary(~World(~S,~P,~project),~ReaderNode(~S,~P,~project),~String,~String,~reader_dispatch(~S,~P,~project),Leaf.facts(~S,~components(),~resources(~S,~P,~project),~Unit,~D.ReaderOps(~S,~P),~D.ReaderLocal<S,P>,~String,~String,~D.reader(~S,~Store(),~P,~project),~D.reader_body(~S,~P),~reader_compilation(~S,~P,~project),node))
def Admin(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Store(),Resources(~S,~P,~project),Unit,D.AdminOps(~S,~P),D.AdminLocal<S,P>,String,String,D.admin(~S,~Store(),~P,~project),D.admin_body(~S,~P)>
def AdminCompilation(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),D.AdminOps(~S,~P)>
def admin_compilation(~S:Data,~P:Type,~project:P -> P & U32) -> AdminCompilation(~S,~P,~project):Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.AdminOps(~S,~P),~D.admin(~S,~Store(),~P,~project))
def AdminNode(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Scope.CompiledBinding<AdminCompilation(~S,~P,~project),Admin(~S,~P,~project)>
def admin_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> AdminNode(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> AdminNode(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~components(),~resources(~S,~P,~project),~Unit,~D.AdminOps(~S,~P),~D.AdminLocal<S,P>,~String,~String,~D.admin(~S,~Store(),~P,~project),~D.admin_body(~S,~P),~admin_compilation(~S,~P,~project))
def admin_facts(~S:Data,~P:Type,~project:P -> P & U32,node:AdminNode(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),AdminNode(~S,~P,~project),String,String,admin_dispatch(~S,~P,~project)>>:Facts.ordinary(~World(~S,~P,~project),~AdminNode(~S,~P,~project),~String,~String,~admin_dispatch(~S,~P,~project),Leaf.facts(~S,~components(),~resources(~S,~P,~project),~Unit,~D.AdminOps(~S,~P),~D.AdminLocal<S,P>,~String,~String,~D.admin(~S,~Store(),~P,~project),~D.admin_body(~S,~P),~admin_compilation(~S,~P,~project),node))
def Peer(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Store(),Resources(~S,~P,~project),Unit,NoOps,U32,String,String,peer_program(~S,~P,~project),peer_body(~S)>
def PeerCompilation(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),NoOps>
def peer_compilation(~S:Data,~P:Type,~project:P -> P & U32) -> PeerCompilation(~S,~P,~project):Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~NoOps,~peer_program(~S,~P,~project))
def PeerNode(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Scope.CompiledBinding<PeerCompilation(~S,~P,~project),Peer(~S,~P,~project)>
def peer_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> PeerNode(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> PeerNode(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Leaf.dispatch(~S,~components(),~resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~String,~peer_program(~S,~P,~project),~peer_body(~S),~peer_compilation(~S,~P,~project))
def peer_facts(~S:Data,~P:Type,~project:P -> P & U32,node:PeerNode(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),PeerNode(~S,~P,~project),String,String,peer_dispatch(~S,~P,~project)>>:Facts.ordinary(~World(~S,~P,~project),~PeerNode(~S,~P,~project),~String,~String,~peer_dispatch(~S,~P,~project),Leaf.facts(~S,~components(),~resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~String,~peer_program(~S,~P,~project),~peer_body(~S),~peer_compilation(~S,~P,~project),node))
def SlowAdmin(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Reg.Product<ReaderNode(~S,~P,~project),AdminNode(~S,~P,~project)>
def slowadmin_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> SlowAdmin(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> SlowAdmin(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S,~P,~project),~ReaderNode(~S,~P,~project),~AdminNode(~S,~P,~project),~String,~String,~reader_dispatch(~S,~P,~project),~admin_dispatch(~S,~P,~project))
def slowadmin_facts(~S:Data,~P:Type,~project:P -> P & U32,owners:SlowAdmin(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),SlowAdmin(~S,~P,~project),String,String,slowadmin_dispatch(~S,~P,~project)>>:
  match owners:
    case Reg.Product{left,right,_}:Facts.paired(~World(~S,~P,~project),~ReaderNode(~S,~P,~project),~AdminNode(~S,~P,~project),~String,~String,~reader_dispatch(~S,~P,~project),~admin_dispatch(~S,~P,~project),reader_facts(~S,~P,~project,left),admin_facts(~S,~P,~project,right))
def Readers(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Reg.Product<ReaderNode(~S,~P,~project),SlowAdmin(~S,~P,~project)>
def readers_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> Readers(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> Readers(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S,~P,~project),~ReaderNode(~S,~P,~project),~SlowAdmin(~S,~P,~project),~String,~String,~reader_dispatch(~S,~P,~project),~slowadmin_dispatch(~S,~P,~project))
def readers_facts(~S:Data,~P:Type,~project:P -> P & U32,owners:Readers(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),Readers(~S,~P,~project),String,String,readers_dispatch(~S,~P,~project)>>:
  match owners:
    case Reg.Product{left,right,_}:Facts.paired(~World(~S,~P,~project),~ReaderNode(~S,~P,~project),~SlowAdmin(~S,~P,~project),~String,~String,~reader_dispatch(~S,~P,~project),~slowadmin_dispatch(~S,~P,~project),reader_facts(~S,~P,~project,left),slowadmin_facts(~S,~P,~project,right))
def Left(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Reg.Product<WriterNode(~S,~P,~project),Readers(~S,~P,~project)>
def left_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> Left(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> Left(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S,~P,~project),~WriterNode(~S,~P,~project),~Readers(~S,~P,~project),~String,~String,~writer_dispatch(~S,~P,~project),~readers_dispatch(~S,~P,~project))
def left_facts(~S:Data,~P:Type,~project:P -> P & U32,owners:Left(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),Left(~S,~P,~project),String,String,left_dispatch(~S,~P,~project)>>:
  match owners:
    case Reg.Product{left,right,_}:Facts.paired(~World(~S,~P,~project),~WriterNode(~S,~P,~project),~Readers(~S,~P,~project),~String,~String,~writer_dispatch(~S,~P,~project),~readers_dispatch(~S,~P,~project),writer_facts(~S,~P,~project,left),readers_facts(~S,~P,~project,right))
def Nodes(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Reg.Product<Left(~S,~P,~project),PeerNode(~S,~P,~project)>
def nodes_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> Nodes(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> Nodes(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S,~P,~project),~Left(~S,~P,~project),~PeerNode(~S,~P,~project),~String,~String,~left_dispatch(~S,~P,~project),~peer_dispatch(~S,~P,~project))
def nodes_facts(~S:Data,~P:Type,~project:P -> P & U32,owners:Nodes(~S,~P,~project)) -> Facts.Facts<Reg.Registry<World(~S,~P,~project),Nodes(~S,~P,~project),String,String,nodes_dispatch(~S,~P,~project)>>:
  match owners:
    case Reg.Product{left,right,_}:Facts.paired(~World(~S,~P,~project),~Left(~S,~P,~project),~PeerNode(~S,~P,~project),~String,~String,~left_dispatch(~S,~P,~project),~peer_dispatch(~S,~P,~project),left_facts(~S,~P,~project,left),peer_facts(~S,~P,~project,right))
def guard_program(~S:Data,~P:Type,~project:P -> P & U32,~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Permit,~F,~H,~B),book:B) -> B & Unit:(book,Unit{})
def guard_step(~H:Type,scope:H,+runs:U32) -> H & (U32 & Sys.Completion<String,Bool>):(scope,(U32.add(runs,1),Sys.Success{U32.is_le(2,runs)}))
def guard_body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,runs:U32) -> F(H & (U32 & Sys.Completion<String,Bool>)):Effects.pure(~F,(H & (U32 & Sys.Completion<String,Bool>)),effects,guard_step(~H,scope,runs))
def GuardOwner(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Sys.Owner<S,Store(),Store(),Resources(~S,~P,~project),Unit,NoOps,U32,String,Bool,guard_program(~S,~P,~project),guard_body(~S)>
# The closed factory registers and retains the returned actual compilation.
# The static witness fixes this consumer; its phantom type is not a coherence proof.
def guard_construction(~S:Data,~P:Type,~project:P -> P & U32) -> Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),NoOps>:Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~NoOps,~guard_program(~S,~P,~project))
def Guard(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Scope.CompiledBinding<Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),NoOps>,GuardOwner(~S,~P,~project)>
def guard_dispatch(~S:Data,~P:Type,~project:P -> P & U32) -> Guard(~S,~P,~project) -> World(~S,~P,~project) -> U32 -> Guard(~S,~P,~project) & (World(~S,~P,~project) & Exec.Invocation<String,Bool>):Conditions.retained_leaf_dispatch(~S,~Store(),~Resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~guard_program(~S,~P,~project),~guard_body(~S),~guard_construction(~S,~P,~project))
type Handler is Type:Handler{token:Array<U32>,errors:U32}
def handle(owner:Handler,_:String) -> Handler & Exec.Handling:
  match owner:
    case Handler{token,errors}:(Handler{token,U32.add(errors,1)},Exec.Continue{})
def available(_:String) -> Bool:True{}
def Application(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Schedule.Scheduled<App.State<World(~S,~P,~project),Nodes(~S,~P,~project),Guard(~S,~P,~project),Handler>>
def text(value:String) -> String:value
def strings(values:List<&2,String>) -> String:List.show(&2,String,text,values)
def reused(~P:Type,first:U32,result:P & U32) -> String:
  match result:
    case (_,second):U32.show(first) ++ "/" ++ U32.show(second)
def value_returned(~P:Type,~project:P -> P & U32,result:P & U32) -> String:
  match result:
    case (owner,first):reused(~P,first,project(owner))
def payload(~P:Type,~project:P -> P & U32,owner:P) -> String:value_returned(~P,~project,project(owner))
def values(~P:Type,~project:P -> P & U32,owners:List<P>) -> String:List.show(&1,P,payload(~P,~project),owners)
def row(~P:Type,~project:P -> P & U32,value:Log.Row<P>) -> String:
  match value:
    case Log.Row{id,owner}:Nat.show(id) ++ "=" ++ payload(~P,~project,owner)
def event_rows(~P:Type,~project:P -> P & U32,owners:List<Log.Row<P>>) -> String:List.show(&1,Log.Row<P>,row(~P,~project),owners)
def cursor(~S:Data,~P:Type,reader:Event.Reader<S,P,"events">) -> String:
  match reader:
    case Event.Reader{identity,id,at}:U32.show(identity) ++ ":" ++ U32.show(id) ++ ":" ++ Nat.show(at)
def maybe_cursor(~S:Data,~P:Type,reader:Maybe<&1,Event.Reader<S,P,"events">>) -> String:
  match reader:
    case None{}:"none"
    case Some{reader}:cursor(~S,~P,reader)
def writer_local(~P:Type,~project:P -> P & U32,local:D.WriterLocal<P>) -> String:
  match local:
    case D.WriterLocal{pending,refused,runs,history}:"pending=" ++ values(~P,~project,pending) ++ ";refused=" ++ values(~P,~project,refused) ++ ";runs=" ++ U32.show(runs) ++ ";history=" ++ strings(history)
def reader_local(~S:Data,~P:Type,local:D.ReaderLocal<S,P>) -> String:
  match local:
    case D.ReaderLocal{reader,runs,history}:"cursor=" ++ cursor(~S,~P,reader) ++ ";runs=" ++ U32.show(runs) ++ ";history=" ++ strings(history)
def admin_local(~S:Data,~P:Type,~project:P -> P & U32,local:D.AdminLocal<S,P>) -> String:
  match local:
    case D.AdminLocal{removable,foreign,retired,extra,runs,history}:"removed=" ++ maybe_cursor(~S,~P,removable) ++ ";foreign=" ++ maybe_cursor(~S,~P,foreign) ++ ";owners=" ++ event_rows(~P,~project,retired) ++ ";extra=" ++ List.show(&1,Event.Reader<S,P,"events">,cursor(~S,~P),extra) ++ ";runs=" ++ U32.show(runs) ++ ";history=" ++ strings(history)
def cached_row(value:View.Row<U32>) -> String:
  match value:
    case View.Row{id,value}:Nat.show(id) ++ "=" ++ U32.show(value)
def cached(~S:Data,~P:Type,value:View.View<S,P,"events",U32>) -> String:
  match value:
    case View.View{identity,open,next,active,dropped,rows}:"id=" ++ U32.show(identity) ++ ";open=" ++ Bool.pick(String,open,"true","false") ++ ";next=" ++ Nat.show(next) ++ ";active=" ++ List.show(&2,U32,U32.show,active) ++ ";dropped=" ++ Nat.show(dropped) ++ ";rows=" ++ List.show(&2,View.Row<U32>,cached_row,rows)
def family(~S:Data,~P:Type,~project:P -> P & U32,value:Event.Family<S,P,"events">) -> String:
  match value:
    case Event.Family{identity,open,Log.Log{next,rows},previous,current,nextReader,active,dropped}:"id=" ++ U32.show(identity) ++ ";open=" ++ Bool.pick(String,open,"true","false") ++ ";next=" ++ Nat.show(next) ++ ";previous=" ++ List.show(&2,Nat,Nat.show,previous) ++ ";current=" ++ List.show(&2,Nat,Nat.show,current) ++ ";next-reader=" ++ U32.show(nextReader) ++ ";active=" ++ List.show(&2,U32,U32.show,active) ++ ";dropped=" ++ Nat.show(dropped) ++ ";rows=" ++ event_rows(~P,~project,rows)
def event(value:Exec.Observation<String,String>) -> String:
  match value:
    case Exec.Ran{id,out}:U32.show(id) ++ "/success/" ++ out
    case Exec.BodyFailed{id,error,out}:U32.show(id) ++ "/error/" ++ error ++ "/" ++ out
    case Exec.Skipped{id}:U32.show(id) ++ "/disabled"
    case Exec.ConditionFailed{id,error}:U32.show(id) ++ "/condition-error/" ++ error
    case Exec.ConditionRejected{id}:U32.show(id) ++ "/condition-refused"
    case Exec.AdmissionRejected{id}:U32.show(id) ++ "/admission-refused"
def event_id(value:Exec.Observation<String,String>) -> U32:
  match value:
    case Exec.Ran{id,_}:id
    case Exec.BodyFailed{id,_,_}:id
    case Exec.Skipped{id}:id
    case Exec.ConditionFailed{id,_}:id
    case Exec.ConditionRejected{id}:id
    case Exec.AdmissionRejected{id}:id
def event_le(left:Exec.Observation<String,String>,right:Exec.Observation<String,String>) -> Bool:U32.is_le(event_id(left),event_id(right))
def report(value:App.Report<String,String>) -> String:
  match value:
    case App.Finished{events}:List.show(&2,Exec.Observation<String,String>,event,List.sort(~Exec.Observation<String,String>,~event_le,events))
    case App.Stopped{_,_}:"stopped"
    case App.Invalid{_}:"invalid"
def token(result:Array<U32> & U32) -> String:
  match result:
    case (_,value):U32.show(value)
def access(value:Decl.Access) -> String:
  match value:
    case Decl.Access{key,Decl.ResourceAccess{},Decl.Exclusive{},Decl.Writable{}}:"resource/" ++ key ++ "/exclusive/write"
    case Decl.Access{key,Decl.ResourceAccess{},Decl.Exclusive{},Decl.ReadOnly{}}:"resource/" ++ key ++ "/exclusive/read"
    case _ :"unexpected-access"
def metadata(~S:Data,~P:Type,~project:P -> P & U32) -> String:
  List.show(&2,Decl.Access,access,Decl.compilation_requirements(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.WriterOps(~P),Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.WriterOps(~P),~D.writer(~S,~Store(),~P,~project)))) ++ "/" ++ List.show(&2,Decl.Access,access,Decl.compilation_requirements(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.ReaderOps(~S,~P),Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.ReaderOps(~S,~P),~D.reader(~S,~Store(),~P,~project)))) ++ "/" ++ List.show(&2,Decl.Access,access,Decl.compilation_requirements(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.AdminOps(~S,~P),Build.compile_framework(~S,~Store(),~Store(),~Resources(~S,~P,~project),~D.AdminOps(~S,~P),~D.admin(~S,~Store(),~P,~project))))
def pending_returned(~World:Type,command:Deferred.Command<World>,tag:String,result:List<Deferred.Command<World>> & List<&2,String>) -> List<Deferred.Command<World>> & List<&2,String>:
  match result:
    case (rest,tags):(command <> rest,tag <> tags)
# Projection returns the actual opaque closures without evaluating them.
def pending(~World:Type,commands:List<Deferred.Command<World>>) -> List<Deferred.Command<World>> & List<&2,String>:
  match commands:
    case []:([],[])
    case Deferred.Raw{apply} <> rest:pending_returned(~World,Deferred.Raw{apply},"Raw",pending(~World,rest))
    case Deferred.Observed{apply} <> rest:pending_returned(~World,Deferred.Observed{apply},"Observed",pending(~World,rest))
def pending_text(~World:Type,result:List<Deferred.Command<World>> & List<&2,String>) -> String:
  match result:
    case (_,tags):strings(tags)
def system_header(namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>) -> String:
  "namespace=" ++ U32.show(namespace) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ strings(access) ++ ";cursor=" ++ Observe.maybe_tick(cursor)
def RawOwners(~S:Data,~P:Type,~project:P -> P & U32) -> Type:Product.Owner<Product.Owner<Writer(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Product.Owner<Reader(~S,~P,~project),Admin(~S,~P,~project)>>>,Peer(~S,~P,~project)>
def observed_raw(~S:Data,~P:Type,~project:P -> P & U32,trace:String,world:World(~S,~P,~project),owners:RawOwners(~S,~P,~project),guard:GuardOwner(~S,~P,~project),handler:Handler) -> String:
  match world owners guard handler:
    case W.World{namespace,allocator,Product.Owner{Unit{},Unit{}},Layout.ResourceSlot{Layout.Viewed{owner,cache},stamp},events,commands,registrations,nextSystem,clock,journal}, Product.Owner{Product.Owner{Sys.Owner{wn,wi,wm,+wa,wc,wl},Product.Owner{Sys.Owner{fn,fi,fm,+fa,fc,fl},Product.Owner{Sys.Owner{sn,si,sm,+sa,sc,sl},Sys.Owner{an,ai,am,+aa,ac,al}}}},Sys.Owner{pn,pi,pm,pa,pc,peer}}, Sys.Owner{gn,gi,gm,ga,gc,guards}, Handler{handler,errors}:trace ++ "|family={" ++ family(~S,~P,~project,owner) ++ "}|cache={" ++ cached(~S,~P,cache) ++ "}|writer={" ++ writer_local(~P,~project,wl) ++ "}|fast={" ++ reader_local(~S,~P,fl) ++ "}|slow={" ++ reader_local(~S,~P,sl) ++ "}|admin={" ++ admin_local(~S,~P,~project,al) ++ "}|access=" ++ strings(wa) ++ "/" ++ strings(fa) ++ "/" ++ strings(sa) ++ "/" ++ strings(aa) ++ "|metadata=" ++ metadata(~S,~P,~project) ++ "|peer=" ++ U32.show(peer) ++ ";guard=" ++ U32.show(guards) ++ ";handler=" ++ token(Array.get(U32,handler,0)) ++ ":" ++ U32.show(errors) ++ "|world={namespace=" ++ U32.show(namespace) ++ ";allocator={" ++ Observe.allocator(allocator) ++ "};components=Owner(Unit,Unit);resources-stamp=" ++ Observe.stamp(Some{stamp}) ++ ";events=" ++ List.show(&2,Unit,_=>"Unit",events) ++ ";pending=" ++ pending_text(~World(~S,~P,~project),pending(~World(~S,~P,~project),commands)) ++ ";registrations=" ++ List.show(&2,W.RegistrationMeta,Observe.registration,registrations) ++ ";nextSystem=" ++ U32.show(nextSystem) ++ ";clock=" ++ Observe.clock(clock) ++ ";journal={" ++ Observe.journal(~S,journal) ++ "}}|systems={writer=" ++ system_header(wn,wi,wm,wa,wc) ++ ";fast=" ++ system_header(fn,fi,fm,fa,fc) ++ ";slow=" ++ system_header(sn,si,sm,sa,sc) ++ ";admin=" ++ system_header(an,ai,am,aa,ac) ++ ";peer=" ++ system_header(pn,pi,pm,pa,pc) ++ ";guard=" ++ system_header(gn,gi,gm,ga,gc) ++ "}"
def observed(~S:Data,~P:Type,~project:P -> P & U32,trace:String,application:Application(~S,~P,~project)) -> String:
  match application:
    case Schedule.Scheduled{App.State{world,Reg.Product{Reg.Product{writer,Reg.Product{fast,Reg.Product{slow,admin,_},_},_},peer,_},guard,handler,_},_,_,_}:observed_raw(~S,~P,~project,trace,world,Product.Owner{Product.Owner{Scope.owner(WriterCompilation(~S,~P,~project),Writer(~S,~P,~project),writer),Product.Owner{Scope.owner(ReaderCompilation(~S,~P,~project),Reader(~S,~P,~project),fast),Product.Owner{Scope.owner(ReaderCompilation(~S,~P,~project),Reader(~S,~P,~project),slow),Scope.owner(AdminCompilation(~S,~P,~project),Admin(~S,~P,~project),admin)}}},Scope.owner(PeerCompilation(~S,~P,~project),Peer(~S,~P,~project),peer)},Scope.owner(Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),NoOps>,GuardOwner(~S,~P,~project),guard),handler)
def publish(~S:Data,~P:Type,~project:P -> P & U32,ids:List<&2,U32>,world:World(~S,~P,~project),nodes:Nodes(~S,~P,~project)) -> World(~S,~P,~project) & (Nodes(~S,~P,~project) & List<&2,U32>):(world,(nodes,ids))
def selected(~S:Data,~P:Type,~project:P -> P & U32,app:Application(~S,~P,~project)) -> IO(Application(~S,~P,~project) & App.Report<String,String>):IO.pure(Application(~S,~P,~project) & App.Report<String,String>,General.run(~S,~components(),~resources(~S,~P,~project),~Unit,~Nodes(~S,~P,~project),~Guard(~S,~P,~project),~Handler,~String,~String,~nodes_dispatch(~S,~P,~project),~guard_dispatch(~S,~P,~project),~handle,~publish(~S,~P,~project),app))
def repeated(~S:Data,~P:Type,~project:P -> P & U32,next:String -> Application(~S,~P,~project) -> IO(String),trace:String,result:Application(~S,~P,~project) & App.Report<String,String>) -> IO(String):
  match result:
    case (application,status):next(trace ++ report(status) ++ "|",application)
def repeat(~S:Data,~P:Type,~project:P -> P & U32,fuel:Nat,trace:String,application:Application(~S,~P,~project)) -> IO(String):
  match fuel:
    case 0n:IO.pure(String,observed(~S,~P,~project,trace,application))
    case 1n+rest:IO.bind(Application(~S,~P,~project) & App.Report<String,String>,String,selected(~S,~P,~project,application),result=>repeated(~S,~P,~project,next=>app=>repeat(~S,~P,~project,rest,next,app),trace,result))
def guarded(~S:Data,~P:Type,~project:P -> P & U32,owners:Nodes(~S,~P,~project),result:Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),NoOps> & Sys.Defined<World(~S,~P,~project),GuardOwner(~S,~P,~project),U32>) -> IO(String):
  match result:
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:guard")
    case (compilation,Sys.Defined{world,guard}):repeat(~S,~P,~project,5n,"",General.build(~S,~components(),~resources(~S,~P,~project),~Unit,~Nodes(~S,~P,~project),~Guard(~S,~P,~project),~Handler,~String,~String,~nodes_dispatch(~S,~P,~project),~guard_dispatch(~S,~P,~project),~available,world,nodes_facts(~S,~P,~project,owners),Conditions.compile_retained_leaf(~String,~S,~Store(),~Resources(~S,~P,~project),~Unit,~NoOps,~U32,~guard_program(~S,~P,~project),~guard_body(~S),~guard_construction(~S,~P,~project),Scope.pack(Decl.Compilation<S,Store(),Store(),Resources(~S,~P,~project),NoOps>,GuardOwner(~S,~P,~project),compilation,guard)),Handler{ALeaf{701},0},[Plan.Edge{1,2},Plan.Edge{1,3},Plan.Edge{2,4},Plan.Edge{3,4}],[App.Binding{3,6}]))
def peer_defined(~S:Data,~P:Type,~project:P -> P & U32,writer:WriterNode(~S,~P,~project),fast:ReaderNode(~S,~P,~project),slow:ReaderNode(~S,~P,~project),admin:AdminNode(~S,~P,~project),result:PeerCompilation(~S,~P,~project) & Sys.Defined<World(~S,~P,~project),Peer(~S,~P,~project),U32>) -> IO(String):
  match result:
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:peer")
    case (compilation,Sys.Defined{world,peer}):guarded(~S,~P,~project,Reg.Product{Reg.Product{writer,Reg.Product{fast,Reg.Product{slow,admin,[]},[]},[]},Scope.pack(PeerCompilation(~S,~P,~project),Peer(~S,~P,~project),compilation,peer),[]},Register.define_with_compilation(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~Bool,~guard_program(~S,~P,~project),~guard_body(~S),~Resources(~S,~P,~project),guard_construction(~S,~P,~project),world,"slow-enabled",0))
def admin_defined(~S:Data,~P:Type,~project:P -> P & U32,writer:WriterNode(~S,~P,~project),fast:ReaderNode(~S,~P,~project),slow:ReaderNode(~S,~P,~project),result:AdminCompilation(~S,~P,~project) & Sys.Defined<World(~S,~P,~project),Admin(~S,~P,~project),D.AdminLocal<S,P>>) -> IO(String):
  match result:
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:admin")
    case (compilation,Sys.Defined{world,admin}):peer_defined(~S,~P,~project,writer,fast,slow,Scope.pack(AdminCompilation(~S,~P,~project),Admin(~S,~P,~project),compilation,admin),Register.define_with_compilation(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Unit,~NoOps,~U32,~String,~String,~peer_program(~S,~P,~project),~peer_body(~S),~Resources(~S,~P,~project),peer_compilation(~S,~P,~project),world,"peer",0))
def slow_defined(~S:Data,~P:Type,~project:P -> P & U32,writer:WriterNode(~S,~P,~project),fast:ReaderNode(~S,~P,~project),admin:D.AdminLocal<S,P>,result:ReaderCompilation(~S,~P,~project) & Sys.Defined<World(~S,~P,~project),Reader(~S,~P,~project),D.ReaderLocal<S,P>>) -> IO(String):
  match result:
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:slow")
    case (compilation,Sys.Defined{world,slow}):admin_defined(~S,~P,~project,writer,fast,Scope.pack(ReaderCompilation(~S,~P,~project),Reader(~S,~P,~project),compilation,slow),Register.define_with_compilation(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Unit,~D.AdminOps(~S,~P),~D.AdminLocal<S,P>,~String,~String,~D.admin(~S,~Store(),~P,~project),~D.admin_body(~S,~P),~Resources(~S,~P,~project),admin_compilation(~S,~P,~project),world,"admin",admin))
def fast_defined(~S:Data,~P:Type,~project:P -> P & U32,writer:WriterNode(~S,~P,~project),slow:D.ReaderLocal<S,P>,admin:D.AdminLocal<S,P>,result:ReaderCompilation(~S,~P,~project) & Sys.Defined<World(~S,~P,~project),Reader(~S,~P,~project),D.ReaderLocal<S,P>>) -> IO(String):
  match result:
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:fast")
    case (compilation,Sys.Defined{world,fast}):slow_defined(~S,~P,~project,writer,Scope.pack(ReaderCompilation(~S,~P,~project),Reader(~S,~P,~project),compilation,fast),admin,Register.define_with_compilation(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Unit,~D.ReaderOps(~S,~P),~D.ReaderLocal<S,P>,~String,~String,~D.reader(~S,~Store(),~P,~project),~D.reader_body(~S,~P),~Resources(~S,~P,~project),reader_compilation(~S,~P,~project),world,"slow",slow))
def writer_defined(~S:Data,~P:Type,~project:P -> P & U32,fast:D.ReaderLocal<S,P>,slow:D.ReaderLocal<S,P>,admin:D.AdminLocal<S,P>,result:WriterCompilation(~S,~P,~project) & Sys.Defined<World(~S,~P,~project),Writer(~S,~P,~project),D.WriterLocal<P>>) -> IO(String):
  match result:
    case (_,Sys.DefinitionRefused{_,_}):IO.pure(String,"ERROR:writer")
    case (compilation,Sys.Defined{world,writer}):fast_defined(~S,~P,~project,Scope.pack(WriterCompilation(~S,~P,~project),Writer(~S,~P,~project),compilation,writer),slow,admin,Register.define_with_compilation(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Unit,~D.ReaderOps(~S,~P),~D.ReaderLocal<S,P>,~String,~String,~D.reader(~S,~Store(),~P,~project),~D.reader_body(~S,~P),~Resources(~S,~P,~project),reader_compilation(~S,~P,~project),world,"fast",fast))
def created(~S:Data,~P:Type,~project:P -> P & U32,pending:List<P>,fast:Event.Reader<S,P,"events">,slow:Event.Reader<S,P,"events">,removable:Event.Reader<S,P,"events">,foreign:Event.Reader<S,P,"events">,result:W.Creation<S,Store(),Resources(~S,~P,~project),Unit>) -> IO(String):
  match result:
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR:world")
    case W.Created{_,world}:writer_defined(~S,~P,~project,D.ReaderLocal{fast,0,[]},D.ReaderLocal{slow,0,[]},D.AdminLocal{Some{removable},Some{foreign},[],[],0,[]},Register.define_with_compilation(~S,~Store(),~Store(),~Resources(~S,~P,~project),~Unit,~D.WriterOps(~P),~D.WriterLocal<P>,~String,~String,~D.writer(~S,~Store(),~P,~project),~D.writer_body(~S,~P),~Resources(~S,~P,~project),writer_compilation(~S,~P,~project),world,"publisher",D.WriterLocal{pending,[],0,[]}))
def empty(_:Unit) -> Store():Product.Owner{Unit{},Unit{}}
def removable_registered(~S:Data,~P:Type,~project:P -> P & U32,pending:List<P>,fast:Event.Reader<S,P,"events">,slow:Event.Reader<S,P,"events">,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> IO(String):
  match result:
    case (_,Event.RegistrationRefused{_}):IO.pure(String,"ERROR:removable-registration")
    case (family,Event.Registered{removable}):created(~S,~P,~project,pending,fast,slow,removable,foreign,W.create(~S,~Store(),~Resources(~S,~P,~project),~Unit,~empty,W.factory(),Layout.ResourceSlot{Layout.initialize(D.layout(~S,~P,~project),Layout.AtLeaf{},family),Layout.unknown_stamp()}))
def slow_registered(~S:Data,~P:Type,~project:P -> P & U32,pending:List<P>,fast:Event.Reader<S,P,"events">,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> IO(String):
  match result:
    case (_,Event.RegistrationRefused{_}):IO.pure(String,"ERROR:slow-registration")
    case (family,Event.Registered{slow}):removable_registered(~S,~P,~project,pending,fast,slow,foreign,Event.register(~S,~P,~"events",Event.Retained{},family))
def fast_registered(~S:Data,~P:Type,~project:P -> P & U32,pending:List<P>,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> IO(String):
  match result:
    case (_,Event.RegistrationRefused{_}):IO.pure(String,"ERROR:fast-registration")
    case (family,Event.Registered{fast}):slow_registered(~S,~P,~project,pending,fast,foreign,Event.register(~S,~P,~"events",Event.Future{},family))
def initial_published(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,pending:List<P>,foreign:Event.Reader<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Publication<P>) -> IO(String):
  match result:
    case (_,Event.PublicationRefused{_}):IO.pure(String,"ERROR:initial-publication")
    case (family,Event.Published{_}):fast_registered(~S,~P,~project,pending,foreign,Event.register(~S,~P,~"events",start,family))
def foreign_registered(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,initial:P,pending:List<P>,primary:Event.Family<S,P,"events">,result:Event.Family<S,P,"events"> & Event.Registration<S,P,"events">) -> IO(String):
  match result:
    case (_,Event.RegistrationRefused{_}):IO.pure(String,"ERROR:foreign-registration")
    case (_,Event.Registered{foreign}):initial_published(~S,~P,~project,start,pending,foreign,Event.publish(~S,~P,~"events",primary,initial))
def foreign_created(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,initial:P,pending:List<P>,primary:Event.Family<S,P,"events">,result:Event.Creation<S,P,"events">) -> IO(String):
  match result:
    case Event.CreationRefused{}:IO.pure(String,"ERROR:foreign-identity")
    case Event.Created{foreign}:foreign_registered(~S,~P,~project,start,initial,pending,primary,Event.register(~S,~P,~"events",Event.Retained{},foreign))
def primary_created(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,initial:P,pending:List<P>,result:Event.Creation<S,P,"events">) -> IO(String):
  match result:
    case Event.CreationRefused{}:IO.pure(String,"ERROR:primary-identity")
    case Event.Created{primary}:IO.bind(Event.Creation<S,P,"events">,String,EventIO.create(~S,~P,~"events"),result=>foreign_created(~S,~P,~project,start,initial,pending,primary,result))
def run_started(~S:Data,~P:Type,~project:P -> P & U32,start:Event.Start,initial:P,pending:List<P>) -> IO(String):
  IO.bind(Event.Creation<S,P,"events">,String,EventIO.create(~S,~P,~"events"),result=>primary_created(~S,~P,~project,start,initial,pending,result))
def run(~S:Data,~P:Type,~project:P -> P & U32,initial:P,pending:List<P>) -> IO(String):
  run_started(~S,~P,~project,Event.Retained{},initial,pending)
def run_future(~S:Data,~P:Type,~project:P -> P & U32,initial:P,pending:List<P>) -> IO(String):
  run_started(~S,~P,~project,Event.Future{},initial,pending)
