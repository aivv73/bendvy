import ../../src/ecs/execution-effects.bend as Effects
import Base
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
import ../../src/ecs/execution-query-store.bend as Store

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def LocalStore() -> Type:L.columns(~S.SchemaA,S.layout_a())
def Ops(Permit:Data,F:Type -> Type,H:Type) -> Type:Q.GeneralReader<S.SchemaA,H,U32>
def any(value:Maybe<&2,U32>) -> Bool:True{}
def selection(~Permit:Data,~F:Type -> Type,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~LocalStore(),~Unit,~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~F,~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~LocalStore(),~Unit,~H,~B),book:B) -> B & Ops(Permit,F,H):
  Build.general_query(~S.SchemaA,~WC(),~LocalStore(),~Unit,~F,~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Optional{},~any,~H,~B,~query,book)
def declaration(~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):
  builder(Ops,selection(~Permit,~F,~H,~B),book)
def program(~Permit:Data,~token:Permit,~F:Type -> Type,~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S.SchemaA>),~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):
  Build.framework_program(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Ops,~declaration,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)
type Local is Type:
  Local{values:Array<U32>}
def body(~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~H:Type,~caps:Ops(Permit,F,H),scope:H,local:Local) -> F(H & (Local & Sys.Completion<String,Unit>)):
  match local:
    case Local{values}:Effects.pure(~F,H & (Local & Sys.Completion<String,Unit>),effects,(scope,(Local{Array.set(U32,values,0,999)},Sys.BodyError{"must-not-enter",Unit{}})))
def compiled() -> D.Compilation<S.SchemaA,WC(),LocalStore(),Unit,Ops>:
  Build.compile_framework(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Ops,~program)
def define(world:W.World<S.SchemaA,WC(),Unit,Unit>,local:Local) -> Sys.Defined<W.World<S.SchemaA,WC(),Unit,Unit>,Sys.Owner<S.SchemaA,WC(),LocalStore(),Unit,Unit,Ops,Local,String,Unit,program,body>,Local>:
  Registration.define_framework(~S.SchemaA,~WC(),~LocalStore(),~Unit,~Unit,~Ops,~Local,~String,~Unit,~program,~body,~Unit,world,"unsupported-general",local)
