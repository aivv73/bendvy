import Base
import ./execution-effects.bend as E
import ./execution-state-effect.bend as StateEffect
import ./world.bend as W
import ./change-tick.bend as Tick
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-builder.bend as Build
import ./execution-reservation-authority.bend as Effect
import ./execution-reservation-authority.bend as RuntimePermit

type Completion<Error:Data,Out:Data> is Data:
  Success{output:Out}
  BodyError{error:Error,output:Out}
def Body(~S:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data) -> Type:
  @-Permit:Data -> @-F:(Type -> Type) -> @-effects:E.Effects<F> -> @-H:Type -> @-caps:Ops(Permit,F,H) -> H -> Local -> F(H & (Local & Completion<Error,Out>))
type Owner<-S:Data,-WC:Type,-C:Type,-R:Type,-E:Data,-Ops:Data -> (Type -> Type) -> Type -> Type,-Local:Type,-Error:Data,-Out:Data,-declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),-body:Body(~S,~Ops,~Local,~Error,~Out)> is Type:
  Owner{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>,local:Local}
type Defined<-World:Type,-System:Type,-Local:Type> is Type:
  Defined{world:World,system:System}
  DefinitionRefused{world:World,local:Local}
type RunResult<-World:Type,-System:Type,Error:Data,Out:Data> is Type:
  Executed{world:World,system:System,completion:Completion<Error,Out>}
  Refused{world:World,system:System}

def registered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),namespace:U32,name:String,access:List<&2,String>,local:Local,result:W.World<S,C,R,E> & W.Registration) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,W.RegistrationRejected{_}):DefinitionRefused{world,local}
    case (world,W.Registered{id}):Defined{world,Owner{namespace,id,name,access,None{},local}}
def named_compilation(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),+name:String,local:Local,world:W.World<S,C,R,E>,namespace:U32,compilation:D.Compilation<S,C,C,R,Ops>) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match compilation:
    case D.Unsupported{_,_,_}:DefinitionRefused{world,local}
    case D.Supported{D.Declaration{_,access},_}:
      +keys = D.keys(access)
      registered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,namespace,name,keys,local,W.register(~S,~C,~R,~E,world,name,keys))
def named(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),+name:String,local:Local,result:W.World<S,C,R,E> & U32) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  match result:
    case (world,namespace):named_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,name,local,world,namespace,Build.compile_framework(~S,~C,~C,~R,~Ops,~declaration))

def define_framework(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),world:W.World<S,C,R,E>,name:String,local:Local) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Local>:
  named(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,name,local,W.namespace(~S,~C,~R,~E,world))
def returned(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),admin:State.Administration<S,C,R,E>,namespace:U32,id:U32,name:String,access:List<&2,String>,+tick:Tick.Tick,result:State.Invocation<S> & (State.Scope<S,C,R> & (Local & Completion<Error,Out>))) -> RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match result:
    case (invocation,(scope,(local,completion))):Executed{W.leave_run(~S,~C,~R,~E,State.reassemble(~S,~C,~R,~E,admin,invocation,scope)),Owner{namespace,id,name,access,Some{tick},local},completion}

def verified_registration(~S:Data,~C:Type,~R:Type,~E:Data,same:Bool,result:W.World<S,C,R,E> & Bool) -> W.World<S,C,R,E> & Bool:
  match result:
    case (world,registered):(world,Bool.and(same,registered))
def trusted_run_scope(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),grant:RuntimePermit.Grant,compilation:D.Compilation<S,C,C,R,Ops>,namespace:U32,+id:U32,name:String,access:List<&2,String>,prior:Maybe<&2,Tick.Tick>,local:Local,+tick:Tick.Tick,separated:State.Administration<S,C,R,E> & (State.Invocation<S> & State.Scope<S,C,R>)) -> D.Compilation<S,C,C,R,Ops> & RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match separated:
    case (admin,(invocation,scope)):(compilation,returned(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,admin,namespace,id,name,access,tick,body(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),StateEffect.dictionary(~State.Invocation<S>),State.Scope<S,C,R>,compiledCaps,State.window(~S,~C,~R,scope,prior),local)(State.admit(~S,id,grant,invocation))))
def trusted_run_entered(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),grant:RuntimePermit.Grant,compilation:D.Compilation<S,C,C,R,Ops>,namespace:U32,id:U32,name:String,access:List<&2,String>,prior:Maybe<&2,Tick.Tick>,local:Local,entered:W.World<S,C,R,E> & Tick.Tick) -> D.Compilation<S,C,C,R,Ops> & RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match entered:
    case (world,+tick):trusted_run_scope(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~compiledCaps,grant,compilation,namespace,id,name,access,prior,local,tick,State.separate(~S,~C,~R,~E,world,tick))
def trusted_run_verified(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),grant:RuntimePermit.Grant,compilation:D.Compilation<S,C,C,R,Ops>,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,verified:W.World<S,C,R,E> & Bool) -> D.Compilation<S,C,C,R,Ops> & RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match system verified:
    case system Tuple{world,False{}}:(compilation,Refused{world,system})
    case Owner{namespace,id,name,access,prior,local} Tuple{world,True{}}:trusted_run_entered(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~compiledCaps,grant,compilation,namespace,id,name,access,prior,local,W.enter_run(~S,~C,~R,~E,world))
def trusted_run_namespace(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),grant:RuntimePermit.Grant,compilation:D.Compilation<S,C,C,R,Ops>,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,observed:W.World<S,C,R,E> & U32) -> D.Compilation<S,C,C,R,Ops> & RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match system observed:
    case Owner{+namespace,+id,+name,+access,prior,local} Tuple{world,actual}:trusted_run_verified(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~compiledCaps,grant,compilation,Owner{namespace,id,name,access,prior,local},verified_registration(~S,~C,~R,~E,U32.is_eq(namespace,actual),W.registration_matches(~S,~C,~R,~E,world,id,name,access)))
def trusted_run_retained_compilation(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),grant:RuntimePermit.Grant,compilation:D.Compilation<S,C,C,R,Ops>,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> D.Compilation<S,C,C,R,Ops> & RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  match compilation:
    case D.Unsupported{caps,requirements,recipes}:(D.Unsupported{caps,requirements,recipes},Refused{world,system})
    case D.Supported{actualDeclaration,recipes}:trusted_run_namespace(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~compiledCaps,grant,D.Supported{actualDeclaration,recipes},system,W.namespace(~S,~C,~R,~E,world))
def run_retained_compilation(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),compilation:D.Compilation<S,C,C,R,Ops>,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> D.Compilation<S,C,C,R,Ops> & RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  trusted_run_retained_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~compiledCaps,RuntimePermit.NoStructural{},compilation,system,world)

def run_result(-Compilation:Type,-Result:Type,result:Compilation & Result) -> Result:
  match result:
    case (_,result):result
def trusted_run_compilation(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compiledCaps:Ops(Effect.Granted,StateEffect.Transition(~State.Invocation<S>),State.Scope<S,C,R>),grant:RuntimePermit.Grant,compilation:D.Compilation<S,C,C,R,Ops>,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  run_result(D.Compilation<S,C,C,R,Ops>,RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>,trusted_run_retained_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~compiledCaps,grant,compilation,system,world))
def trusted_run_constructed(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),~compilation:D.Compilation<S,C,C,R,Ops>,grant:RuntimePermit.Grant,system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  trusted_run_compilation(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~D.trusted_construction_caps(~S,~C,~C,~R,~Ops,compilation),grant,compilation,system,world)
def run(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),system:Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,C,R,E>) -> RunResult<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,declaration,body>,Error,Out>:
  trusted_run_constructed(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~Build.compile_framework(~S,~C,~C,~R,~Ops,~declaration),RuntimePermit.NoStructural{},system,world)

def metadata(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),system:Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>) -> Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body> & W.RegistrationMeta:
  match system:
    case Owner{+namespace,+id,+name,+access,cursor,local}:(Owner{namespace,id,name,access,cursor,local},W.RegistrationMeta{id,name,access})

def define(~S:Data,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.Program(~S,~C,~C,~R,~Ops),~body:Body(~S,~Ops,~Local,~Error,~Out),world:W.World<S,C,R,E>,name:String,local:Local) -> Defined<W.World<S,C,R,E>,Owner<S,C,C,R,E,Ops,Local,Error,Out,Build.framework_program(~S,~C,~C,~R,~Ops,~declaration),body>,Local>:
  define_framework(~S,~C,~R,~E,~Ops,~Local,~Error,~Out,~Build.framework_program(~S,~C,~C,~R,~Ops,~declaration),~body,world,name,local)
