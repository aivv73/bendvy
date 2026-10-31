import Base

type Granted is Data:
  Granted{}

type Grant is Data:
  NoStructural{}
  Structural{}
type Context is Data:
  Context{namespace:U32,id:U32,grant:Grant}
type Permit is Data:
  Authorized{namespace:U32,id:U32}
  Unauthorized{}

# The prepared framework boundary supplies Context from its actual owner and
# closed command declaration. Gameplay bodies quantify an abstract Permit.
def qualified(context:Context) -> Permit:
  match context:
    case Context{namespace,id,Structural{}}:Authorized{namespace,id}
    case Context{_,_,NoStructural{}}:Unauthorized{}
def admitted(permit:Permit,namespace:U32,identity:Maybe<&2,U32>) -> Bool:
  match permit identity:
    case Authorized{actual,id} Some{expected}:Bool.and(U32.is_eq(actual,namespace),U32.is_eq(id,expected))
    case _ _:False{}
