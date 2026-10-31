import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./body.bend as B
import ./schema.bend as S
import ./payload.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf

def C() -> Type:L.columns(~S.Workshop,S.components())
def R() -> Type:L.resources(~S.Workshop,S.resources())
def Ops(Permit:Data,F:(Type -> Type),H:Type) -> Type:Q.GeneralReader<S.Workshop,H,P.Tree>
def any(_:Maybe<&2,P.Tree>) -> Bool:True{}
def selection(~Permit:Data,~F:(Type -> Type),~H:Type,~B:Type,~cr:Build.ComponentRead(~S.Workshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~S.Workshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~S.Workshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~S.Workshop,~C(),~R(),~H,~B),~q:Build.Query(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~F,~H,~B),~life:Build.Lifecycle(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~H,~B),book:B) -> B & Ops(Permit,F,H):
  Build.general_query(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~F,~S.components(),~L.AtLeaf{},~{==},~{==},~{==},~Recipe.ReadRows{},~Recipe.AllLive{},~Match.Required{},~any,~H,~B,~q,book)
def program(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~B:Type,~builder:Build.Builder(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):builder(Ops,selection(~Permit,~F,~H,~B),book)
def kernel(~Permit:Data,~token:Permit,~F:(Type -> Type),~effects:Effects.Effects<F>,~request:Permit -> F(W.Reservation<S.Workshop>),~H:Type,~B:Type,~builder:Build.Builder(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Permit,~F,~H,~B),book:B) -> B & Ops(Permit,F,H):Build.framework_program(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Ops,~program,~Permit,~token,~F,~effects,~request,~H,~B,~builder,book)


def view(value:Q.GeneralRow<S.Workshop,P.Tree>) -> String:
  match value:
    case Q.GeneralRow{_,Some{tree}}:P.text(tree)
    case _:"Absent"
def selected(~Permit:Data,~F:(Type -> Type),~H:Type,result:H & Q.GeneralReport<S.Workshop,P.Tree>) -> H & (Unit & Sys.Completion<B.Error,String>):
  match result:
    case (scope,Q.SelectedRows{rows}):(scope,(Unit{},Sys.Success{List.show(&2,Q.GeneralRow<S.Workshop,P.Tree>,view,rows)}))
    case (scope,_):(scope,(Unit{},Sys.BodyError{B.AuditMissing{},"audit refused"}))
def body_caps(~Permit:Data,~F:(Type -> Type),~H:Type,caps:Ops(Permit,F,H),scope:H) -> H & (Unit & Sys.Completion<B.Error,String>):
  match caps:
    case Q.GeneralReader{query,_}:selected(~Permit,~F,~H,query(scope))
    case _:(scope,(Unit{},Sys.BodyError{B.AuditMissing{},"audit unsupported"}))
def body(~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Ops(Permit,F,H),scope:H,_:Unit) -> F(H & (Unit & Sys.Completion<B.Error,String>)):Effects.pure(~F,(H & (Unit & Sys.Completion<B.Error,String>)),effects,body_caps(~Permit,~F,~H,caps,scope))
def compiled() -> Decl.Compilation<S.Workshop,S.Store(~S.Workshop),C(),R(),Ops>:Program.compile_framework(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Ops,~kernel)
def Owner() -> Type:Sys.Owner<S.Workshop,S.Store(~S.Workshop),C(),R(),Unit,Ops,Unit,B.Error,String,kernel,body>
def Node() -> Type:Leaf.Node(~S.Workshop,~S.components(),~S.resources(),~Unit,~Ops,~Unit,~B.Error,~String,~kernel,~body)
