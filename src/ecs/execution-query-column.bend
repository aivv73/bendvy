import Base
import ./chunk-column.bend as Col
import ./chunk-shape.bend as Part
import ./execution-composer-layout.bend as L
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./execution-effects.bend as E

type Edit<-S:Data,-C:Type,-P:Type,-Out:Type> is Type:
  Edited{column:Col.Column<S,C>,output:Out}
  Unchanged{column:Col.Column<S,C>,unused:P -> P & Out}

type Update<-S:Data,-C:Type,-O:Type> is Type:
  Updated{column:Col.Column<S,C>,state:O,changed:Bool}

def updated(~S:Data,~layout:L.Layout,~route:L.Route,-O:Type,values:Array<Maybe<&1,L.stored(layout,route)>>,stamps:Array<Life.Stamp>,+index:U32,tick:Tick.Tick,result:L.stored(layout,route) & O) -> Update<S,L.stored(layout,route),O>:
  match result:
    case (owner,state):Updated{Col.Leaf{Array.set(Maybe<&1,L.stored(layout,route)>,values,index,Some{owner}),Col.edit_stamps(stamps,index,tick,True{})},state,True{}}
def effect_rewritten(~S:Data,~layout:L.Layout,~route:L.Route,-O:Type,values:Array<Maybe<&1,L.stored(layout,route)>>,stamps:Array<Life.Stamp>,index:U32,tick:Tick.Tick,result:L.payload(layout,route) & O) -> Update<S,L.stored(layout,route),O>:
  updated(~S,~layout,~route,O,values,stamps,index,tick,L.rewritten(L.payload(layout,route),L.stored(layout,route),O,L.initialize(layout,route),result))
def effect_taken(~S:Data,~F:Type -> Type,~effects:E.Effects<F>,~layout:L.Layout,~route:L.Route,-O:Type,stamps:Array<Life.Stamp>,index:U32,tick:Tick.Tick,state:O,operation:L.payload(layout,route) -> O -> F(L.payload(layout,route) & O),result:Array<Maybe<&1,L.stored(layout,route)>> & Maybe<&1,L.stored(layout,route)>) -> F(Update<S,L.stored(layout,route),O>):
  match result:
    case (values,None{}):E.pure(~F,Update<S,L.stored(layout,route),O>,effects,Updated{Col.Leaf{values,stamps},state,False{}})
    case (values,Some{L.Viewed{payload,_}}):E.map(~F,L.payload(layout,route) & O,Update<S,L.stored(layout,route),O>,effects,operation(payload,state),result=>effect_rewritten(~S,~layout,~route,O,values,stamps,index,tick,result))
def effect_left(-S:Data,-C:Type,-O:Type,half:U32,right:Col.Column<S,C>,result:Update<S,C,O>) -> Update<S,C,O>:
  match result:
    case Updated{left,state,changed}:Updated{Col.Branch{half,left,right},state,changed}
def effect_right(-S:Data,-C:Type,-O:Type,half:U32,left:Col.Column<S,C>,result:Update<S,C,O>) -> Update<S,C,O>:
  match result:
    case Updated{right,state,changed}:Updated{Col.Branch{half,left,right},state,changed}
def effect_branch(~F:Type -> Type,~effects:E.Effects<F>,-S:Data,-C:Type,-P:Type,-O:Type,+half:U32,left:Col.Column<S,C>,right:Col.Column<S,C>,goLeft:Col.Column<S,C> -> O -> (P -> O -> F(P & O)) -> F(Update<S,C,O>),goRight:Col.Column<S,C> -> O -> (P -> O -> F(P & O)) -> F(Update<S,C,O>),state:O,operation:P -> O -> F(P & O),first:Bool) -> F(Update<S,C,O>):
  match first:
    case True{}:E.map(~F,Update<S,C,O>,Update<S,C,O>,effects,goLeft(left,state,operation),result=>effect_left(S,C,O,half,right,result))
    case False{}:E.map(~F,Update<S,C,O>,Update<S,C,O>,effects,goRight(right,state,operation),result=>effect_right(S,C,O,half,left,result))
def effect_tree(~S:Data,~F:Type -> Type,~effects:E.Effects<F>,~layout:L.Layout,~route:L.Route,-O:Type,shape:Part.Shape,column:Col.Column<S,L.stored(layout,route)>,+index:U32,+tick:Tick.Tick,state:O,operation:L.payload(layout,route) -> O -> F(L.payload(layout,route) & O)) -> F(Update<S,L.stored(layout,route),O>):
  match shape column:
    case Part.Leaf{} Col.Leaf{values,stamps}:effect_taken(~S,~F,~effects,~layout,~route,O,stamps,index,tick,state,operation,Array.swap(Maybe<&1,L.stored(layout,route)>,values,index,None{}))
    case Part.Branch{+half,leftShape,rightShape} Col.Branch{_,left,right}:effect_branch(~F,~effects,S,L.stored(layout,route),L.payload(layout,route),O,half,left,right,(column=>state=>operation=>effect_tree(~S,~F,~effects,~layout,~route,O,leftShape,column,index,tick,state,operation)),(column=>state=>operation=>effect_tree(~S,~F,~effects,~layout,~route,O,rightShape,column,U32.sub(index,half),tick,state,operation)),state,operation,U32.is_lt(index,half))
    case _ column:E.pure(~F,Update<S,L.stored(layout,route),O>,effects,Updated{column,state,False{}})
def effect_checked(~S:Data,~F:Type -> Type,~effects:E.Effects<F>,~layout:L.Layout,~route:L.Route,-O:Type,shape:Part.Shape,column:Col.Column<S,L.stored(layout,route)>,index:U32,tick:Tick.Tick,state:O,operation:L.payload(layout,route) -> O -> F(L.payload(layout,route) & O),valid:Bool) -> F(Update<S,L.stored(layout,route),O>):
  match valid:
    case False{}:E.pure(~F,Update<S,L.stored(layout,route),O>,effects,Updated{column,state,False{}})
    case True{}:effect_tree(~S,~F,~effects,~layout,~route,O,shape,column,index,tick,state,operation)
def effect_inspected(~S:Data,~F:Type -> Type,~effects:E.Effects<F>,~layout:L.Layout,~route:L.Route,-O:Type,+index:U32,tick:Tick.Tick,state:O,operation:L.payload(layout,route) -> O -> F(L.payload(layout,route) & O),result:Col.Column<S,L.stored(layout,route)> & Part.Inspection) -> F(Update<S,L.stored(layout,route),O>):
  match result:
    case (column,Part.Inspection{shape,capacity,valid}):effect_checked(~S,~F,~effects,~layout,~route,O,shape,column,index,tick,state,operation,Bool.and(valid,U32.is_lt(index,capacity)))
def effect_edit(~S:Data,~F:Type -> Type,~effects:E.Effects<F>,~layout:L.Layout,~route:L.Route,-O:Type,column:Col.Column<S,L.stored(layout,route)>,index:U32,tick:Tick.Tick,state:O,operation:L.payload(layout,route) -> O -> F(L.payload(layout,route) & O)) -> F(Update<S,L.stored(layout,route),O>):
  effect_inspected(~S,~F,~effects,~layout,~route,O,index,tick,state,operation,Part.inspect(S,L.stored(layout,route),column))

type PureUpdate<-P:Type,-Out:Type> is Type:
  PendingUpdate{transform:P -> P & Out}
  FinishedUpdate{output:Out}
def pure_transformed(-P:Type,-Out:Type,result:P & Out) -> P & PureUpdate<P,Out>:
  match result:
    case (payload,output):(payload,FinishedUpdate{output})
def pure_operation(-P:Type,-Out:Type,payload:P,state:PureUpdate<P,Out>) -> P & PureUpdate<P,Out>:
  match state:
    case PendingUpdate{transform}:pure_transformed(P,Out,transform(payload))
    case FinishedUpdate{output}:(payload,FinishedUpdate{output})
def pure_returned(-S:Data,-C:Type,-P:Type,-Out:Type,result:Update<S,C,PureUpdate<P,Out>>) -> Edit<S,C,P,Out>:
  match result:
    case Updated{column,PendingUpdate{transform},_}:Unchanged{column,transform}
    case Updated{column,FinishedUpdate{output},_}:Edited{column,output}
def edit(~S:Data,~layout:L.Layout,~route:L.Route,-Out:Type,column:Col.Column<S,L.stored(layout,route)>,index:U32,tick:Tick.Tick,transform:L.payload(layout,route) -> L.payload(layout,route) & Out) -> Edit<S,L.stored(layout,route),L.payload(layout,route),Out>:
  pure_returned(S,L.stored(layout,route),L.payload(layout,route),Out,effect_edit(~S,~E.Identity,~E.identity(),~layout,~route,PureUpdate<L.payload(layout,route),Out>,column,index,tick,PendingUpdate{transform},pure_operation(L.payload(layout,route),Out)))
