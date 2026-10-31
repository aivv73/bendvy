import Base
import ./world.bend as W
import ./registration.bend as Reg
import ./execution-system.bend as Sys
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./change-tick.bend as Tick

type Detached<-System:Type> is Type:
  Detached{system:System}
type Retirement<-World:Type,-System:Type> is Type:
  Retired{world:World,detached:Detached<System>}
  RetirementRefused{world:World,system:System}
type Restoration<-World:Type,-System:Type> is Type:
  Restored{world:World,system:System}
  RestorationRefused{world:World,detached:Detached<System>}
type Identity is Data:
  Identity{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:Maybe<&2,Tick.Tick>}
type Released<-Local:Type> is Type:
  Released{identity:Identity,local:Local}

def retired(~World:Type,~System:Type,system:System,result:World & Bool) -> Retirement<World,System>:
  match result:
    case (world,False{}):RetirementRefused{world,system}
    case (world,True{}):Retired{world,Detached{system}}
def retire(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~WE:Data,system:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,WC,WR,WE>) -> Retirement<W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match system:
    case Sys.Owner{+namespace,+id,+name,+access,cursor,local}:retired(~W.World<S,WC,WR,WE>,~Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,Sys.Owner{namespace,id,name,access,cursor,local},Reg.remove(~S,~WC,~WR,~WE,world,namespace,id,name,access))

def contains_id(registrations:List<&2,W.RegistrationMeta>,+id:U32) -> Bool:
  match registrations:
    case []:False{}
    case W.RegistrationMeta{actual,_,_} <> rest:Bool.or(U32.is_eq(actual,id),contains_id(rest,id))
def restored(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~WE:Data,allowed:Bool,system:Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,world:W.World<S,WC,WR,WE>) -> Restoration<W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match allowed system world:
    case False{} system world:RestorationRefused{world,Detached{system}}
    case True{} Sys.Owner{+namespace,+id,+name,+access,cursor,local} W.World{actual,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}:Restored{W.World{actual,allocator,store,resource,events,pending,W.RegistrationMeta{id,name,access} <> registrations,nextSystemId,clock,lifecycle},Sys.Owner{namespace,id,name,access,cursor,local}}
def restore_with_compilation(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~WE:Data,compilation:D.Compilation<S,WC,C,R,Ops>,detached:Detached<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,world:W.World<S,WC,WR,WE>) -> D.Compilation<S,WC,C,R,Ops> & Restoration<W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  match compilation detached world:
    case D.Unsupported{caps,access,recipes} detached world:(D.Unsupported{caps,access,recipes},RestorationRefused{world,detached})
    case D.Supported{D.Declaration{caps,+requirements},recipes} Detached{Sys.Owner{+namespace,+id,+name,+access,cursor,local}} W.World{+actual,allocator,store,resource,events,pending,+registrations,+nextSystemId,clock,lifecycle}:
      (D.Supported{D.Declaration{caps,requirements},recipes},restored(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~WE,Bool.and(U32.is_eq(namespace,actual),Bool.and(U32.is_lt(id,nextSystemId),Bool.and(Bool.not(contains_id(registrations,id)),W.access_equal(access,D.keys(requirements))))),Sys.Owner{namespace,id,name,access,cursor,local},W.World{actual,allocator,store,resource,events,pending,registrations,nextSystemId,clock,lifecycle}))
def restoration_result(-Compilation:Type,-World:Type,-System:Type,result:Compilation & Restoration<World,System>) -> Restoration<World,System>:
  match result:
    case (_,restoration):restoration
def restore(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),~WR:Type,~WE:Data,detached:Detached<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>,world:W.World<S,WC,WR,WE>) -> Restoration<W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>:
  restoration_result(D.Compilation<S,WC,C,R,Ops>,W.World<S,WC,WR,WE>,Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>,restore_with_compilation(~S,~WC,~C,~R,~E,~Ops,~Local,~Error,~Out,~declaration,~body,~WR,~WE,Build.compile_framework(~S,~WC,~C,~R,~Ops,~declaration),detached,world))
def release(~S:Data,~WC:Type,~C:Type,~R:Type,~E:Data,~Ops:Data -> (Type -> Type) -> Type -> Type,~Local:Type,~Error:Data,~Out:Data,~declaration:Build.FrameworkProgram(~S,~WC,~C,~R,~Ops),~body:Sys.Body(~S,~Ops,~Local,~Error,~Out),detached:Detached<Sys.Owner<S,WC,C,R,E,Ops,Local,Error,Out,declaration,body>>) -> Released<Local>:
  match detached:
    case Detached{Sys.Owner{namespace,id,name,access,cursor,local}}:Released{Identity{namespace,id,name,access,cursor},local}
