import Base
import ../../src/ecs/execution-effects.bend as Effects
import ./declarations.bend as D
import ./payloads.bend as Payload
import ./bodies.bend as Body
import ./contexts.bend as Context
import ../../src/ecs/execution-capture.bend as Capture
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as Access
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-system-lifecycle.bend as Life
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/world.bend as W

def components() -> Layout.Layout:D.components_layout()
def C(~S:Data) -> Type:D.Store(~S)
def R(~S:Data) -> Type:D.Resources(~S)
def World(~S:Data) -> Type:W.World<S,D.Store(~S),D.Resources(~S),Unit>
def LeftOps(Permit:Data,F:Type -> Type,H:Type) -> Type:Access.Writer<H,Payload.Counter,String>
def RightOps(Permit:Data,F:Type -> Type,H:Type) -> Type:Access.Writer<H,Payload.Score,String>

def left_written(-H:Type,state:Array<U32>,capture:Context.Count(),+runs:U32,value:U32,result:H & ResourceStore.Edit<Payload.Counter,String>) -> H & (Body.LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (scope,ResourceStore.Edited{_}):(scope,(Capture.Local{state,capture},Body.completion(U32.is_eq(runs,2),U32.show(runs) ++ "/capture=" ++ U32.show(value))))
    case (scope,ResourceStore.Unchanged{_}):(scope,(Capture.Local{state,capture},Sys.BodyError{"counter-owner-refused",U32.show(runs) ++ "/capture=" ++ U32.show(value)}))
def left_captured(-H:Type,cap:Access.Writer<H,Payload.Counter,String>,scope:H,state:Array<U32>,runs:U32,result:Context.Count() & U32) -> H & (Body.LeftLocal() & Sys.Completion<String,String>):
  match cap result:
    case Access.Writer{_,own,_}, (capture,value):left_written(H,state,capture,runs,value,own(String,scope,Payload.update_counter))
    case Access.UnsupportedWriter{}, (capture,value):(scope,(Capture.Local{state,capture},Sys.BodyError{"counter-writer-unsupported",U32.show(runs) ++ "/capture=" ++ U32.show(value)}))
def left_advanced(-H:Type,cap:Access.Writer<H,Payload.Counter,String>,scope:H,capture:Context.Count(),result:Array<U32> & U32) -> H & (Body.LeftLocal() & Sys.Completion<String,String>):
  match result:
    case (state,runs):left_captured(H,cap,scope,state,runs,Capture.invoke(~Array<U32>,~U32,~U32,~Context.count_step,capture,2))
def left_body(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~caps:LeftOps(Permit,F,H),scope:H,local:Body.LeftLocal()) -> F(H & (Body.LeftLocal() & Sys.Completion<String,String>)):
  match local:
    case Capture.Local{state,capture}:Effects.pure(~F,H & (Body.LeftLocal() & Sys.Completion<String,String>),effects,left_advanced(H,caps,scope,capture,Body.advance(state)))
def right_written(-H:Type,state:Array<U32>,capture:Context.Text(),runs:U32,value:String,result:H & ResourceStore.Edit<Payload.Score,String>) -> H & (Body.RightLocal() & Sys.Completion<String,String>):
  match result:
    case (scope,ResourceStore.Edited{_}):(scope,(Capture.Local{state,capture},Sys.Success{U32.show(runs) ++ "/capture=" ++ value}))
    case (scope,ResourceStore.Unchanged{_}):(scope,(Capture.Local{state,capture},Sys.BodyError{"score-owner-refused",U32.show(runs) ++ "/capture=" ++ value}))
def right_captured(-H:Type,cap:Access.Writer<H,Payload.Score,String>,scope:H,state:Array<U32>,runs:U32,result:Context.Text() & String) -> H & (Body.RightLocal() & Sys.Completion<String,String>):
  match cap result:
    case Access.Writer{_,own,_}, (capture,value):right_written(H,state,capture,runs,value,own(String,scope,Payload.update_score))
    case Access.UnsupportedWriter{}, (capture,value):(scope,(Capture.Local{state,capture},Sys.BodyError{"score-writer-unsupported",U32.show(runs) ++ "/capture=" ++ value}))
def right_advanced(-H:Type,cap:Access.Writer<H,Payload.Score,String>,scope:H,capture:Context.Text(),result:Array<U32> & U32) -> H & (Body.RightLocal() & Sys.Completion<String,String>):
  match result:
    case (state,runs):right_captured(H,cap,scope,state,runs,Capture.invoke(~Context.TextContext,~String,~String,~Context.text_step,capture,"x"))
def right_body(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~caps:RightOps(Permit,F,H),scope:H,local:Body.RightLocal()) -> F(H & (Body.RightLocal() & Sys.Completion<String,String>)):
  match local:
    case Capture.Local{state,capture}:Effects.pure(~F,H & (Body.RightLocal() & Sys.Completion<String,String>),effects,right_advanced(H,caps,scope,capture,Body.advance(state)))

def left_selection(~S:Data,~Permit:Data,~F:Type -> Type,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~C(~S),~R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~C(~S),~R(~S),~H,~B),~rr:Build.ResourceRead(~S,~C(~S),~R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~C(~S),~R(~S),~H,~B),~query:Build.Query(~S,~C(~S),~C(~S),~R(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~C(~S),~C(~S),~R(~S),~H,~B),book:B) -> B & LeftOps(Permit,F,H):
  Build.general_resource_write(~S,~C(~S),~R(~S),~H,~B,~D.resources_layout(),~Layout.InLeft{Layout.AtLeaf{}},~{==},~{==},~rw,book)
def left_declaration(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~C(~S),~C(~S),~R(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(Permit,F,H):
  builder(LeftOps,left_selection(~S,~Permit,~F,~H,~B),book)
def left_kernel(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~C(~S),~C(~S),~R(~S),~Permit,~F,~H,~B),book:B) -> B & LeftOps(Permit,F,H):
  Build.framework_program(~S,~C(~S),~C(~S),~R(~S),~LeftOps,~left_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def right_selection(~S:Data,~Permit:Data,~F:Type -> Type,~H:Type,~B:Type,~cr:Build.ComponentRead(~S,~C(~S),~R(~S),~H,~B),~cw:Build.ComponentWrite(~S,~C(~S),~R(~S),~H,~B),~rr:Build.ResourceRead(~S,~C(~S),~R(~S),~H,~B),~rw:Build.ResourceWrite(~S,~C(~S),~R(~S),~H,~B),~query:Build.Query(~S,~C(~S),~C(~S),~R(~S),~F,~H,~B),~lifecycle:Build.Lifecycle(~S,~C(~S),~C(~S),~R(~S),~H,~B),book:B) -> B & RightOps(Permit,F,H):
  Build.general_resource_write(~S,~C(~S),~R(~S),~H,~B,~D.resources_layout(),~Layout.InRight{Layout.AtLeaf{}},~{==},~{==},~rw,book)
def right_declaration(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S,~C(~S),~C(~S),~R(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(Permit,F,H):
  builder(RightOps,right_selection(~S,~Permit,~F,~H,~B),book)
def right_kernel(~S:Data,~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S>),~H:Type,~B:Type,~builder:Build.Builder(~S,~C(~S),~C(~S),~R(~S),~Permit,~F,~H,~B),book:B) -> B & RightOps(Permit,F,H):
  Build.framework_program(~S,~C(~S),~C(~S),~R(~S),~RightOps,~right_declaration(~S),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def LeftCompilation(~S:Data) -> Type:Decl.Compilation<S,C(~S),C(~S),R(~S),LeftOps>
def left_compilation(~S:Data) -> LeftCompilation(~S):Program.compile_framework(~S,~C(~S),~C(~S),~R(~S),~LeftOps,~left_kernel(~S))
def RightCompilation(~S:Data) -> Type:Decl.Compilation<S,C(~S),C(~S),R(~S),RightOps>
def right_compilation(~S:Data) -> RightCompilation(~S):Program.compile_framework(~S,~C(~S),~C(~S),~R(~S),~RightOps,~right_kernel(~S))
def LeftOwner(~S:Data) -> Type:Sys.Owner<S,C(~S),C(~S),R(~S),Unit,LeftOps,Body.LeftLocal(),String,String,left_kernel(~S),left_body(~S)>
def RightOwner(~S:Data) -> Type:Sys.Owner<S,C(~S),C(~S),R(~S),Unit,RightOps,Body.RightLocal(),String,String,right_kernel(~S),right_body(~S)>
def LeftNode(~S:Data) -> Type:Leaf.Node(~S,~components(),~D.resources_layout(),~Unit,~LeftOps,~Body.LeftLocal(),~String,~String,~left_kernel(~S),~left_body(~S))
def RightNode(~S:Data) -> Type:Leaf.Node(~S,~components(),~D.resources_layout(),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S))
def define_left(~S:Data,world:World(~S),name:String,local:Body.LeftLocal()) -> LeftCompilation(~S) & Sys.Defined<World(~S),LeftOwner(~S),Body.LeftLocal()>:
  Leaf.define_with_compilation(~S,~components(),~D.resources_layout(),~Unit,~LeftOps,~Body.LeftLocal(),~String,~String,~left_kernel(~S),~left_body(~S),left_compilation(~S),world,name,local)
def define_right(~S:Data,world:World(~S),name:String,local:Body.RightLocal()) -> RightCompilation(~S) & Sys.Defined<World(~S),RightOwner(~S),Body.RightLocal()>:
  Leaf.define_with_compilation(~S,~components(),~D.resources_layout(),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S),right_compilation(~S),world,name,local)
def left_node(~S:Data,compilation:LeftCompilation(~S),owner:LeftOwner(~S)) -> LeftNode(~S):Retained.pack(LeftCompilation(~S),LeftOwner(~S),compilation,owner)
def right_node(~S:Data,compilation:RightCompilation(~S),owner:RightOwner(~S)) -> RightNode(~S):Retained.pack(RightCompilation(~S),RightOwner(~S),compilation,owner)
def LeftTree(~S:Data) -> Type:Reg.Product<LeftNode(~S),LeftNode(~S)>
def Nodes(~S:Data) -> Type:Reg.Product<LeftTree(~S),RightNode(~S)>
def left_dispatch(~S:Data) -> LeftNode(~S) -> World(~S) -> U32 -> LeftNode(~S) & (World(~S) & Exec.Invocation<String,String>):
  Leaf.dispatch(~S,~components(),~D.resources_layout(),~Unit,~LeftOps,~Body.LeftLocal(),~String,~String,~left_kernel(~S),~left_body(~S),~left_compilation(~S))
def right_dispatch(~S:Data) -> RightNode(~S) -> World(~S) -> U32 -> RightNode(~S) & (World(~S) & Exec.Invocation<String,String>):
  Leaf.dispatch(~S,~components(),~D.resources_layout(),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S),~right_compilation(~S))
def left_tree_dispatch(~S:Data) -> LeftTree(~S) -> World(~S) -> U32 -> LeftTree(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~LeftNode(~S),~LeftNode(~S),~String,~String,~left_dispatch(~S),~left_dispatch(~S))
def dispatch(~S:Data) -> Nodes(~S) -> World(~S) -> U32 -> Nodes(~S) & (World(~S) & Exec.Invocation<String,String>):Reg.paired_dispatch(~World(~S),~LeftTree(~S),~RightNode(~S),~String,~String,~left_tree_dispatch(~S),~right_dispatch(~S))
def left_facts(~S:Data,node:LeftNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),LeftNode(~S),String,String,left_dispatch(~S)>>:
  Registry.ordinary(~World(~S),~LeftNode(~S),~String,~String,~left_dispatch(~S),Leaf.facts(~S,~components(),~D.resources_layout(),~Unit,~LeftOps,~Body.LeftLocal(),~String,~String,~left_kernel(~S),~left_body(~S),~left_compilation(~S),node))
def right_facts(~S:Data,node:RightNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),RightNode(~S),String,String,right_dispatch(~S)>>:
  Registry.ordinary(~World(~S),~RightNode(~S),~String,~String,~right_dispatch(~S),Leaf.facts(~S,~components(),~D.resources_layout(),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S),~right_compilation(~S),node))
def facts(~S:Data,left:LeftNode(~S),other:LeftNode(~S),right:RightNode(~S)) -> Registry.Facts<Reg.Registry<World(~S),Nodes(~S),String,String,dispatch(~S)>>:
  Registry.paired(~World(~S),~LeftTree(~S),~RightNode(~S),~String,~String,~left_tree_dispatch(~S),~right_dispatch(~S),Registry.paired(~World(~S),~LeftNode(~S),~LeftNode(~S),~String,~String,~left_dispatch(~S),~left_dispatch(~S),left_facts(~S,left),left_facts(~S,other)),right_facts(~S,right))
def publish(~S:Data,_:List<&2,U32>,world:World(~S),nodes:Nodes(~S)) -> World(~S) & (Nodes(~S) & List<&2,U32>):(world,(nodes,[]))
def retired(~S:Data,compilation:RightCompilation(~S),result:Life.Retirement<World(~S),RightOwner(~S)>) -> Life.Retirement<World(~S),RightNode(~S)>:
  match result:
    case Life.Retired{world,Life.Detached{owner}}:Life.Retired{world,Life.Detached{right_node(~S,compilation,owner)}}
    case Life.RetirementRefused{world,owner}:Life.RetirementRefused{world,right_node(~S,compilation,owner)}
def retire_opened(~S:Data,world:World(~S),pair:RightCompilation(~S) & RightOwner(~S)) -> Life.Retirement<World(~S),RightNode(~S)>:
  match pair:
    case (compilation,owner):retired(~S,compilation,Life.retire(~S,~C(~S),~C(~S),~R(~S),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S),~R(~S),~Unit,owner,world))
def retire(~S:Data,node:RightNode(~S),world:World(~S)) -> Life.Retirement<World(~S),RightNode(~S)>:
  retire_opened(~S,world,Retained.unpack(RightCompilation(~S),RightOwner(~S),node))
def restored(~S:Data,result:RightCompilation(~S) & Life.Restoration<World(~S),RightOwner(~S)>) -> Life.Restoration<World(~S),RightNode(~S)>:
  match result:
    case (compilation,Life.Restored{world,owner}):Life.Restored{world,right_node(~S,compilation,owner)}
    case (compilation,Life.RestorationRefused{world,Life.Detached{owner}}):Life.RestorationRefused{world,Life.Detached{right_node(~S,compilation,owner)}}
def reregister_opened(~S:Data,world:World(~S),pair:RightCompilation(~S) & RightOwner(~S)) -> Life.Restoration<World(~S),RightNode(~S)>:
  match pair:
    case (compilation,owner):restored(~S,Life.restore_with_compilation(~S,~C(~S),~C(~S),~R(~S),~Unit,~RightOps,~Body.RightLocal(),~String,~String,~right_kernel(~S),~right_body(~S),~R(~S),~Unit,compilation,Life.Detached{owner},world))
def reregister(~S:Data,node:RightNode(~S),world:World(~S)) -> Life.Restoration<World(~S),RightNode(~S)>:
  reregister_opened(~S,world,Retained.unpack(RightCompilation(~S),RightOwner(~S),node))
