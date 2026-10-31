import Base
import ./world.bend as W
import ./execution-retained-system.bend as Retained
import ./execution-reservation-authority.bend as Effect
import ./execution-state-effect.bend as StateEffect
import ./execution-state.bend as State
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./dependency-registration.bend as Reg
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec

def Dispatch(~World:Type,~Owners:Type,~Error:Data) -> Type:
  Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Bool>)
def Registry(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error)) -> Type:
  Reg.ConditionRegistry<World,Owners,Error,dispatch>
def System(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool)) -> Type:
  Sys.Owner<S,C,C,R,E,Ops,Local,Error,Bool,declaration,body>

def RetainedSystem(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool)) -> Type:
  Retained.CompiledBinding<D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)>
def retained_leaf_returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),result:D.Compilation<S,C,C,R,Ops> & Sys.RunResult<W.World<S,C,R,E>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),Error,Bool>) -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>):
  match result:
    case (compilation,Sys.Refused{world,system}):(Retained.pack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),compilation,system),(world,Exec.AdmissionRefused{}))
    case (compilation,Sys.Executed{world,system,Sys.Success{output}}):(Retained.pack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),compilation,system),(world,Exec.Completed{output}))
    case (compilation,Sys.Executed{world,system,Sys.BodyError{error,output}}):(Retained.pack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),compilation,system),(world,Exec.BodyError{error,output}))
def retained_leaf_selected_unpacked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~caps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),selected:Bool,node:D.Compilation<S,C,C,R,Ops> & System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),world:W.World<S,C,R,E>) -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>):
  match selected node:
    case False{} node:(Retained.pack_pair(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),node),(world,Exec.AdmissionRefused{}))
    case True{}, (compilation,owner):retained_leaf_returned(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,Sys.run_retained_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Bool,~declaration,~body,~caps,compilation,owner,world))
def retained_leaf_selected(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~caps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),selected:Bool,node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),world:W.World<S,C,R,E>) -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>):
  retained_leaf_selected_unpacked(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~caps,selected,Retained.unpack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),node),world)
def retained_leaf_dispatch_unpacked(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,node:D.Compilation<S,C,C,R,Ops> & System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),world:W.World<S,C,R,E>,id:U32) -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>):
  match node:
    case (compilation,Sys.Owner{namespace,+actual,name,access,cursor,local}):retained_leaf_selected(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~D.trusted_construction_caps(~S,~C,~C,~R,~Ops,construction),U32.is_eq(actual,id),Retained.pack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),compilation,Sys.Owner{namespace,actual,name,access,cursor,local}),world)
def retained_leaf_dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),world:W.World<S,C,R,E>,id:U32) -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) & (W.World<S,C,R,E> & Exec.Invocation<Error,Bool>):
  retained_leaf_dispatch_unpacked(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction,Retained.unpack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),node),world,id)
def compile_retained_leaf_unpacked(~Error:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,node:D.Compilation<S,C,C,R,Ops> & System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)) -> Registry(~W.World<S,C,R,E>,~RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),~Error,~retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction)):
  match node:
    case (D.Supported{D.Declaration{caps,+requirements},recipes},Sys.Owner{namespace,+id,name,access,cursor,local}):Reg.ConditionRegistry{Reg.Registry{Retained.pack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),D.Supported{D.Declaration{caps,requirements},recipes},Sys.Owner{namespace,id,name,access,cursor,local}),[Plan.Node{id,D.qualified(requirements)}]},Reg.condition_permission(D.read_only(requirements),id)}
    case (D.Unsupported{caps,+requirements,recipes},Sys.Owner{namespace,+id,name,access,cursor,local}):Reg.ConditionRegistry{Reg.Registry{Retained.pack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),D.Unsupported{caps,requirements,recipes},Sys.Owner{namespace,id,name,access,cursor,local}),[Plan.Node{id,D.qualified(requirements)}]},Some{Plan.InvalidCondition{id}}}
def compile_retained_leaf(~Error:Data,~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)) -> Registry(~W.World<S,C,R,E>,~RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),~Error,~retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction)):
  compile_retained_leaf_unpacked(~Error,~S,~C,~R,~E,~Ops,~Local,~declaration,~body,~construction,Retained.unpack(D.Compilation<S,C,C,R,Ops>,System(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),node))
def compile_join(~Error:Data,~World:Type,~L:Type,~R:Type,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),l:Registry(~World,~L,~Error,~left),r:Registry(~World,~R,~Error,~right)) -> Registry(~World,~Reg.Product<L,R>,~Error,~Reg.paired_dispatch(~World,~L,~R,~Error,~Bool,~left,~right)):
  Reg.paired_conditions(~World,~L,~R,~Error,~left,~right,l,r)
def compile_empty(~Error:Data,~World:Type) -> Registry(~World,~Unit,~Error,~Reg.empty_dispatch(~World,~Error,~Bool)):
  Reg.empty_conditions(~World,~Error)

def Family(~Error:Data) -> Type:
  @-World:Type -> @-Owners:Type -> @-dispatch:Dispatch(~World,~Owners,~Error) -> Type
def Leaf(~Error:Data,~F:Family(~Error)) -> Type:
  @-S:Data -> @-C:Type -> @-R:Type -> @-E:Data -> @-Ops:(Data -> (Type -> Type) -> Type -> Type) -> @-Local:Type -> @-declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops) -> @-body:Sys.Body(~S,~Ops,~Local,~Error,~Bool) -> @-construction:D.Compilation<S,C,C,R,Ops> -> RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body) -> F(W.World<S,C,R,E>,RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction))
def Join(~Error:Data,~F:Family(~Error)) -> Type:
  @-World:Type -> @-L:Type -> @-R:Type -> @-left:Dispatch(~World,~L,~Error) -> @-right:Dispatch(~World,~R,~Error) -> F(World,L,left) -> F(World,R,right) -> F(World,Reg.Product<L,R>,Reg.paired_dispatch(~World,~L,~R,~Error,~Bool,~left,~right))
def Vacant(~Error:Data,~F:Family(~Error)) -> Type:
  @-World:Type -> F(World,Unit,Reg.empty_dispatch(~World,~Error,~Bool))
def Selection(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error)) -> Type:
  @-F:Family(~Error) -> @-leaf:Leaf(~Error,~F) -> @-pair:Join(~Error,~F) -> @-empty:Vacant(~Error,~F) -> Owners -> F(World,Owners,dispatch)
def Checked(~Error:Data,~World:Type,~Owners:Type,~dispatch:Dispatch(~World,~Owners,~Error)) -> Type:
  Registry(~World,~Owners,~Error,~dispatch)
def compile(~World:Type,~Owners:Type,~Error:Data,~dispatch:Dispatch(~World,~Owners,~Error),~selection:Selection(~World,~Owners,~Error,~dispatch),owners:Owners) -> Registry(~World,~Owners,~Error,~dispatch):
  selection(Checked(~Error),compile_retained_leaf(~Error),compile_join(~Error),compile_empty(~Error),owners)
def leaf(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Bool),~construction:D.Compilation<S,C,C,R,Ops>,~F:Family(~Error),~leaf:Leaf(~Error,~F),~pair:Join(~Error,~F),~empty:Vacant(~Error,~F),node:RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body)) -> F(W.World<S,C,R,E>,RetainedSystem(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body),retained_leaf_dispatch(~S,~C,~R,~E,~Ops,~Local,~Error,~declaration,~body,~construction)):
  leaf(S,C,R,E,Ops,Local,declaration,body,construction,node)
def paired(~World:Type,~L:Type,~R:Type,~Error:Data,~left:Dispatch(~World,~L,~Error),~right:Dispatch(~World,~R,~Error),~leftSelection:Selection(~World,~L,~Error,~left),~rightSelection:Selection(~World,~R,~Error,~right),~F:Family(~Error),~leaf:Leaf(~Error,~F),~pair:Join(~Error,~F),~empty:Vacant(~Error,~F),owners:Reg.Product<L,R>) -> F(World,Reg.Product<L,R>,Reg.paired_dispatch(~World,~L,~R,~Error,~Bool,~left,~right)):
  match owners:
    case Reg.Product{l,r,_}:pair(World,L,R,left,right,leftSelection(F,leaf,pair,empty,l),rightSelection(F,leaf,pair,empty,r))
def empty(~World:Type,~Error:Data,~F:Family(~Error),~leaf:Leaf(~Error,~F),~pair:Join(~Error,~F),~empty:Vacant(~Error,~F),_:Unit) -> F(World,Unit,Reg.empty_dispatch(~World,~Error,~Bool)):
  empty(World)
