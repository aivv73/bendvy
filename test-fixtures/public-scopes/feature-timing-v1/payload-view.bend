import Base
import ../../../src/ecs/relation-types.bend as G
import ../../../src/ecs/relation-commands.bend as A
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/entity-key.bend as K

type Payload is Type:
  Payload{first:Array<U32>,second:Array<U32>}
def payload(+id:U32) -> Payload:
  Payload{ALeaf{id},ANode{ALeaf{U32.add(id,10)},ALeaf{U32.add(id,20)}}}
def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}}
def parent(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{2,"Parent","Children",G.Hierarchy{}}
def descriptors(~S:Data) -> List<&2,G.Descriptor<S>>:
  [link(~S),parent(~S)]
def record(~S:Data,handle:W.Handle<S>) -> A.Notice<S,U32>:
  match handle:
    case W.Handle{_,key}:A.Original{K.index(key)}

# Preserve every affine Array owner while projecting the complete shared payload.
# No physical tree constructor names enter the matched JSON transport.
def joined(right:Array<U32> & List<&2,U32>,left:Array<U32> & List<&2,U32>) -> Array<U32> & List<&2,U32>:
  (b,other)=right
  (a,values)=left
  (ANode{a,b},List.append(&2,U32,values,other))
def flatten(array:Array<U32>) -> Array<U32> & List<&2,U32>:
  match array:
    case ALeaf{+value}:(ALeaf{value},[value])
    case ANode{left,right}:joined(flatten(right),flatten(left))
def payload_right(first:Array<U32>,values:List<&2,U32>,seen:Array<U32> & List<&2,U32>) -> Payload & List<&2,U32>:
  match seen:
    case (second,other):(Payload{first,second},List.append(&2,U32,values,other))
def payload_left(second:Array<U32>,seen:Array<U32> & List<&2,U32>) -> Payload & List<&2,U32>:
  match seen:
    case (first,values):payload_right(first,values,flatten(second))
def project(payload:Payload) -> Payload & List<&2,U32>:
  match payload:
    case Payload{first,second}:payload_left(second,flatten(first))
