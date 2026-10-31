import Base
import ./execution-composer-layout.bend as L
import ./execution-query-domain.bend as D
import ./execution-query-matches.bend as Q
import ./chunk-shape.bend as Part
import ./chunk-column.bend as Col
import ./owner-product.bend as Product
import ./lifecycle.bend as Life

# A full-layout-indexed framework Book. Ordinary lowering must construct its
# entries from the same closed declaration that provisions H operations.
type Entry is Data:
  Entry{route:L.Route,recipe:Q.Recipe}
type Book<-S:Data,-full:L.Layout> is Data:
  Book{entries:List<&2,Entry>}
def same_route(left:L.Route,right:L.Route) -> Bool:
  match left right:
    case L.AtLeaf{} L.AtLeaf{}:True{}
    case L.InLeft{left} L.InLeft{right}:same_route(left,right)
    case L.InRight{left} L.InRight{right}:same_route(left,right)
    case _ _:False{}
def access_union(left:D.Access,right:D.Access) -> D.Access:
  match left right:
    case D.Access{lr,lw} D.Access{rr,rw}:D.Access{D.union(lr,rr),D.union(lw,rw)}
def access(recipe:Q.Recipe) -> D.Access:
  match recipe:
    case Q.Read{domain}:D.Access{domain,D.Domain{[]}}
    case Q.Write{+domain}:D.Access{domain,domain}
    case Q.Both{left,right}:access_union(access(left),access(right))
def access_entry(recipe:Q.Recipe,next:D.Access,selected:Bool) -> D.Access:
  match selected:
    case False{}:next
    case True{}:access_union(access(recipe),next)
def entry_access(+route:L.Route,entries:List<&2,Entry>) -> D.Access:
  match entries:
    case []:D.Access{D.Domain{[]},D.Domain{[]}}
    case Entry{at,recipe} <> rest:access_entry(recipe,entry_access(route,rest),same_route(route,at))
def family_access(-S:Data,-full:L.Layout,book:Book<S,full>,route:L.Route) -> D.Access:
  match book:
    case Book{entries}:entry_access(route,entries)
def routes_valid(~full:L.Layout,entries:List<&2,Entry>) -> Bool:
  match entries:
    case []:True{}
    case Entry{route,_} <> rest:Bool.and(L.valid(full,route),routes_valid(~full,rest))
def all_recipes_valid(+route:L.Route,+capacity:U32,entries:List<&2,Entry>) -> Bool:
  match entries:
    case []:True{}
    case Entry{at,recipe} <> rest:Bool.and(Bool.or(Bool.not(same_route(route,at)),Q.validate_recipe(capacity,recipe)),all_recipes_valid(route,capacity,rest))

def append_route(prefix:L.Route,+suffix:L.Route) -> L.Route:
  match prefix:
    case L.AtLeaf{}:suffix
    case L.InLeft{rest}:L.InLeft{append_route(rest,suffix)}
    case L.InRight{rest}:L.InRight{append_route(rest,suffix)}
def cached_cell(-P:Type,-V:Data,+offset:U32,+stamp:Life.Stamp,result:Array<Maybe<&1,L.Viewed<P,V>>> & Maybe<&1,L.Viewed<P,V>>) -> Array<Maybe<&1,L.Viewed<P,V>>> & Q.Row<V>:
  match result:
    case (values,None{}):(values,Q.StampedRow{offset,None{},stamp})
    case (values,Some{L.Viewed{owner,+view}}):(Array.set(Maybe<&1,L.Viewed<P,V>>,values,U32.mod(offset,8),Some{L.Viewed{owner,view}}),Q.StampedRow{offset,Some{view},stamp})
def cached_step(-P:Type,-V:Data,rows:List<&2,Q.Row<V>>,result:Array<Maybe<&1,L.Viewed<P,V>>> & Q.Row<V>) -> Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>:
  match result:
    case (values,row):(values,row <> rows)
def cache_stamp(-P:Type,-V:Data,+base:U32,+index:U32,values:Array<Maybe<&1,L.Viewed<P,V>>>,rows:List<&2,Q.Row<V>>,result:Array<Life.Stamp> & Life.Stamp) -> Array<Life.Stamp> & (Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>):
  match result:
    case (stamps,stamp):(stamps,cached_step(P,V,rows,cached_cell(P,V,U32.add(base,index),stamp,Array.swap(Maybe<&1,L.Viewed<P,V>>,values,index,None{}))))
def cache_leaf(-P:Type,-V:Data,fuel:Nat,+base:U32,+index:U32,result:Array<Life.Stamp> & (Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>)) -> Array<Life.Stamp> & (Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>):
  match fuel result:
    case 0n result:result
    case 1n+rest, (stamps,(values,rows)):cache_leaf(P,V,rest,base,U32.add(index,1),cache_stamp(P,V,base,index,values,rows,Array.get(Life.Stamp,stamps,index)))
def cached_leaf(-S:Data,-P:Type,-V:Data,result:Array<Life.Stamp> & (Array<Maybe<&1,L.Viewed<P,V>>> & List<&2,Q.Row<V>>)) -> Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>:
  match result:
    case (stamps,(values,rows)):(Col.Leaf{values,stamps},rows)
def cached_pair(-S:Data,-P:Type,-V:Data,half:U32,left:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>,right:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>) -> Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>:
  match left right:
    case (l,lr), (r,rr):(Col.Branch{half,l,r},List.append(&2,Q.Row<V>,lr,rr))
def cache_column(-S:Data,-P:Type,-V:Data,column:Col.Column<S,L.Viewed<P,V>>,+base:U32) -> Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>:
  match column:
    case Col.Leaf{values,stamps}:cached_leaf(S,P,V,cache_leaf(P,V,8n,base,0,(stamps,(values,[]))))
    case Col.Branch{+half,l,r}:cached_pair(S,P,V,half,cache_column(S,P,V,l,base),cache_column(S,P,V,r,U32.add(base,half)))
def filtered_row(-V:Data,row:Q.Row<V>,rest:List<&2,Q.Row<V>>,selected:Bool) -> List<&2,Q.Row<V>>:
  match selected:
    case False{}:rest
    case True{}:row <> rest
def filter_rows(-V:Data,+domain:D.Domain,rows:List<&2,Q.Row<V>>) -> List<&2,Q.Row<V>>:
  match rows:
    case []:[]
    case +row <> rest:filtered_row(V,row,filter_rows(V,domain,rest),D.contains(domain,Q.row_offset(V,row)))

type Info is Data:
  Info{route:L.Route,capacity:U32,present:D.Domain}
type Description<-S:Data,-full:L.Layout> is Type:
  Description{columns:L.columns(~S,full),info:List<&2,Info>,valid:Bool}
def present_offsets(-V:Data,rows:List<&2,Q.Row<V>>) -> List<&2,U32>:
  match rows:
    case []:[]
    case Q.Row{_,None{}} <> rest:present_offsets(V,rest)
    case Q.Row{offset,Some{_}} <> rest:offset <> present_offsets(V,rest)
    case Q.StampedRow{_,None{},_} <> rest:present_offsets(V,rest)
    case Q.StampedRow{offset,Some{_},_} <> rest:offset <> present_offsets(V,rest)
def described_cache(-S:Data,-P:Type,-V:Data,route:L.Route,capacity:U32,result:Col.Column<S,L.Viewed<P,V>> & List<&2,Q.Row<V>>) -> Col.Column<S,L.Viewed<P,V>> & (Info & Bool):
  match result:
    case (column,rows):(column,(Info{route,capacity,D.Domain{present_offsets(V,rows)}},True{}))
def described_inspection(-S:Data,-P:Type,-V:Data,route:L.Route,result:Col.Column<S,L.Viewed<P,V>> & Part.Inspection) -> Col.Column<S,L.Viewed<P,V>> & (Info & Bool):
  match result:
    case (column,Part.Inspection{_,capacity,False{}}):(column,(Info{route,capacity,D.Domain{[]}},False{}))
    case (column,Part.Inspection{_,capacity,True{}}):described_cache(S,P,V,route,capacity,cache_column(S,P,V,column,0))
def describe_leaf(-S:Data,-P:Type,-V:Data,route:L.Route,column:Col.Column<S,L.Viewed<P,V>>) -> Col.Column<S,L.Viewed<P,V>> & (Info & Bool):
  described_inspection(S,P,V,route,Part.inspect(S,L.Viewed<P,V>,column))
def leaf_description(-S:Data,-P:Type,-V:Data,-Out:Type,make:Col.Column<S,L.Viewed<P,V>> -> Info -> Bool -> Out,result:Col.Column<S,L.Viewed<P,V>> & (Info & Bool)) -> Out:
  match result:
    case (column,(info,valid)):make(column,info,valid)
def described_pair(~S:Data,-ll:L.Layout,-rr:L.Layout,left:Description<S,ll>,right:Description<S,rr>) -> Description<S,L.LayoutPair{ll,rr}>:
  match left right:
    case Description{l,li,lv} Description{r,ri,rv}:Description{Product.Owner{l,r},List.append(&2,Info,li,ri),Bool.and(lv,rv)}
def describe(~S:Data,layout:L.Layout,+route:L.Route,columns:L.columns(~S,layout)) -> Description<S,layout>:
  match layout columns:
    case L.EmptyLayout{} Unit{}:Description{Unit{},[],True{}}
    case L.LayoutLeaf{P,V,refresh,key,accessPolicy} L.ColumnSlot{column}:leaf_description(S,P,V,Description<S,L.LayoutLeaf{P,V,refresh,key,accessPolicy}>,(column => info => valid => Description{L.ColumnSlot{column},[info],valid}),describe_leaf(S,P,V,route,column))
    case L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy} L.ColumnSlot{column}:leaf_description(S,P,V,Description<S,L.ClassifiedLayoutLeaf{P,V,refresh,key,kind,accessPolicy}>,(column => info => valid => Description{L.ColumnSlot{column},[info],valid}),describe_leaf(S,P,V,route,column))
    case L.LayoutPair{ll,rr} Product.Owner{l,r}:described_pair(~S,ll,rr,describe(~S,ll,append_route(route,L.InLeft{L.AtLeaf{}}),l),describe(~S,rr,append_route(route,L.InRight{L.AtLeaf{}}),r))
