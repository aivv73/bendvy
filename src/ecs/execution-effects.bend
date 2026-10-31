import Base

def Pure(~F:Type -> Type) -> Type:
  @-R:Type -> R -> F(R)
def Bind(~F:Type -> Type) -> Type:
  @-A:Type -> @-B:Type -> F(A) -> (A -> F(B)) -> F(B)
def Mapping(~F:Type -> Type) -> Type:
  @-A:Type -> @-B:Type -> F(A) -> (A -> B) -> F(B)

type Effects<-F:Type -> Type> is Type:
  Effects{pure:Pure(~F),bind:Bind(~F),map:Mapping(~F)}

def pure(~F:Type -> Type,-R:Type,effects:Effects<F>,value:R) -> F(R):
  match effects:
    case Effects{pure,_,_}:pure(R,value)
def bind(~F:Type -> Type,-A:Type,-B:Type,effects:Effects<F>,action:F(A),next:A -> F(B)) -> F(B):
  match effects:
    case Effects{_,bind,_}:bind(A,B,action,next)
def map(~F:Type -> Type,-A:Type,-B:Type,effects:Effects<F>,action:F(A),next:A -> B) -> F(B):
  match effects:
    case Effects{_,_,map}:map(A,B,action,next)

def Identity(R:Type) -> Type:R
def identity_pure(-R:Type,value:R) -> R:value
def identity_bind(-A:Type,-B:Type,value:A,next:A -> B) -> B:next(value)
def identity_map(-A:Type,-B:Type,value:A,next:A -> B) -> B:next(value)
def identity() -> Effects<Identity>:
  Effects{identity_pure,identity_bind,identity_map}
