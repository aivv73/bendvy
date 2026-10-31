import Base
import ./chunk-column.bend as Col
import ./lifecycle.bend as L

type Shape is Data:
  Leaf{}
  Branch{half:U32,left:Shape,right:Shape}
type Inspection is Data:
  Inspection{shape:Shape,capacity:U32,valid:Bool}

def inspected_leaf(-S:Data,-C:Type,values:Array<Maybe<&1,C>>,valueSize:U32,result:Array<L.Stamp> & U32) -> Col.Column<S,C> & Inspection:
  match result:
    case (stamps,stampSize):(Col.Leaf{values,stamps},Inspection{Leaf{},8,Bool.and(U32.is_eq(valueSize,8),U32.is_eq(stampSize,8))})
def inspect_values(-S:Data,-C:Type,stamps:Array<L.Stamp>,result:Array<Maybe<&1,C>> & U32) -> Col.Column<S,C> & Inspection:
  match result:
    case (values,size):inspected_leaf(S,C,values,size,Array.size(L.Stamp,stamps))
def inspected_right(-S:Data,-C:Type,+half:U32,left:Col.Column<S,C>,li:Inspection,result:Col.Column<S,C> & Inspection) -> Col.Column<S,C> & Inspection:
  match li result:
    case Inspection{ls,+lc,lv}, (right,Inspection{rs,rc,rv}):(Col.Branch{half,left,right},Inspection{Branch{half,ls,rs},U32.add(half,half),Bool.and(lv,Bool.and(rv,Bool.and(U32.is_eq(lc,half),Bool.and(U32.is_eq(rc,half),U32.is_le(half,2147483647)))))})
def inspected_pair(-S:Data,-C:Type,half:U32,leftResult:Col.Column<S,C> & Inspection,rightResult:Col.Column<S,C> & Inspection) -> Col.Column<S,C> & Inspection:
  match leftResult:
    case (left,li):inspected_right(S,C,half,left,li,rightResult)
def inspect(-S:Data,-C:Type,column:Col.Column<S,C>) -> Col.Column<S,C> & Inspection:
  match column:
    case Col.Leaf{values,stamps}:inspect_values(S,C,stamps,Array.size(Maybe<&1,C>,values))
    case Col.Branch{half,left,right}:inspected_pair(S,C,half,inspect(S,C,left),inspect(S,C,right))
