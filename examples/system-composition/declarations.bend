import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./schema.bend as Schema
import ./feature-motion.bend as Motion
import ./feature-labels.bend as Labels
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-access.bend as Access
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-service.bend as Service
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as Resource
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/world.bend as W
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/dependency-registration.bend as Reg

def C() -> Type:Layout.columns(~Schema.Nominal,Schema.components())
def R() -> Type:Layout.resources(~Schema.Nominal,Schema.resources())
def any(_:Maybe<&2,String>) -> Bool:True{}
def motion_combined(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,component:Q.GeneralWriter<Schema.Nominal,H,Motion.Position,String>,result:B & Resource.Writer<H,Motion.Counter,String>) -> B & Motion.Ops(~Schema.Nominal,Permit,F,H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def motion_component(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),result:B & Q.GeneralWriter<Schema.Nominal,H,Motion.Position,String>) -> B & Motion.Ops(~Schema.Nominal,Permit,F,H):
  match result:
    case (book,component):motion_combined(~Permit,~F,~H,~B,component,Build.general_resource_write(~Schema.Nominal,~C(),~R(),~H,~B,~Schema.resources(),~Schema.left(),~{==},~{==},~rw,book))
def motion_grants(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~F,~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~C(),~R(),~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,Permit,F,H):
  motion_component(~Permit,~F,~H,~B,~rw,Build.general_query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~F,~Schema.components(),~Schema.left(),~{==},~{==},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~query,book))
def motion_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,Permit,F,H):
  builder(Motion.Family(~Schema.Nominal),motion_grants(~Permit,~F,~H,~B),book)
def motion_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema.Nominal>),~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Motion.Ops(~Schema.Nominal,Permit,F,H):
  Build.framework_program(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Motion.Family(~Schema.Nominal),~motion_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def motion_compiled() -> D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Motion.Family(~Schema.Nominal)>:
  Program.compile_framework(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Motion.Family(~Schema.Nominal),~motion_kernel)
def MotionOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),C(),R(),Unit,Motion.Family(~Schema.Nominal),Motion.Local<Schema.Nominal>,String,String,motion_kernel,Motion.body(~Schema.Nominal)>
def MotionBinding() -> Type:Retained.CompiledBinding<D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Motion.Family(~Schema.Nominal)>,MotionOwner()>
def MotionNode() -> Type:Leaf.Node(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_kernel,~Motion.body(~Schema.Nominal))
def motion_dispatch() -> MotionNode() -> Schema.World() -> U32 -> MotionNode() & (Schema.World() & Exec.Invocation<String,String>):
  Leaf.dispatch(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_kernel,~Motion.body(~Schema.Nominal),~motion_compiled())
def motion_facts(binding:MotionBinding()) -> Registry.Facts<Reg.Registry<Schema.World(),MotionNode(),String,String,motion_dispatch()>>:
  Registry.ordinary(~Schema.World(),~MotionNode(),~String,~String,~motion_dispatch(),Leaf.facts(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Motion.Family(~Schema.Nominal),~Motion.Local<Schema.Nominal>,~String,~String,~motion_kernel,~Motion.body(~Schema.Nominal),~motion_compiled(),binding))
def labels_combined(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,component:Q.GeneralWriter<Schema.Nominal,H,Labels.Label,String>,result:B & Resource.Writer<H,Service.Slot<Labels.Host>,Service.Status<String>>) -> B & Labels.Ops(~Schema.Nominal,Permit,F,H):
  match result:
    case (book,resource):(book,Cap.Bundle{component,resource})
def labels_component(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),result:B & Q.GeneralWriter<Schema.Nominal,H,Labels.Label,String>) -> B & Labels.Ops(~Schema.Nominal,Permit,F,H):
  match result:
    case (book,component):labels_combined(~Permit,~F,~H,~B,component,Build.general_resource_write(~Schema.Nominal,~C(),~R(),~H,~B,~Schema.resources(),~Schema.host_route(),~{==},~{==},~rw,book))
def labels_grants(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~C(),~R(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~F,~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~C(),~R(),~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,Permit,F,H):
  labels_component(~Permit,~F,~H,~B,~rw,Build.general_query(~Schema.Nominal,~Schema.Store(),~C(),~R(),~F,~Schema.components(),~Schema.right(),~{==},~{==},~{==},~Recipe.WriteRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~query,book))
def labels_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,Permit,F,H):
  builder(Labels.Family(~Schema.Nominal),labels_grants(~Permit,~F,~H,~B),book)
def labels_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema.Nominal>),~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Labels.Ops(~Schema.Nominal,Permit,F,H):
  Build.framework_program(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Labels.Family(~Schema.Nominal),~labels_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def labels_compiled() -> D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Labels.Family(~Schema.Nominal)>:
  Program.compile_framework(~Schema.Nominal,~Schema.Store(),~C(),~R(),~Labels.Family(~Schema.Nominal),~labels_kernel)
def LabelsOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),C(),R(),Unit,Labels.Family(~Schema.Nominal),Labels.Local<Schema.Nominal>,String,String,labels_kernel,Labels.body(~Schema.Nominal)>
def LabelsBinding() -> Type:Retained.CompiledBinding<D.Compilation<Schema.Nominal,Schema.Store(),C(),R(),Labels.Family(~Schema.Nominal)>,LabelsOwner()>
def LabelsNode() -> Type:Leaf.Node(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_kernel,~Labels.body(~Schema.Nominal))
def labels_dispatch() -> LabelsNode() -> Schema.World() -> U32 -> LabelsNode() & (Schema.World() & Exec.Invocation<String,String>):
  Leaf.dispatch(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_kernel,~Labels.body(~Schema.Nominal),~labels_compiled())
def labels_facts(binding:LabelsBinding()) -> Registry.Facts<Reg.Registry<Schema.World(),LabelsNode(),String,String,labels_dispatch()>>:
  Registry.ordinary(~Schema.World(),~LabelsNode(),~String,~String,~labels_dispatch(),Leaf.facts(~Schema.Nominal,~Schema.components(),~Schema.resources(),~Unit,~Labels.Family(~Schema.Nominal),~Labels.Local<Schema.Nominal>,~String,~String,~labels_kernel,~Labels.body(~Schema.Nominal),~labels_compiled(),binding))
def GuardFamily(Permit:Data,F:(Type -> Type),H:Type) -> Type:Cap.Bundle<Access.ResourceRead<H,Service.Status<String>>,Access.ResourceRead<H,String>>
type GuardLocal is Type:GuardLocal{token:Array<U32>,checks:U32}
def guard_combined(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,host:Access.ResourceRead<H,Service.Status<String>>,result:B & Access.ResourceRead<H,String>) -> B & GuardFamily(Permit,F,H):
  match result:
    case (book,optional):(book,Cap.Bundle{host,optional})
def guard_host(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),result:B & Access.ResourceRead<H,Service.Status<String>>) -> B & GuardFamily(Permit,F,H):
  match result:
    case (book,host):guard_combined(~Permit,~F,~H,~B,host,Build.basic_resource_read(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.optional_route(),~{==},~{==},~rr,book))
def guard_grants(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~cw:Build.ComponentWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rr:Build.ResourceRead(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~rw:Build.ResourceWrite(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B),~query:Build.Query(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~F,~H,~B),~lifecycle:Build.Lifecycle(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~H,~B),book:B) -> B & GuardFamily(Permit,F,H):
  guard_host(~Permit,~F,~H,~B,~rr,Build.basic_resource_read(~Schema.Nominal,~Schema.Store(),~Schema.Resources(),~H,~B,~Schema.resources(),~Schema.host_route(),~{==},~{==},~rr,book))
def guard_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~Permit,~F,~H,~B),book:B) -> B & GuardFamily(Permit,F,H):
  builder(GuardFamily,guard_grants(~Permit,~F,~H,~B),book)
def guard_kernel(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<Schema.Nominal>),~H:Type,~B:Type,~builder:Build.Builder(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~Permit,~F,~H,~B),book:B) -> B & GuardFamily(Permit,F,H):
  Build.framework_program(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~GuardFamily,~guard_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def guard_returned(~Permit:Data,~F:(Type -> Type),~H:Type,local:GuardLocal,result:H & Service.Status<String>) -> H & (GuardLocal & Sys.Completion<String,Bool>):
  match local result:
    case GuardLocal{token,checks},(scope,status):(scope,(GuardLocal{token,U32.add(checks,1)},Service.required(~String,Layout.key(Schema.resources(),Schema.host_route()),status)))
def optional_read(~Permit:Data,~F:(Type -> Type),~H:Type,host:Access.ResourceRead<H,Service.Status<String>>,local:GuardLocal,result:H & String) -> H & (GuardLocal & Sys.Completion<String,Bool>):
  match result:
    case (scope,_):guard_returned(~Permit,~F,~H,local,Access.resource_read_field(~H,~Service.Status<String>,host)(scope))
def guard_caps(~Permit:Data,~F:(Type -> Type),~H:Type,caps:GuardFamily(Permit,F,H),scope:H,local:GuardLocal) -> H & (GuardLocal & Sys.Completion<String,Bool>):
  match caps:
    case Cap.Bundle{host,optional}:optional_read(~Permit,~F,~H,host,local,Access.resource_read_field(~H,~String,optional)(scope))
def guard_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:GuardFamily(Permit,F,H),scope:H,local:GuardLocal) -> F(H & (GuardLocal & Sys.Completion<String,Bool>)):
  Effects.pure(~F,(H & (GuardLocal & Sys.Completion<String,Bool>)),effects,guard_caps(~Permit,~F,~H,caps,scope,local))
def GuardOwner() -> Type:Sys.Owner<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),Unit,GuardFamily,GuardLocal,String,Bool,guard_kernel,guard_body>
def GuardCompilation() -> Type:D.Compilation<Schema.Nominal,Schema.Store(),Schema.Store(),Schema.Resources(),GuardFamily>
def guard_compiled() -> GuardCompilation():
  Program.compile_framework(~Schema.Nominal,~Schema.Store(),~Schema.Store(),~Schema.Resources(),~GuardFamily,~guard_kernel)
def GuardBinding() -> Type:Retained.CompiledBinding<GuardCompilation(),GuardOwner()>
def MotionOwners() -> Type:Reg.Product<MotionNode(),MotionNode()>
def LabelsOwners() -> Type:Reg.Product<LabelsNode(),LabelsNode()>
def Owners() -> Type:Reg.Product<MotionOwners(),LabelsOwners()>
def Guards() -> Type:Reg.Product<GuardBinding(),GuardBinding()>
