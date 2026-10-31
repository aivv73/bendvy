import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./app-a-systems.bend as Systems
import ./app-a-payloads.bend as P
import ./app-a-commands.bend as Author
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-system-registration.bend as Register
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-executor.bend as Exec

def Resources() -> Type:L.resources(~P.AuditWorkshop,Author.resources())
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<P.AuditWorkshop>),~H:Type,~B:Type,~builder:Build.Builder(~P.AuditWorkshop,~Systems.Columns(),~Systems.Columns(),~Resources(),~Permit,~F,~H,~B),book:B) -> B & Unit:(book,Unit{})
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Unit,scope:H,runs:U32) -> F(H & (U32 & Sys.Completion<String,Bool>)):
  +count=runs
  Effects.pure(~F,(H & (U32 & Sys.Completion<String,Bool>)),effects,(scope,(U32.add(count,1),Sys.Success{Bool.not(U32.is_eq(count,1))})))
def Compilation() -> Type:Decl.Compilation<P.AuditWorkshop,Systems.Columns(),Systems.Columns(),Resources(),Ops>
def RawOwner() -> Type:Sys.Owner<P.AuditWorkshop,Systems.Columns(),Systems.Columns(),Resources(),Unit,Ops,U32,String,Bool,kernel,body>
# This closed factory supplies the declaration witness; it is not a theorem
# that arbitrary manually constructed bindings carry matching compilations.
def construction() -> Compilation():Build.compile_framework(~P.AuditWorkshop,~Systems.Columns(),~Systems.Columns(),~Resources(),~Ops,~kernel)
def Owner() -> Type:Conditions.RetainedSystem(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~String,~kernel,~body)
def define(world:Systems.World()) -> Compilation() & Sys.Defined<Systems.World(),RawOwner(),U32>:
  Register.define_with_compilation(~P.AuditWorkshop,~Systems.Columns(),~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~String,~Bool,~kernel,~body,~Resources(),construction(),world,"CapturedQueryEnabled",0)
def dispatch() -> Owner() -> Systems.World() -> U32 -> Owner() & (Systems.World() & Exec.Invocation<String,Bool>):
  Conditions.retained_leaf_dispatch(~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~String,~kernel,~body,~construction())
def registry(owner:Owner()) -> Conditions.Registry(~Systems.World(),~Owner(),~String,~dispatch()):
  Conditions.compile_retained_leaf(~String,~P.AuditWorkshop,~Systems.Columns(),~Resources(),~Unit,~Ops,~U32,~kernel,~body,~construction(),owner)
