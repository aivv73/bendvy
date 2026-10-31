import Base
import ./execution-effects.bend as Effects
import ./chunk-column.bend as C
import ./lifecycle.bend as L
import ./change-tick.bend as Tick

type Error<-E:Data> is Data:
  Error{index:U32,value:E}
type Run<-S:Data,-A:Type,-B:Type,-E:Data> is Type:
  Run{read:C.Column<S,A>,write:C.Column<S,B>,errors:List<&2,Error<E>>,aligned:Bool}

type Selection is Data:
  All{}
  Selected{indices:List<&2,U32>}
  Filtered{indices:List<&2,U32>,filter:L.Filter,cursor:Maybe<&2,Tick.Tick>}
def contains(+index:U32,indices:List<&2,U32>) -> Bool:
  match indices:
    case []: False{}
    case current <> rest: U32.is_eq(index,current) || contains(index,rest)
def eligible(index:U32,stamp:L.Stamp,tick:Tick.Tick,selection:Selection) -> Bool:
  match selection:
    case All{}: True{}
    case Selected{indices}: contains(index,indices)
    case Filtered{indices,filter,cursor}:Bool.and(contains(index,indices),L.matches(filter,stamp,cursor,tick))
type Layout is Data:
  LayoutLeaf{}
  LayoutBranch{half:U32,left:Layout,right:Layout}
def layout_join(~S:Data,~A:Type,+half:U32,left:C.Column<S,A> & Layout,right:C.Column<S,A> & Layout) -> C.Column<S,A> & Layout:
  match left right:
    case Tuple{l,ls} Tuple{r,rs}: (C.Branch{half,l,r},LayoutBranch{half,ls,rs})
def layout(~S:Data,~A:Type,column:C.Column<S,A>) -> C.Column<S,A> & Layout:
  match column:
    case C.Leaf{values,stamps}: (C.Leaf{values,stamps},LayoutLeaf{})
    case C.Branch{+half,left,right}: layout_join(~S,~A,half,layout(~S,~A,left),layout(~S,~A,right))
def same(left:Layout,right:Layout) -> Bool:
  match left right:
    case LayoutLeaf{} LayoutLeaf{}: True{}
    case LayoutBranch{lh,ll,lr} LayoutBranch{rh,rl,rr}: U32.is_eq(lh,rh) && same(ll,rl) && same(lr,rr)
    case _ _: False{}
# Sequential row traversal threads its physical columns and affine output owner.
# Context is reusable selection data; it cannot contain affine payload owners.
type OutputRow<-A:Type,-B:Type,-O:Type,-E:Data> is Type:
  OutputRow{read:Maybe<&1,A>,write:Maybe<&1,B>,stamp:L.Stamp,output:O,errors:List<&2,Error<E>>}
type OutputValues<-A:Type,-B:Type,-O:Type,-E:Data> is Type:
  OutputValues{read:Array<Maybe<&1,A>>,write:Array<Maybe<&1,B>>,stamps:Array<L.Stamp>,output:O,errors:List<&2,Error<E>>,aligned:Bool}
type OutputRun<-S:Data,-A:Type,-B:Type,-O:Type,-E:Data> is Type:
  OutputRun{read:C.Column<S,A>,write:C.Column<S,B>,output:O,errors:List<&2,Error<E>>,aligned:Bool}
def output_result(~A:Type,~B:Type,~O:Type,~E:Data,read:A,index:U32,stamp:L.Stamp,result:B & (O & Maybe<&2,E>)) -> OutputRow<A,B,O,E>:
  match result:
    case (write,(output,None{})):OutputRow{Some{read},Some{write},stamp,output,[]}
    case (write,(output,Some{error})):OutputRow{Some{read},Some{write},stamp,output,[Error{index,error}]}
def output_values(~A:Type,~B:Type,~O:Type,~E:Data,result:OutputRow<A,B,O,E>) -> OutputValues<A,B,O,E>:
  match result:
    case OutputRow{read,write,stamp,output,errors}:OutputValues{ALeaf{read},ALeaf{write},ALeaf{stamp},output,errors,True{}}
def output_values_join(~A:Type,~B:Type,~O:Type,~E:Data,leftRead:Array<Maybe<&1,A>>,leftWrite:Array<Maybe<&1,B>>,leftStamps:Array<L.Stamp>,leftErrors:List<&2,Error<E>>,leftAligned:Bool,right:OutputValues<A,B,O,E>) -> OutputValues<A,B,O,E>:
  match right:
    case OutputValues{read,write,stamps,output,errors,aligned}:OutputValues{ANode{leftRead,read},ANode{leftWrite,write},ANode{leftStamps,stamps},output,List.append(&2,Error<E>,leftErrors,errors),Bool.and(leftAligned,aligned)}
def output_leaf_run(~S:Data,~A:Type,~B:Type,~O:Type,~E:Data,readStamps:Array<L.Stamp>,result:OutputValues<A,B,O,E>) -> OutputRun<S,A,B,O,E>:
  match result:
    case OutputValues{a,b,stamps,output,errors,aligned}:OutputRun{C.Leaf{a,readStamps},C.Leaf{b,stamps},output,errors,aligned}
def output_join(~S:Data,~A:Type,~B:Type,~O:Type,~E:Data,+half:U32,leftRead:C.Column<S,A>,leftWrite:C.Column<S,B>,leftErrors:List<&2,Error<E>>,leftAligned:Bool,right:OutputRun<S,A,B,O,E>) -> OutputRun<S,A,B,O,E>:
  match right:
    case OutputRun{read,write,output,errors,aligned}:OutputRun{C.Branch{half,leftRead,read},C.Branch{half,leftWrite,write},output,List.append(&2,Error<E>,leftErrors,errors),Bool.and(leftAligned,aligned)}
def effect_Body(~F:Type -> Type,~K:Data,~V:Data,~B:Type,~O:Type,~E:Data) -> Type:
  K -> U32 -> V -> B -> O -> F(B & (O & Maybe<&2,E>))
def effect_projected(~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~body:effect_Body(~F,~K,~V,~B,~O,~E),context:K,write:B,output:O,+index:U32,stamp:L.Stamp,tick:Tick.Tick,result:A & V) -> F(OutputRow<A,B,O,E>):
  match result:
    case (read,view):Effects.map(~F,(B & (O & Maybe<&2,E>)),OutputRow<A,B,O,E>,effects,body(context,index,view,write,output),result => output_result(~A,~B,~O,~E,read,index,L.written(True{},stamp,tick),result))
def effect_allowed(~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),context:K,read:A,write:B,output:O,index:U32,stamp:L.Stamp,tick:Tick.Tick,selected:Bool) -> F(OutputRow<A,B,O,E>):
  match selected:
    case False{}:Effects.pure(~F,OutputRow<A,B,O,E>,effects,OutputRow{Some{read},Some{write},stamp,output,[]})
    case True{}:effect_projected(~F,~effects,~A,~B,~O,~V,~K,~E,~body,context,write,output,index,stamp,tick,project(read))
def effect_row(~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),context:K,read:Maybe<&1,A>,write:Maybe<&1,B>,output:O,+index:U32,+stamp:L.Stamp,+tick:Tick.Tick,selection:Selection) -> F(OutputRow<A,B,O,E>):
  match read write:
    case None{} write:Effects.pure(~F,OutputRow<A,B,O,E>,effects,OutputRow{None{},write,stamp,output,[]})
    case Some{read} None{}:Effects.pure(~F,OutputRow<A,B,O,E>,effects,OutputRow{Some{read},None{},stamp,output,[]})
    case Some{read} Some{write}:effect_allowed(~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,read,write,output,index,stamp,tick,eligible(index,stamp,tick,selection))
def effect_leaf_right(~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~E:Data,left:OutputValues<A,B,O,E>,walk:O -> F(OutputValues<A,B,O,E>)) -> F(OutputValues<A,B,O,E>):
  match left:
    case OutputValues{read,write,stamps,output,errors,aligned}:Effects.map(~F,OutputValues<A,B,O,E>,OutputValues<A,B,O,E>,effects,walk(output),right => output_values_join(~A,~B,~O,~E,read,write,stamps,errors,aligned,right))
def effect_leaf(~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),+context:K,read:Array<Maybe<&1,A>>,write:Array<Maybe<&1,B>>,stamps:Array<L.Stamp>,output:O,+offset:U32,+size:U32,+tick:Tick.Tick,+selection:Selection) -> F(OutputValues<A,B,O,E>):
  match read write stamps:
    case ALeaf{a} ALeaf{b} ALeaf{stamp}:Effects.map(~F,OutputRow<A,B,O,E>,OutputValues<A,B,O,E>,effects,effect_row(~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,a,b,output,offset,stamp,tick,selection),result => output_values(~A,~B,~O,~E,result))
    case ANode{al,ar} ANode{bl,br} ANode{sl,sr}:Effects.bind(~F,OutputValues<A,B,O,E>,OutputValues<A,B,O,E>,effects,effect_leaf(~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,al,bl,sl,output,offset,U32.shr(size),tick,selection),left => effect_leaf_right(~F,~effects,~A,~B,~O,~E,left,output => effect_leaf(~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,ar,br,sr,output,U32.add(offset,U32.shr(size)),U32.shr(size),tick,selection)))
    case a b s:Effects.pure(~F,OutputValues<A,B,O,E>,effects,OutputValues{a,b,s,output,[],False{}})
def effect_branch_right(~S:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~E:Data,+half:U32,left:OutputRun<S,A,B,O,E>,walk:O -> F(OutputRun<S,A,B,O,E>)) -> F(OutputRun<S,A,B,O,E>):
  match left:
    case OutputRun{read,write,output,errors,aligned}:Effects.map(~F,OutputRun<S,A,B,O,E>,OutputRun<S,A,B,O,E>,effects,walk(output),right => output_join(~S,~A,~B,~O,~E,half,read,write,errors,aligned,right))
def effect_rows(~S:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),+context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,+offset:U32,+tick:Tick.Tick,+selection:Selection) -> F(OutputRun<S,A,B,O,E>):
  match read write:
    case C.Leaf{a,sa} C.Leaf{b,sb}:Effects.map(~F,OutputValues<A,B,O,E>,OutputRun<S,A,B,O,E>,effects,effect_leaf(~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,a,b,sb,output,offset,8,tick,selection),result => output_leaf_run(~S,~A,~B,~O,~E,sa,result))
    case C.Branch{+half,al,ar} C.Branch{_,bl,br}:Effects.bind(~F,OutputRun<S,A,B,O,E>,OutputRun<S,A,B,O,E>,effects,effect_rows(~S,~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,al,bl,output,offset,tick,selection),left => effect_branch_right(~S,~F,~effects,~A,~B,~O,~E,half,left,output => effect_rows(~S,~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,ar,br,output,U32.add(offset,half),tick,selection)))
    case a b:Effects.pure(~F,OutputRun<S,A,B,O,E>,effects,OutputRun{a,b,output,[],False{}})
def effect_execute(~S:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,offset:U32,tick:Tick.Tick,selection:Selection,aligned:Bool) -> F(OutputRun<S,A,B,O,E>):
  match aligned:
    case False{}:Effects.pure(~F,OutputRun<S,A,B,O,E>,effects,OutputRun{read,write,output,[],False{}})
    case True{}:effect_rows(~S,~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,read,write,output,offset,tick,selection)
def effect_prepared(~S:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),context:K,output:O,offset:U32,tick:Tick.Tick,selection:Selection,left:C.Column<S,A> & Layout,right:C.Column<S,B> & Layout) -> F(OutputRun<S,A,B,O,E>):
  match left right:
    case Tuple{read,ls} Tuple{write,rs}:effect_execute(~S,~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,read,write,output,offset,tick,selection,same(ls,rs))
def effect_with_output(~S:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:effect_Body(~F,~K,~V,~B,~O,~E),context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,offset:U32,tick:Tick.Tick,selection:Selection) -> F(OutputRun<S,A,B,O,E>):
  effect_prepared(~S,~F,~effects,~A,~B,~O,~V,~K,~E,~project,~body,context,output,offset,tick,selection,layout(~S,~A,read),layout(~S,~B,write))

def with_output(~S:Data,~A:Type,~B:Type,~O:Type,~V:Data,~K:Data,~E:Data,~project:A -> A & V,~body:K -> U32 -> V -> B -> O -> B & (O & Maybe<&2,E>),context:K,read:C.Column<S,A>,write:C.Column<S,B>,output:O,offset:U32,tick:Tick.Tick,selection:Selection) -> OutputRun<S,A,B,O,E>:
  effect_with_output(~S,~Effects.Identity,~Effects.identity(),~A,~B,~O,~V,~K,~E,~project,~body,context,read,write,output,offset,tick,selection)

def unit_result(~B:Type,~E:Data,result:B & Maybe<&2,E>) -> B & (Unit & Maybe<&2,E>):
  match result:
    case (owner,error):(owner,(Unit{},error))
def unit_body(~B:Type,~V:Data,~E:Data,~body:U32 -> V -> B -> B & Maybe<&2,E>,_:Unit,index:U32,view:V,owner:B,_:Unit) -> B & (Unit & Maybe<&2,E>):
  unit_result(~B,~E,body(index,view,owner))
def unit_run(~S:Data,~A:Type,~B:Type,~E:Data,result:OutputRun<S,A,B,Unit,E>) -> Run<S,A,B,E>:
  match result:
    case OutputRun{read,write,_,errors,aligned}:Run{read,write,errors,aligned}
def selected(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick,selection:Selection) -> Run<S,A,B,E>:
  unit_run(~S,~A,~B,~E,with_output(~S,~A,~B,~Unit,~V,~Unit,~E,~project,~unit_body(~B,~V,~E,~body),Unit{},read,write,Unit{},offset,tick,selection))
def serial(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick) -> Run<S,A,B,E>:
  selected(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,All{})
def serial_selected(~S:Data,~A:Type,~B:Type,~V:Data,~E:Data,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,read:C.Column<S,A>,write:C.Column<S,B>,offset:U32,tick:Tick.Tick,selection:Selection) -> Run<S,A,B,E>:
  selected(~S,~A,~B,~V,~E,~project,~body,read,write,offset,tick,selection)
