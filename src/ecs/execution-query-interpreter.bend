import Base
import ./chunk-query.bend as Row
import ./execution-query-lifecycle.bend as Lifecycle
import ./execution-query-store.bend as Store
import ./execution-query-admission.bend as Admission
import ./execution-query-recipe.bend as Recipe
import ./execution-query-identity.bend as Id
import ./execution-query-schema.bend as Schema
import ./execution-query-matches.bend as Match
import ./execution-query.bend as Q
import ./execution-builder.bend as Build
import ./execution-state.bend as State
import ./execution-state-effect.bend as StateEffect
import ./execution-effects.bend as Effects
import ./execution-composer-layout.bend as L
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./chunk-column.bend as Column
import ./chunk-shape.bend as Part
import ./execution-query-column.bend as EditColumn
def matched_view_checked(~V:Data,view:Maybe<&2,V>,matched:Bool) -> Q.GeneralLookup<V>:
  match matched:
    case False{}:Q.NotMatched{}
    case True{}:Q.Matched{view}
def matched_view(~V:Data,~predicate:Maybe<&2,V> -> Bool,presence:Match.Presence,+view:Maybe<&2,V>) -> Q.GeneralLookup<V>:
  matched_view_checked(~V,view,Bool.and(Match.membership(V,presence,view),predicate(view)))
def outside_view(~V:Data,~predicate:Maybe<&2,V> -> Bool,presence:Match.Presence,outside:Bool) -> Q.GeneralLookup<V>:
  match outside:
    case False{}:Q.LookupRefused{}
    case True{}:matched_view(~V,~predicate,presence,None{})
def selected_lookup(~V:Data,~predicate:Maybe<&2,V> -> Bool,presence:Match.Presence,offset:U32,capacity:U32,lookup:Store.Lookup<V>) -> Q.GeneralLookup<V>:
  match lookup:
    case Store.Known{view}:matched_view(~V,~predicate,presence,view)
    case Store.OutsideDomain{}:outside_view(~V,~predicate,presence,U32.is_le(capacity,offset))
def query_row(~S:Data,~V:Data,handle:W.Handle<S>,row:Q.GeneralLookup<V>,tail:Q.GeneralReport<S,V>) -> Q.GeneralReport<S,V>:
  match row tail:
    case Q.Matched{view} Q.SelectedRows{rows}:Q.SelectedRows{Q.GeneralRow{handle,view} <> rows}
    case Q.NotMatched{} tail:tail
    case _ _:Q.SelectionRefused{}
type WholeFrame<-S:Data,-full:L.Layout,-route:L.Route,-R:Type> is Type:
  WholeFrame{rest:L.column_rest(~S,full,route),resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,lifecycleView:Notice.View<S>}
def whole_scope(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,frame:WholeFrame<S,full,route,R>,column:Column.Column<S,L.stored(full,route)>) -> State.Scope<S,L.columns(~S,full),R>:
  match frame:
    case WholeFrame{rest,resource,handles,tick,prior,+view}:State.Scope{L.column_put(~S,full,route,rest,L.ColumnSlot{column}),resource,handles,tick,prior,view}
def whole_lookup(~V:Data,view:Maybe<&2,V>,inside:Bool) -> Store.Lookup<V>:
  match inside:
    case True{}:Store.Known{view}
    case False{}:Store.OutsideDomain{}
def whole_cached(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,frame:WholeFrame<S,full,route,R>,+offset:U32,+capacity:U32,result:Column.Column<S,L.stored(full,route)> & Maybe<&2,L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (column,view):(whole_scope(~S,~full,~route,~R,frame,column),selected_lookup(~L.view(full,route),~predicate,presence,offset,capacity,whole_lookup(~L.view(full,route),view,U32.is_lt(offset,capacity))))
def whole_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,+offset:U32,capacity:U32,result:L.column_rest(~S,full,route) & L.ColumnSlot<S,L.stored(full,route),L.key(full,route),L.origin(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (rest,L.ColumnSlot{column}):whole_cached(~S,~full,~route,~R,~presence,~predicate,WholeFrame{rest,resource,handles,tick,prior,view},offset,capacity,Column.view(~S,~L.stored(full,route),~L.view(full,route),~L.read(~L.payload(full,route),~L.view(full,route)),column,offset))
def whole_described_allowed(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>,offset:U32,capacity:U32,allowed:Bool) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope allowed:
    case scope False{}:(scope,Q.NotMatched{})
    case State.Scope{columns,resource,handles,tick,prior,+view} True{}:whole_taken(~S,~full,~route,~R,~presence,~predicate,resource,handles,tick,prior,view,offset,capacity,L.column_take(~S,full,route,columns))
def whole_bound_done(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,capacity:U32,result:L.columns(~S,full) & Bool) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case (columns,selected):whole_described_allowed(~S,~full,~route,~R,~presence,~predicate,State.Scope{columns,resource,handles,tick,prior,view},offset,capacity,selected)
def whole_described(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,+offset:U32,result:Schema.Description<S,full>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match result:
    case Schema.Description{columns,+info,True{}}:whole_bound_done(~S,~full,~route,~R,~presence,~predicate,resource,handles,tick,prior,view,offset,Admission.capacity(Admission.info_at(route,info)),Lifecycle.whole_bound(~S,~full,info,bound,offset,prior,tick,columns))
    case Schema.Description{columns,_,False{}}:(State.Scope{columns,resource,handles,tick,prior,view},Q.LookupRefused{})
def whole_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>,checked:Id.Offset<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope checked:
    case State.Scope{columns,resource,handles,tick,prior,+view} Id.Physical{_,offset}:whole_described(~S,~full,~route,~R,~bound,~presence,~predicate,resource,handles,tick,prior,view,offset,Schema.describe(~S,full,L.AtLeaf{},columns))
    case scope _:(scope,Q.MissingEntity{})
def whole_get(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>,handle:W.Handle<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope:
    case State.Scope{columns,resource,+handles,tick,prior,+view}:whole_physical(~S,~full,~route,~R,~bound,~presence,~predicate,State.Scope{columns,resource,handles,tick,prior,view},Id.captured_offset(~S,handles,handle))
def whole_edit_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,frame:WholeFrame<S,full,route,R>,result:EditColumn.Edit<S,L.stored(full,route),L.payload(full,route),Out>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case EditColumn.Edited{column,out}:(whole_scope(~S,~full,~route,~R,frame,column),Q.GeneralEdited{out})
    case EditColumn.Unchanged{column,unused}:(whole_scope(~S,~full,~route,~R,frame,column),Q.GeneralUnchanged{unused})
def whole_edit_taken(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,offset:U32,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:L.column_rest(~S,full,route) & L.ColumnSlot<S,L.stored(full,route),L.key(full,route),L.origin(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case (rest,L.ColumnSlot{column}):whole_edit_returned(~S,~full,~route,~R,Out,WholeFrame{rest,resource,handles,tick,prior,view},EditColumn.edit(~S,~full,~route,Out,column,offset,tick,transform))
def whole_edit_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,scope:State.Scope<S,L.columns(~S,full),R>,transform:L.payload(full,route) -> L.payload(full,route) & Out,checked:Id.Offset<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match scope checked:
    case State.Scope{columns,resource,handles,tick,prior,+view} Id.Physical{_,offset}:whole_edit_taken(~S,~full,~route,~R,Out,resource,handles,tick,prior,view,offset,transform,L.column_take(~S,full,route,columns))
    case scope _:(scope,Q.GeneralUnchanged{transform})
def whole_edit_matched(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,-Out:Type,handle:W.Handle<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  match result:
    case (State.Scope{columns,resource,+handles,tick,prior,+view},Q.Matched{_}):whole_edit_physical(~S,~full,~route,~R,Out,State.Scope{columns,resource,handles,tick,prior,view},transform,Id.captured_offset(~S,handles,handle))
    case (scope,_):(scope,Q.GeneralUnchanged{transform})
def whole_modify(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,-Out:Type,scope:State.Scope<S,L.columns(~S,full),R>,+handle:W.Handle<S>,transform:L.payload(full,route) -> L.payload(full,route) & Out) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralEdit<L.payload(full,route),Out>:
  whole_edit_matched(~S,~full,~route,~R,Out,handle,transform,whole_get(~S,~full,~route,~R,~bound,~presence,~predicate,scope,handle))

def whole_row_got(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,handle:W.Handle<S>,tail:Q.GeneralReport<S,L.view(full,route)>,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match result:
    case (scope,row):(scope,query_row(~S,~L.view(full,route),handle,row,tail))
def whole_known_physical(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,+info:List<&2,Schema.Info>,scope:State.Scope<S,L.columns(~S,full),R>,checked:Id.Offset<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope checked:
    case State.Scope{columns,resource,handles,+tick,+prior,view} Id.Physical{_,+offset}:whole_bound_done(~S,~full,~route,~R,~presence,~predicate,resource,handles,tick,prior,view,offset,Admission.capacity(Admission.info_at(route,info)),Lifecycle.whole_bound(~S,~full,info,bound,offset,prior,tick,columns))
    case scope _:(scope,Q.MissingEntity{})
def whole_known_get(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,info:List<&2,Schema.Info>,scope:State.Scope<S,L.columns(~S,full),R>,handle:W.Handle<S>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralLookup<L.view(full,route)>:
  match scope:
    case State.Scope{columns,resource,+handles,tick,prior,view}:whole_known_physical(~S,~full,~route,~R,~bound,~presence,~predicate,info,State.Scope{columns,resource,handles,tick,prior,view},Id.captured_offset(~S,handles,handle))
def whole_row_tail(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,info:List<&2,Schema.Info>,+handle:W.Handle<S>,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match result:
    case (scope,tail):whole_row_got(~S,~full,~route,~R,handle,tail,whole_known_get(~S,~full,~route,~R,~bound,~presence,~predicate,info,scope,handle))
def whole_rows(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,+info:List<&2,Schema.Info>,candidates:List<&2,W.Handle<S>>,scope:State.Scope<S,L.columns(~S,full),R>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match candidates:
    case []:(scope,Q.SelectedRows{[]})
    case +handle <> rest:whole_row_tail(~S,~full,~route,~R,~bound,~presence,~predicate,info,handle,whole_rows(~S,~full,~route,~R,~bound,~presence,~predicate,info,rest,scope))
def whole_query_described(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,resource:R,+handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,description:Schema.Description<S,full>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match description:
    case Schema.Description{columns,info,True{}}:whole_rows(~S,~full,~route,~R,~bound,~presence,~predicate,info,handles,State.Scope{columns,resource,handles,tick,prior,view})
    case Schema.Description{columns,_,False{}}:(State.Scope{columns,resource,handles,tick,prior,view},Q.SelectionRefused{})
def whole_query(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,scope:State.Scope<S,L.columns(~S,full),R>) -> State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>:
  match scope:
    case State.Scope{columns,resource,handles,tick,prior,view}:whole_query_described(~S,~full,~route,~R,~bound,~presence,~predicate,resource,handles,tick,prior,view,Schema.describe(~S,full,L.AtLeaf{},columns))

def whole_reader(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool) -> Q.GeneralReader<S,State.Scope<S,L.columns(~S,full),R>,L.view(full,route)>:
  Q.GeneralReader{scope=>whole_query(~S,~full,~route,~R,~bound,~presence,~predicate,scope),scope=>handle=>whole_get(~S,~full,~route,~R,~bound,~presence,~predicate,scope,handle)}
def whole_caps_direct(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,L.columns(~S,full),R>):
  match kind:
    case Recipe.ReadRows{}:whole_reader(~S,~full,~route,~R,~bound,~presence,~predicate)
    case Recipe.WriteRows{}:Q.GeneralWriter{whole_reader(~S,~full,~route,~R,~bound,~presence,~predicate),Out=>scope=>handle=>transform=>whole_modify(~S,~full,~route,~R,~bound,~presence,~predicate,Out,scope,handle,transform)}
def whole_caps(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,same:{C == L.columns(~S,full) : Type},kind:Recipe.QueryKind) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,C,R>):
  %Equal.sym(Type,C,L.columns(~S,full),same) : Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,_,R>)
  whole_caps_direct(~S,~full,~route,~R,~bound,~presence,~predicate,kind)

def selected_handles(~S:Data,~V:Data,rows:List<&2,Q.GeneralRow<S,V>>) -> List<&2,W.Handle<S>>:
  match rows:
    case []:[]
    case Q.GeneralRow{handle,Some{_}} <> rest:handle <> selected_handles(~S,~V,rest)
    case Q.GeneralRow{_,None{}} <> rest:selected_handles(~S,~V,rest)
def requested_member(~S:Data,handle:W.Handle<S>,targets:Q.GeneralTargets<S>) -> Bool:
  match targets:
    case Q.AllMatched{}:True{}
    case Q.ExplicitHandles{requested}:State.member(~S,handle,requested)
def members(~S:Data,requested:List<&2,W.Handle<S>>,+selected:List<&2,W.Handle<S>>) -> Bool:
  match requested:
    case []:True{}
    case handle <> rest:Bool.and(State.member(~S,handle,selected),members(~S,rest,selected))
def row_errors(~E:Data,index:U32,errors:List<&2,Row.Error<E>>,error:Maybe<&2,E>) -> List<&2,Row.Error<E>>:
  match error:
    case None{}:errors
    case Some{value}:Row.Error{index,value} <> errors
def row_operation(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~P:Type,~V:Data,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~P,~V,~O,~E),handle:W.Handle<S>,view:V,payload:P,state:O & Maybe<&2,E>) -> F(P & (O & Maybe<&2,E>)):
  match state:
    case (output,_):body(handle,view,payload,output)
def row_updated(~S:Data,~F:Type -> Type,~C:Type,~O:Type,~E:Data,index:U32,errors:List<&2,Row.Error<E>>,next:Column.Column<S,C> -> O -> List<&2,Row.Error<E>> -> F(Column.Column<S,C> & (O & List<&2,Row.Error<E>>)),result:EditColumn.Update<S,C,O & Maybe<&2,E>>) -> F(Column.Column<S,C> & (O & List<&2,Row.Error<E>>)):
  match result:
    case EditColumn.Updated{column,(output,error),_}:next(column,output,row_errors(~E,index,errors,error))
def row_allowed(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),shape:Part.Shape,column:Column.Column<S,L.stored(full,route)>,+index:U32,tick:Tick.Tick,handle:W.Handle<S>,view:L.view(full,route),output:O,errors:List<&2,Row.Error<E>>,next:Column.Column<S,L.stored(full,route)> -> O -> List<&2,Row.Error<E>> -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)),allowed:Bool) -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)):
  match allowed:
    case False{}:next(column,output,errors)
    case True{}:Effects.bind(~F,EditColumn.Update<S,L.stored(full,route),O & Maybe<&2,E>>,Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>),effects,EditColumn.effect_tree(~S,~F,~effects,~full,~route,O & Maybe<&2,E>,shape,column,index,tick,(output,None{}),payload=>state=>row_operation(~S,~Permit,~F,~effects,~L.payload(full,route),~L.view(full,route),~O,~E,~body,handle,view,payload,state)),result=>row_updated(~S,~F,~L.stored(full,route),~O,~E,index,errors,next,result))
def filter_stamp(mode:Q.Mode,prior:Maybe<&2,Tick.Tick>,tick:Tick.Tick,stamp:Maybe<&2,Life.Stamp>) -> Bool:
  match mode stamp:
    case Q.AllRows{} _:True{}
    case Q.Where{filter} Some{stamp}:Life.matches(filter,stamp,prior,tick)
    case _ _:False{}
def row_stamped(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),shape:Part.Shape,index:U32,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,mode:Q.Mode,handle:W.Handle<S>,view:L.view(full,route),output:O,errors:List<&2,Row.Error<E>>,next:Column.Column<S,L.stored(full,route)> -> O -> List<&2,Row.Error<E>> -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)),result:Column.Column<S,L.stored(full,route)> & Maybe<&2,Life.Stamp>) -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)):
  match result:
    case (column,stamp):row_allowed(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,column,index,tick,handle,view,output,errors,next,filter_stamp(mode,prior,tick,stamp))
def row_selected(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),shape:Part.Shape,column:Column.Column<S,L.stored(full,route)>,+index:U32,+tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,mode:Q.Mode,handle:W.Handle<S>,view:L.view(full,route),output:O,errors:List<&2,Row.Error<E>>,next:Column.Column<S,L.stored(full,route)> -> O -> List<&2,Row.Error<E>> -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)),selected:Bool) -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)):
  match mode selected:
    case _ False{}:next(column,output,errors)
    case Q.AllRows{} True{}:row_allowed(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,column,index,tick,handle,view,output,errors,next,True{})
    case mode True{}:row_stamped(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,index,tick,prior,mode,handle,view,output,errors,next,Column.lifecycle(~S,~L.stored(full,route),column,index))
def traverse_rows(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),+shape:Part.Shape,+capacity:U32,rows:List<&2,Q.GeneralRow<S,L.view(full,route)>>,column:Column.Column<S,L.stored(full,route)>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,+mode:Q.Mode,+requested:Q.GeneralTargets<S>,output:O,errors:List<&2,Row.Error<E>>) -> F(Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)):
  match rows:
    case []:Effects.pure(~F,Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>),effects,(column,(output,List.reverse(&2,Row.Error<E>,errors))))
    case Q.GeneralRow{_,None{}} <> rest:traverse_rows(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,capacity,rest,column,tick,prior,mode,requested,output,errors)
    case Q.GeneralRow{+handle,Some{view}} <> rest:row_selected(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,column,U32.sub(W.handle_index(~S,handle),1),tick,prior,mode,handle,view,output,errors,(column=>output=>errors=>traverse_rows(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,capacity,rest,column,tick,prior,mode,requested,output,errors)),Bool.and(requested_member(~S,handle,requested),U32.is_le(W.handle_index(~S,handle),capacity)))
def traversal_returned(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,frame:WholeFrame<S,full,route,R>,result:Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>)) -> State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>):
  match result:
    case (column,(output,errors)):(whole_scope(~S,~full,~route,~R,frame,column),(output,Q.Completed{errors}))
def traversal_inspected(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),frame:WholeFrame<S,full,route,R>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,mode:Q.Mode,requested:Q.GeneralTargets<S>,rows:List<&2,Q.GeneralRow<S,L.view(full,route)>>,output:O,result:Column.Column<S,L.stored(full,route)> & Part.Inspection) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match result:
    case (column,Part.Inspection{_,_,False{}}):Effects.pure(~F,State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>),effects,(whole_scope(~S,~full,~route,~R,frame,column),(output,Q.LayoutRefused{})))
    case (column,Part.Inspection{shape,capacity,True{}}):Effects.map(~F,Column.Column<S,L.stored(full,route)> & (O & List<&2,Row.Error<E>>),State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>),effects,traverse_rows(~S,~Permit,~F,~effects,~full,~route,~O,~E,~body,shape,capacity,rows,column,tick,prior,mode,requested,output,[]),result=>traversal_returned(~S,~full,~route,~R,~O,~E,frame,result))
def traversal_taken(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),resource:R,handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,mode:Q.Mode,requested:Q.GeneralTargets<S>,rows:List<&2,Q.GeneralRow<S,L.view(full,route)>>,output:O,result:L.column_rest(~S,full,route) & L.ColumnSlot<S,L.stored(full,route),L.key(full,route),L.origin(full,route)>) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match result:
    case (rest,L.ColumnSlot{column}):traversal_inspected(~S,~Permit,~F,~effects,~full,~route,~R,~O,~E,~body,WholeFrame{rest,resource,handles,tick,prior,view},tick,prior,mode,requested,rows,output,Part.inspect(S,L.stored(full,route),column))
def traversal_validated(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),scope:State.Scope<S,L.columns(~S,full),R>,mode:Q.Mode,rows:List<&2,Q.GeneralRow<S,L.view(full,route)>>,output:O,checked:Id.TargetCheck<S>,allowed:Bool) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match scope checked allowed:
    case State.Scope{columns,resource,handles,tick,prior,view} Id.Targets{requested,_} True{}:traversal_taken(~S,~Permit,~F,~effects,~full,~route,~R,~O,~E,~body,resource,handles,tick,prior,view,mode,Q.ExplicitHandles{requested},rows,output,L.column_take(~S,full,route,columns))
    case scope _ _:Effects.pure(~F,State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>),effects,(scope,(output,Q.LayoutRefused{})))
def traversal_requested(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),scope:State.Scope<S,L.columns(~S,full),R>,mode:Q.Mode,rows:List<&2,Q.GeneralRow<S,L.view(full,route)>>,output:O,+selected:List<&2,W.Handle<S>>,+requested:List<&2,W.Handle<S>>) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match scope:
    case State.Scope{columns,resource,+handles,tick,prior,+view}:traversal_validated(~S,~Permit,~F,~effects,~full,~route,~R,~O,~E,~body,State.Scope{columns,resource,handles,tick,prior,view},mode,rows,output,Id.targets_offsets(~S,requested,Id.target_offsets(~S,Q.view_namespace(~S,view),handles,requested)),members(~S,requested,selected))
def traversal_queried(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,output:O,targets:Q.GeneralTargets<S>,result:State.Scope<S,L.columns(~S,full),R> & Q.GeneralReport<S,L.view(full,route)>) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match targets result:
    case _, (scope,Q.SelectionRefused{}):Effects.pure(~F,State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>),effects,(scope,(output,Q.LayoutRefused{})))
    case Q.AllMatched{}, (State.Scope{columns,resource,handles,tick,prior,view},Q.SelectedRows{rows}):traversal_taken(~S,~Permit,~F,~effects,~full,~route,~R,~O,~E,~body,resource,handles,tick,prior,view,mode,Q.AllMatched{},rows,output,L.column_take(~S,full,route,columns))
    case Q.ExplicitHandles{requested}, (scope,Q.SelectedRows{+rows}):traversal_requested(~S,~Permit,~F,~effects,~full,~route,~R,~O,~E,~body,scope,mode,rows,output,selected_handles(~S,~L.view(full,route),rows),requested)
def traversal_live(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,scope:State.Scope<S,L.columns(~S,full),R>,output:O,targets:Q.GeneralTargets<S>,checked:Id.TargetCheck<S>) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match checked:
    case Id.Refused{_}:Effects.pure(~F,State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>),effects,(scope,(output,Q.LayoutRefused{})))
    case Id.Targets{_,_}:traversal_queried(~S,~Permit,~F,~effects,~full,~route,~R,~O,~E,~body,mode,output,targets,whole_query(~S,~full,~route,~R,~bound,~presence,~predicate,scope))
def whole_traverse(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,scope:State.Scope<S,L.columns(~S,full),R>,output:O,targets:Q.GeneralTargets<S>) -> F(State.Scope<S,L.columns(~S,full),R> & (O & Q.Report<E>)):
  match scope:
    case State.Scope{columns,resource,+handles,tick,prior,+view}:traversal_live(~S,~Permit,~F,~effects,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~body,mode,State.Scope{columns,resource,handles,tick,prior,view},output,targets,Id.targets(~S,Q.view_namespace(~S,view),handles))

def ordinary_provider(~S:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~local:{C == L.columns(~S,full) : Type},~kind:Recipe.QueryKind,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool) -> Q.GeneralOps(~S,~L.payload(full,route),~L.view(full,route),kind,State.Scope<S,C,R>):
  whole_caps(~S,~full,~route,~C,~R,~bound,~presence,~predicate,local,kind)
def pure_body(~S:Data,~P:Type,~V:Data,~O:Type,~E:Data,~body:W.Handle<S> -> V -> P -> O -> P & (O & Maybe<&2,E>),handle:W.Handle<S>,view:V,payload:P,output:O) -> P & (O & Maybe<&2,E>):
  body(handle,view,payload,output)
def whole_output_caps_direct(~S:Data,~full:L.Layout,~route:L.Route,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>)) -> Q.GeneralOutputWriter<S,State.Scope<S,L.columns(~S,full),R>,L.payload(full,route),L.view(full,route),O,E>:
  Q.GeneralOutputWriter{whole_reader(~S,~full,~route,~R,~bound,~presence,~predicate),Out=>scope=>handle=>transform=>whole_modify(~S,~full,~route,~R,~bound,~presence,~predicate,Out,scope,handle,transform),whole_traverse(~S,~Unit,~Effects.Identity,~Effects.identity(),~full,~route,~R,~bound,~presence,~predicate,~O,~E,~pure_body(~S,~L.payload(full,route),~L.view(full,route),~O,~E,~body))}
def whole_output_caps(~S:Data,~full:L.Layout,~route:L.Route,~C:Type,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>),same:{C == L.columns(~S,full) : Type}) -> Q.GeneralOutputWriter<S,State.Scope<S,C,R>,L.payload(full,route),L.view(full,route),O,E>:
  %Equal.sym(Type,C,L.columns(~S,full),same) : Q.GeneralOutputWriter<S,State.Scope<S,_,R>,L.payload(full,route),L.view(full,route),O,E>
  whole_output_caps_direct(~S,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~body)
def output_provider(~S:Data,~WC:Type,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~local:{C == L.columns(~S,full) : Type},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:W.Handle<S> -> L.view(full,route) -> L.payload(full,route) -> O -> L.payload(full,route) & (O & Maybe<&2,E>)) -> Q.GeneralOutputWriter<S,State.Scope<S,C,R>,L.payload(full,route),L.view(full,route),O,E>:
  whole_output_caps(~S,~full,~route,~C,~R,~bound,~presence,~predicate,~O,~E,~body,local)
def whole_sequential_caps(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~full:L.Layout,~route:L.Route,~C:Type,~R:Type,~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode,same:{C == L.columns(~S,full) : Type}) -> Q.SequentialOutputEach<S,Permit,F,State.Scope<S,C,R>,O,E>:
  %Equal.sym(Type,C,L.columns(~S,full),same) : Q.SequentialOutputEach<S,Permit,F,State.Scope<S,_,R>,O,E>
  Q.SequentialOutputEach{scope=>output=>whole_traverse(~S,~Permit,~F,~effects,~full,~route,~R,~bound,~presence,~predicate,~O,~E,~body,mode,scope,output,Q.AllMatched{})}
def sequential_provider(~S:Data,~WC:Type,~C:Type,~R:Type,~F:Type -> Type,~effects:Effects.Effects<F>,~Permit:Data,~full:L.Layout,~route:L.Route,~same:{WC == L.columns(~S,full) : Type},~valid:{L.grant_valid(~full,~route) == True{} : Bool},~local:{C == L.columns(~S,full) : Type},~bound:Recipe.Bound,~presence:Match.Presence,~predicate:Maybe<&2,L.view(full,route)> -> Bool,~O:Type,~E:Data,~body:Q.SequentialGeneralBody(~S,~Permit,~F,~L.payload(full,route),~L.view(full,route),~O,~E),mode:Q.Mode) -> Q.SequentialOutputEach<S,Permit,F,State.Scope<S,C,R>,O,E>:
  whole_sequential_caps(~S,~Permit,~F,~effects,~full,~route,~C,~R,~bound,~presence,~predicate,~O,~E,~body,mode,local)
def provider_dictionary(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Type,~selection:Build.GeneralProviderSelection(~S,~WC,~C,~R,~StateEffect.Transition(~State.Invocation<S>),~Ops)) -> Ops:
  selection(ordinary_provider(~S,~WC,~C,~R),output_provider(~S,~WC,~C,~R),sequential_provider(~S,~WC,~C,~R,~StateEffect.Transition(~State.Invocation<S>),~StateEffect.dictionary(~State.Invocation<S>)))
