import Base
import ./execution-effects.bend as E

def Transition(~I:Type,R:Type) -> Type:
  I -> I & R
def pure(-I:Type,-R:Type,value:R,invocation:I) -> I & R:
  (invocation,value)
def continued(-I:Type,-A:Type,-B:Type,next:A -> I -> I & B,result:I & A) -> I & B:
  match result:
    case (invocation,value):next(value)(invocation)
def bind(-I:Type,-A:Type,-B:Type,action:I -> I & A,next:A -> I -> I & B,invocation:I) -> I & B:
  continued(I,A,B,next,action(invocation))
def mapped(-I:Type,-A:Type,-B:Type,next:A -> B,result:I & A) -> I & B:
  match result:
    case (invocation,value):(invocation,next(value))
def map(-I:Type,-A:Type,-B:Type,action:I -> I & A,next:A -> B,invocation:I) -> I & B:
  mapped(I,A,B,next,action(invocation))
def dictionary(~I:Type) -> E.Effects<Transition(~I)>:
  E.Effects{pure(I),bind(I),map(I)}
