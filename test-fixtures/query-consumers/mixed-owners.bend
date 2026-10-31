import Base
import ../../src/ecs/execution-effects.bend as Effects
import ../../src/ecs/execution-generalized-system-leaf.bend as GeneralLeaf
import ../../src/ecs/execution-generalized-root-application.bend as GeneralRoot
import ../../src/ecs/execution-schedule.bend as RootApp
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/dependency-plan.bend as Plan
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-access.bend as ResourceAccess
import ../../src/ecs/execution-resource-policy.bend as ResourcePolicy
import ../../src/ecs/execution-resource-program.bend as ResourceProgram
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/execution-retained-system.bend as Scope
import ./schema.bend as S
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-system-registration.bend as Registration
import ../../src/ecs/world.bend as W

def WC() -> Type:L.columns(~S.SchemaA,S.layout_b())
def any(value:Maybe<&2,U32>) -> Bool:True{}
def combined_array_view(result:Array<U32> & U32,right:Array<U32>) -> Array<U32> & U32:
  match result:
    case (left,value):(ANode{left,right},value)
def combined_array_refresh(owner:Array<U32>) -> Array<U32> & U32:
  match owner:
    case ALeaf{+value}:(ALeaf{value},value)
    case ANode{left,right}:combined_array_view(combined_array_refresh(left),right)
def combined_string_refresh(owner:String) -> String & U32:(owner,7)
def combined_resources() -> L.Layout:
  L.LayoutPair{L.LayoutLeaf{Array<U32>,U32,combined_array_refresh,"combined-array",ResourcePolicy.Ordinary{}},L.LayoutLeaf{String,U32,combined_string_refresh,"combined-string",ResourcePolicy.Ordinary{}}}
def CombinedColumns() -> Type:L.columns(~S.SchemaA,S.layout_b())
def CombinedResources() -> Type:L.resources(~S.SchemaA,combined_resources())
def CombinedWorld() -> Type:W.World<S.SchemaA,WC(),L.resources(~S.SchemaA,combined_resources()),Unit>
def CombinedLeftOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Writer<H,Array<U32>,U32>>
def CombinedRightOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Reader<H,U32>>
type CombinedToken is Type:
  CombinedArray{values:Array<U32>}
  CombinedDeferred{transform:Array<U32> -> Array<U32> & Array<U32>}
type CombinedLocal is Type:
  CombinedLocal{token:CombinedToken}
def combined_left_resource(~H:Type,~B:Type,query:Q.GeneralReader<S.SchemaA,H,U32>,result:B & ResourceAccess.Writer<H,Array<U32>,U32>) -> B & Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Writer<H,Array<U32>,U32>>:
  match result:
    case (book,write):(book,Cap.Bundle{query,write})
def combined_right_resource(~H:Type,~B:Type,query:Q.GeneralReader<S.SchemaA,H,U32>,result:B & ResourceAccess.Reader<H,U32>) -> B & Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Reader<H,U32>>:
  match result:
    case (book,read):(book,Cap.Bundle{query,read})
def combined_left_query(~H:Type,~B:Type,~resource:Build.ResourceWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),result:B & Q.GeneralReader<S.SchemaA,H,U32>) -> B & Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Writer<H,Array<U32>,U32>>:
  match result:
    case (book,query):combined_left_resource(~H,~B,query,Build.general_resource_write(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B,~combined_resources(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~resource,book))
def combined_right_query(~H:Type,~B:Type,~resource:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),query:Q.GeneralReader<S.SchemaA,H,U32>,book:B,own:Bool) -> B & Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Reader<H,U32>>:
  match own:
    case True{}:combined_right_resource(~H,~B,query,Build.general_resource_read(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B,~combined_resources(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~resource,book))
    case False{}:combined_right_resource(~H,~B,query,Build.general_resource_read(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B,~combined_resources(),~L.InRight{L.AtLeaf{}},~{==},~{==},~resource,book))
def combined_right_selected(~own:Bool,~H:Type,~B:Type,~resource:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),result:B & Q.GeneralReader<S.SchemaA,H,U32>) -> B & Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Reader<H,U32>>:
  match result:
    case (book,query):combined_right_query(~H,~B,~resource,query,book,own)
def combined_left_selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~q:Build.Query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~F,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~H,~B),book:B) -> B & CombinedLeftOps(Permit,F,H):
  combined_left_query(~H,~B,~rw,Build.general_query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~F,~S.layout_b(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~q,book))
def combined_right_selection(~own:Bool,~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~CombinedColumns(),~CombinedResources(),~H,~B),~q:Build.Query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~F,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~H,~B),book:B) -> B & CombinedRightOps(Permit,F,H):
  combined_right_selected(~own,~H,~B,~rr,Build.general_query(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~F,~S.layout_b(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~q,book))
def combined_left_program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~F,~H,~B),book:B) -> B & CombinedLeftOps(Permit,F,H):
  builder(CombinedLeftOps,combined_left_selection(~Permit,~F,~H,~B),book)
def combined_right_program(~own:Bool,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~F,~H,~B),book:B) -> B & CombinedRightOps(Permit,F,H):
  builder(CombinedRightOps,combined_right_selection(~own,~Permit,~F,~H,~B),book)
def combined_left_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S.SchemaA>),~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~F,~H,~B),book:B) -> B & CombinedLeftOps(Permit,F,H):
  Build.framework_program(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedLeftOps,~combined_left_program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def combined_right_kernel(~own:Bool,~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S.SchemaA>),~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Permit,~F,~H,~B),book:B) -> B & CombinedRightOps(Permit,F,H):
  Build.framework_program(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedRightOps,~combined_right_program(~own),~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
def combined_left_observed(~H:Type,local:CombinedLocal,result:H & ResourceStore.Lookup<U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,ResourceStore.Viewed{view,_}):(scope,(local,Sys.BodyError{"retained-left",Some{view}}))
    case (scope,ResourceStore.LookupRefused{}):(scope,(local,Sys.BodyError{"read-refused",None{}}))
def combined_left_updated(~H:Type,get:H -> H & ResourceStore.Lookup<U32>,result:H & ResourceStore.Edit<Array<U32>,Array<U32>>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,ResourceStore.Edited{values}):combined_left_observed(~H,CombinedLocal{CombinedArray{values}},get(scope))
    case (scope,ResourceStore.Unchanged{unused}):(scope,(CombinedLocal{CombinedDeferred{unused}},Sys.BodyError{"write-refused",None{}}))
def combined_left_write(~H:Type,write:ResourceAccess.Writer<H,Array<U32>,U32>,scope:H,local:CombinedLocal) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match write local:
    case ResourceAccess.Writer{ResourceAccess.Reader{get},own,_} CombinedLocal{CombinedArray{values}}:combined_left_updated(~H,get,own(Array<U32>,scope,(owner => (ALeaf{42},values))))
    case write local:(scope,(local,Sys.BodyError{"deferred",None{}}))
def combined_left_queried(~H:Type,write:ResourceAccess.Writer<H,Array<U32>,U32>,local:CombinedLocal,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,_):combined_left_write(~H,write,scope,local)
def combined_left_caps(~H:Type,caps:Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Writer<H,Array<U32>,U32>>,scope:H,local:CombinedLocal) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match caps:
    case Cap.Bundle{Q.GeneralReader{query,_},write}:combined_left_queried(~H,write,local,query(scope))
    case caps:(scope,(local,Sys.BodyError{"unsupported-query",None{}}))
def combined_left_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:CombinedLeftOps(Permit,F,H),scope:H,local:CombinedLocal) -> F(H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>)):
  Effects.pure(~F,H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>),effects,combined_left_caps(~H,caps,scope,local))
def combined_right_observed(~H:Type,local:CombinedLocal,result:H & ResourceStore.Lookup<U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match result:
    case (scope,ResourceStore.Viewed{view,_}):(scope,(local,Sys.Success{Some{view}}))
    case (scope,ResourceStore.LookupRefused{}):(scope,(local,Sys.BodyError{"read-refused",None{}}))
def combined_right_queried(~H:Type,read:ResourceAccess.Reader<H,U32>,local:CombinedLocal,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match read result:
    case ResourceAccess.Reader{get}, (scope,_):combined_right_observed(~H,local,get(scope))
    case ResourceAccess.UnsupportedReader{}, (scope,_):(scope,(local,Sys.BodyError{"unsupported-read",None{}}))
def combined_right_caps(~H:Type,caps:Cap.Bundle<Q.GeneralReader<S.SchemaA,H,U32>,ResourceAccess.Reader<H,U32>>,scope:H,local:CombinedLocal) -> H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>):
  match caps:
    case Cap.Bundle{Q.GeneralReader{query,_},read}:combined_right_queried(~H,read,local,query(scope))
    case caps:(scope,(local,Sys.BodyError{"unsupported-query",None{}}))
def combined_right_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:CombinedRightOps(Permit,F,H),scope:H,local:CombinedLocal) -> F(H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>)):
  Effects.pure(~F,H & (CombinedLocal & Sys.Completion<String,Maybe<&2,U32>>),effects,combined_right_caps(~H,caps,scope,local))
# Concrete full-shape specialization; the package owns its actual registered locals.
def CombinedLeftCompilation() -> Type:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>
def CombinedRightCompilation() -> Type:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>
def CombinedLeftOwner() -> Type:Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>
def CombinedRightOwner(~own:Bool) -> Type:Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>
def combined_left_compiled() -> D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>:
  ResourceProgram.compile_framework(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedLeftOps,~combined_left_kernel)
def combined_right_compiled(~own:Bool) -> D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>:
  ResourceProgram.compile_framework(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~CombinedRightOps,~combined_right_kernel(own))
type CombinedRegistration<-own:Bool> is Type:
  CombinedRegistered{world:CombinedWorld(),left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,right:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>>}
  CombinedLeftRejected{world:CombinedWorld(),compilation:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,left:CombinedLocal,right:CombinedLocal}
  CombinedRightRejected{world:CombinedWorld(),left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,compilation:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,right:CombinedLocal}
def combined_right_registered(~own:Bool,left:Scope.CompiledBinding<D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>>,result:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps> & Sys.Defined<CombinedWorld(),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,CombinedLocal>) -> CombinedRegistration<own>:
  match result:
    case (compilation,Sys.Defined{world,system}):CombinedRegistered{world,left,Scope.pack(D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedRightOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedRightOps,CombinedLocal,String,Maybe<&2,U32>,combined_right_kernel(own),combined_right_body>,compilation,system)}
    case (compilation,Sys.DefinitionRefused{world,local}):CombinedRightRejected{world,left,compilation,local}
def combined_left_registered(~own:Bool,right:CombinedLocal,result:D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps> & Sys.Defined<CombinedWorld(),Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,CombinedLocal>) -> CombinedRegistration<own>:
  match result:
    case (compilation,Sys.Defined{world,system}):combined_right_registered(~own,Scope.pack(D.Compilation<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),CombinedLeftOps>,Sys.Owner<S.SchemaA,WC(),CombinedColumns(),CombinedResources(),Unit,CombinedLeftOps,CombinedLocal,String,Maybe<&2,U32>,combined_left_kernel,combined_left_body>,compilation,system),Registration.define_with_compilation(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Unit,~CombinedRightOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_right_kernel(own),~combined_right_body,~L.resources(~S.SchemaA,combined_resources()),combined_right_compiled(~own),world,"combined-right",right))
    case (compilation,Sys.DefinitionRefused{world,local}):CombinedLeftRejected{world,compilation,local,right}
def combined_register(~own:Bool,world:CombinedWorld(),left:CombinedLocal,right:CombinedLocal) -> CombinedRegistration<own>:
  combined_left_registered(~own,right,Registration.define_with_compilation(~S.SchemaA,~WC(),~CombinedColumns(),~CombinedResources(),~Unit,~CombinedLeftOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_left_kernel,~combined_left_body,~L.resources(~S.SchemaA,combined_resources()),combined_left_compiled(),world,"combined-left",left))
def CombinedLeftNode() -> Type:GeneralLeaf.Node(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~CombinedLeftOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_left_kernel,~combined_left_body)
def CombinedRightNode(~own:Bool) -> Type:GeneralLeaf.Node(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~CombinedRightOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_right_kernel(own),~combined_right_body)
def combined_extra_live(result:CombinedWorld() & W.Reservation<S.SchemaA>) -> CombinedWorld():
  match result:
    case (world,W.Reserved{handle}):W.discard_status(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,W.activate(~S.SchemaA,~WC(),~L.resources(~S.SchemaA,combined_resources()),~Unit,world,handle))
    case (world,W.ReservationRejected{_}):world
def RootGuardOps(Permit:Data,F:(Type -> Type),H:Type) -> Type:Unit
def root_guard_kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S.SchemaA>),~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~WC(),~L.resources(~S.SchemaA,combined_resources()),~Permit,~F,~H,~B),book:B) -> B & RootGuardOps(Permit,F,H):(book,Unit{})
def root_guard_result(local:U32,error:Bool) -> Sys.Completion<String,Bool>:
  match error:
    case True{}:Sys.BodyError{"root-guard-error",False{}}
    case False{}:Sys.Success{Bool.not(U32.is_eq(local,1))}
def root_guard_updated(~Permit:Data,~F:(Type -> Type),~H:Type,scope:H,+local:U32) -> H & (U32 & Sys.Completion<String,Bool>):
  (scope,(U32.add(local,1),root_guard_result(local,U32.is_eq(local,4))))
def root_guard_body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:RootGuardOps(Permit,F,H),scope:H,local:U32) -> F(H & (U32 & Sys.Completion<String,Bool>)):
  Effects.pure(~F,H & (U32 & Sys.Completion<String,Bool>),effects,root_guard_updated(~Permit,~F,~H,scope,local))
def RootGuard() -> Type:Sys.Owner<S.SchemaA,WC(),WC(),L.resources(~S.SchemaA,combined_resources()),Unit,RootGuardOps,U32,String,Bool,root_guard_kernel,root_guard_body>
def RootGuardCompilation() -> Type:D.Compilation<S.SchemaA,WC(),WC(),L.resources(~S.SchemaA,combined_resources()),RootGuardOps>
def root_guard_construction() -> RootGuardCompilation():ResourceProgram.compile_framework(~S.SchemaA,~WC(),~WC(),~L.resources(~S.SchemaA,combined_resources()),~RootGuardOps,~root_guard_kernel)
def RetainedRootGuard() -> Type:Scope.CompiledBinding<RootGuardCompilation(),RootGuard()>
def root_guard_text(guard:RootGuard()) -> String:
  match guard:
    case Sys.Owner{_,id,_,_,cursor,local}:"guard=" ++ U32.show(id) ++ "/" ++ U32.show(local) ++ "/" ++ Tick.cursor_show(cursor)
def RootNodes(~own:Bool) -> Type:Reg.Product<CombinedLeftNode(),CombinedRightNode(~own)>
def left_dispatch() -> CombinedLeftNode() -> CombinedWorld() -> U32 -> CombinedLeftNode() & (CombinedWorld() & Exec.Invocation<String,Maybe<&2,U32>>):
  GeneralLeaf.dispatch(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~CombinedLeftOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_left_kernel,~combined_left_body,~combined_left_compiled())
def right_dispatch(~own:Bool) -> CombinedRightNode(~own) -> CombinedWorld() -> U32 -> CombinedRightNode(~own) & (CombinedWorld() & Exec.Invocation<String,Maybe<&2,U32>>):
  GeneralLeaf.dispatch(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~CombinedRightOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_right_kernel(own),~combined_right_body,~combined_right_compiled(~own))
def root_dispatch(~own:Bool) -> RootNodes(~own) -> CombinedWorld() -> U32 -> RootNodes(~own) & (CombinedWorld() & Exec.Invocation<String,Maybe<&2,U32>>):
  Reg.paired_dispatch(~CombinedWorld(),~CombinedLeftNode(),~CombinedRightNode(~own),~String,~Maybe<&2,U32>,~left_dispatch(),~right_dispatch(~own))
def left_facts(node:CombinedLeftNode()) -> Registry.Facts<Reg.Registry<CombinedWorld(),CombinedLeftNode(),String,Maybe<&2,U32>,left_dispatch()>>:
  Registry.ordinary(~CombinedWorld(),~CombinedLeftNode(),~String,~Maybe<&2,U32>,~left_dispatch(),GeneralLeaf.facts(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~CombinedLeftOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_left_kernel,~combined_left_body,~combined_left_compiled(),node))
def right_facts(~own:Bool,node:CombinedRightNode(~own)) -> Registry.Facts<Reg.Registry<CombinedWorld(),CombinedRightNode(~own),String,Maybe<&2,U32>,right_dispatch(~own)>>:
  Registry.ordinary(~CombinedWorld(),~CombinedRightNode(~own),~String,~Maybe<&2,U32>,~right_dispatch(~own),GeneralLeaf.facts(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~CombinedRightOps,~CombinedLocal,~String,~Maybe<&2,U32>,~combined_right_kernel(own),~combined_right_body,~combined_right_compiled(~own),node))
def root_guard_dispatch() -> Conditions.Dispatch(~CombinedWorld(),~RetainedRootGuard(),~String):
  Conditions.retained_leaf_dispatch(~S.SchemaA,~WC(),~CombinedResources(),~Unit,~RootGuardOps,~U32,~String,~root_guard_kernel,~root_guard_body,~root_guard_construction())
def RootApplication(~own:Bool) -> Type:RootApp.Scheduled<App.State<CombinedWorld(),RootNodes(~own),RetainedRootGuard(),U32>>
def root_publish(~own:Bool,ids:List<&2,U32>,world:CombinedWorld(),nodes:RootNodes(~own)) -> CombinedWorld() & (RootNodes(~own) & List<&2,U32>):(world,(nodes,ids))
def root_handle(count:U32,error:String) -> U32 & Exec.Handling:(U32.add(count,1),Exec.Continue{})
def root_available(_:String) -> Bool:True{}
def root_run(~own:Bool,app:RootApplication(~own)) -> RootApplication(~own) & App.Report<String,Maybe<&2,U32>>:
  GeneralRoot.run(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~RootNodes(~own),~RetainedRootGuard(),~U32,~String,~Maybe<&2,U32>,~root_dispatch(~own),~root_guard_dispatch(),~root_handle,~root_publish(~own),app)
def root_output(value:Maybe<&2,U32>) -> String:
  match value:
    case Some{value}:U32.show(value)
    case None{}:"none"
def root_event(value:Exec.Observation<String,Maybe<&2,U32>>) -> String:
  match value:
    case Exec.Ran{id,value}:"ran:" ++ U32.show(id) ++ ":" ++ root_output(value)
    case Exec.BodyFailed{id,error,value}:"body-error:" ++ U32.show(id) ++ ":" ++ error ++ ":" ++ root_output(value)
    case Exec.Skipped{id}:"disabled:" ++ U32.show(id)
    case Exec.ConditionFailed{id,error}:"guard-error:" ++ U32.show(id) ++ ":" ++ error
    case Exec.ConditionRejected{id}:"guard-refused:" ++ U32.show(id)
    case Exec.AdmissionRejected{id}:"body-refused:" ++ U32.show(id)
def root_report(report:App.Report<String,Maybe<&2,U32>>) -> String:
  match report:
    case App.Finished{events}:"finished:" ++ List.show(&2,Exec.Observation<String,Maybe<&2,U32>>,root_event,events)
    case App.Stopped{error,_}:"stopped:" ++ error
    case App.Invalid{_}:"invalid"
type CombinedPipeline<-own:Bool> is Type:
  CombinedExecuted{world:CombinedWorld(),nodes:RootNodes(~own),report:App.Report<String,Maybe<&2,U32>>}
  CombinedRegistrationRefused{inventory:CombinedRegistration<own>}
def root_final(~own:Bool,result:RootApplication(~own) & App.Report<String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case (RootApp.Scheduled{App.State{world,nodes,guard,handler,_},_,_,_},+report):IO.bind(Unit,CombinedPipeline<own>,IO.print("root-final=" ++ root_report(report) ++ "|" ++ root_guard_text(Scope.owner(RootGuardCompilation(),RootGuard(),guard)) ++ "|handler=" ++ U32.show(handler)),_ => IO.pure(CombinedPipeline<own>,CombinedExecuted{world,nodes,report}))
def root_third(~own:Bool,result:RootApplication(~own) & App.Report<String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case (app,report):IO.bind(Unit,CombinedPipeline<own>,IO.print("root-second=" ++ root_report(report)),_ => root_final(~own,root_run(~own,app)))
def root_changed(~own:Bool,app:RootApplication(~own)) -> RootApplication(~own):
  match app:
    case RootApp.Scheduled{App.State{world,nodes,guard,handler,stateBindings},plan,bindings,deferred}:RootApp.Scheduled{App.State{combined_extra_live(W.reserve_id(~S.SchemaA,~WC(),~CombinedResources(),~Unit,world)),nodes,guard,handler,stateBindings},plan,bindings,deferred}
def root_second(~own:Bool,result:RootApplication(~own) & App.Report<String,Maybe<&2,U32>>) -> IO(CombinedPipeline<own>):
  match result:
    case (app,report):IO.bind(Unit,CombinedPipeline<own>,IO.print("root-first=" ++ root_report(report)),_ => root_third(~own,root_run(~own,root_changed(~own,app))))
def root_guard_defined(~own:Bool,left:CombinedLeftNode(),right:CombinedRightNode(~own),result:RootGuardCompilation() & Sys.Defined<CombinedWorld(),RootGuard(),U32>) -> IO(CombinedPipeline<own>):
  match result:
    case (compilation,Sys.Defined{world,guard}):root_second(~own,root_run(~own,GeneralRoot.build(~S.SchemaA,~S.layout_b(),~combined_resources(),~Unit,~RootNodes(~own),~RetainedRootGuard(),~U32,~String,~Maybe<&2,U32>,~root_dispatch(~own),~root_guard_dispatch(),~root_available,world,Registry.paired(~CombinedWorld(),~CombinedLeftNode(),~CombinedRightNode(~own),~String,~Maybe<&2,U32>,~left_dispatch(),~right_dispatch(~own),left_facts(left),right_facts(~own,right)),Conditions.compile_retained_leaf(~String,~S.SchemaA,~WC(),~CombinedResources(),~Unit,~RootGuardOps,~U32,~root_guard_kernel,~root_guard_body,~root_guard_construction(),Scope.pack(RootGuardCompilation(),RootGuard(),compilation,guard)),0,[Plan.Edge{1,2}],[App.Binding{1,3},App.Binding{2,3}])))
    case (_,Sys.DefinitionRefused{world,_}):IO.pure(CombinedPipeline<own>,CombinedRegistrationRefused{CombinedRegistered{world,left,right}})
def combined_root_registered(~own:Bool,registration:CombinedRegistration<own>) -> IO(CombinedPipeline<own>):
  match registration:
    case CombinedRegistered{world,left,right}:root_guard_defined(~own,left,right,Registration.define_with_compilation(~S.SchemaA,~WC(),~WC(),~CombinedResources(),~Unit,~RootGuardOps,~U32,~String,~Bool,~root_guard_kernel,~root_guard_body,~CombinedResources(),root_guard_construction(),world,"root-guard",0))
    case inventory:IO.pure(CombinedPipeline<own>,CombinedRegistrationRefused{inventory})
