import Base
import ./execution-effects.bend as Effects
import ./execution-query-identity.bend as Index
import ./execution-query-domain.bend as Domain
import ./execution-lifecycle-notices.bend as Notice
import ./chunk-column.bend as Col
import ./chunk-query.bend as Q
import ./execution-state.bend as State
import ./execution-declaration.bend as D
import ./execution-projection.bend as Projection
import ./ordinary-declaration.bend as Identity
import ./owner-product.bend as Product
import ./world.bend as W
import ./change-tick.bend as Tick
import ./lifecycle.bend as Life
import ./execution-composer-layout.bend as Layout
import ./execution-query-recipe.bend as Recipe

type Mode is Data:
  AllRows{}
  Where{filter:Life.Filter}
def selection(mode:Mode,indices:List<&2,U32>,prior:Maybe<&2,Tick.Tick>) -> Q.Selection:
  match mode:
    case AllRows{}:Q.Selected{indices}
    case Where{filter}:Q.Filtered{indices,filter,prior}
type Report<-E:Data> is Data:
  Completed{errors:List<&2,Q.Error<E>>}
  LayoutRefused{}
type Each<-S:Data,-H:Type,-E:Data> is Type:
  Each{run:H -> H & Report<E>}
def Ops(~S:Data,~E:Data,H:Type) -> Type: Each<S,H,E>
def logical_errors(~E:Data,errors:List<&2,Q.Error<E>>) -> List<&2,Q.Error<E>>:
  match errors:
    case []:[]
    case Q.Error{index,value} <> rest:Q.Error{U32.add(index,1),value} <> logical_errors(~E,rest)
def logical_body(~A:Type,~B:Type,~V:Data,~E:Data,~body:U32 -> V -> B -> B & Maybe<&2,E>,index:U32,view:V,owner:B) -> B & Maybe<&2,E>:
  body(U32.add(index,1),view,owner)
def view_namespace(~S:Data,view:Notice.View<S>) -> U32:
  match view:
    case Notice.View{namespace,_,_}:namespace
def report(~E:Data,errors:List<&2,Q.Error<E>>,aligned:Bool) -> Report<E>:
  match aligned:
    case True{}: Completed{logical_errors(~E,errors)}
    case False{}: LayoutRefused{}
def returned(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,rest:Rest,resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Q.Run<S,A,B,E>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Report<E>:
  match result:
    case Q.Run{read,write,errors,aligned}: (State.Scope{Product.put_field(~C,~Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,~Rest,lens)(rest,Product.Owner{read,write}),resource,handles,tick,prior,lifecycleView},report(~E,errors,aligned))
def taken(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,+mode:Mode,resource:R,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,+selected:List<&2,U32>,result:Rest & Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & Report<E>:
  match result:
    case Tuple{rest,Product.Owner{read,write}}:returned(~S,~C,~R,~A,~B,~Rest,~E,~lens,rest,resource,handles,tick,prior,Q.selected(~S,~A,~B,~V,~E,~project,~logical_body(~A,~B,~V,~E,~body),read,write,0,tick,selection(mode,selected,prior)),lifecycleView)
def invoke_targets(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,mode:Mode,scope:State.Scope<S,C,R>,targets:Index.TargetCheck<S>) -> State.Scope<S,C,R> & Report<E>:
  match scope targets:
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView} Index.Targets{_,Domain.Domain{selected}}: taken(~S,~C,~R,~A,~B,~Rest,~V,~E,~lens,~project,~body,mode,resource,handles,tick,prior,selected,Product.get_field(~C,~Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,~Rest,lens)(store),lifecycleView)
    case scope Index.Refused{_}:(scope,LayoutRefused{})
def invoke(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,mode:Mode,scope:State.Scope<S,C,R>) -> State.Scope<S,C,R> & Report<E>:
  match scope:
    case State.Scope{store,resource,+handles,tick,prior,+lifecycleView}:invoke_targets(~S,~C,~R,~A,~B,~Rest,~V,~E,~lens,~project,~body,mode,State.Scope{store,resource,handles,tick,prior,lifecycleView},Index.targets(~S,view_namespace(~S,lifecycleView),handles))
def declaration(~S:Data,~C:Type,~R:Type,~A:Type,~B:Type,~Rest:Type,~V:Data,~E:Data,~lens:Product.Lens<C,Product.Owner<Col.Column<S,A>,Col.Column<S,B>>,Rest>,~project:A -> A & V,~body:U32 -> V -> B -> B & Maybe<&2,E>,_:Projection.Affine<A,V,project>,mode:Mode,read:Identity.Declaration<S,A>,write:Identity.Declaration<S,B>) -> D.Declaration<S,C,R,Ops(~S,~E)>:
  D.Declaration{Each{invoke(~S,~C,~R,~A,~B,~Rest,~V,~E,~lens,~project,~body,mode)},[D.Access{Identity.key(~S,~A,read),D.ComponentAccess{},D.Exclusive{},D.ReadOnly{}},D.Access{Identity.key(~S,~B,write),D.ComponentAccess{},D.Exclusive{},D.Writable{}}]}
def each(~S:Data,~H:Type,~E:Data,cap:Each<S,H,E>) -> H -> H & Report<E>:
  match cap:
    case Each{run}: run

def layout_unwrapped(~S:Data,~layout:Layout.Layout,~route:Layout.Route,rest:Layout.subtree_rest(~S,layout,route),selected:Layout.query_pair(~S,~layout,~route)) -> Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>:
  match selected:
    case Product.Owner{Layout.ColumnSlot{read},Layout.ColumnSlot{write}}: (rest,Product.Owner{read,write})
def layout_selected(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},result:Layout.subtree_rest(~S,layout,route) & Layout.columns(~S,Layout.subtree(layout,route))) -> Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>:
  match result:
    case (rest,selected): layout_unwrapped(~S,~layout,~route,rest,Layout.checked_owner(Layout.columns(~S,Layout.subtree(layout,route)),Layout.query_pair(~S,~layout,~route),shape,selected))
def layout_take(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},owner:C) -> Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>:
  layout_selected(~S,~layout,~route,~shape,Layout.subtree_take(~S,layout,route,Layout.checked_owner(C,Layout.columns(~S,layout),same,owner)))
def layout_put(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},rest:Layout.subtree_rest(~S,layout,route),selected:Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>) -> C:
  match selected:
    case Product.Owner{read,write}: Layout.checked_owner(Layout.columns(~S,layout),C,Equal.sym(Type,C,Layout.columns(~S,layout),same),Layout.subtree_put(~S,layout,route,rest,Layout.checked_owner(Layout.query_pair(~S,~layout,~route),Layout.columns(~S,Layout.subtree(layout,route)),Equal.sym(Type,Layout.columns(~S,Layout.subtree(layout,route)),Layout.query_pair(~S,~layout,~route),shape),Product.Owner{Layout.ColumnSlot{read},Layout.ColumnSlot{write}})))
def layout_lens(~S:Data,~C:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type}) -> Product.Lens<C,Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>,Layout.subtree_rest(~S,layout,route)>:
  Product.Lens{layout_take(~S,~C,~layout,~route,~same,~shape),layout_put(~S,~C,~layout,~route,~same,~shape)}
def layout_body(~layout:Layout.Layout,~route:Layout.Route,~E:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,E>,index:U32,view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})) -> Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & Maybe<&2,E>:
  Layout.rewrite(~Layout.subtree(layout,route),~Layout.InRight{Layout.AtLeaf{}},Maybe<&2,E>,body(index,view),owner)
def layout_declaration(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~E:Data,~body:U32 -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> Layout.query_output(layout,route) & Maybe<&2,E>,mode:Mode) -> D.Declaration<S,C,R,Ops(~S,~E)>:
  declaration(~S,~C,~R,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),~Layout.subtree_rest(~S,layout,route),~Layout.query_view(layout,route),~E,~layout_lens(~S,~C,~layout,~route,~same,~shape),~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route)),~layout_body(~layout,~route,~E,~body),Projection.trusted_affine(~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.query_view(layout,route),~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route))),mode,Identity.component(~S,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),Layout.query_read_key(layout,route)),Identity.component(~S,~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),Layout.query_write_key(layout,route)))

# The output type is selected only inside the registered system body. It remains
# abstract to gameplay, including when it is the framework command-buffer owner.
def OutputBody(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data) -> Type:
  W.Handle<S> -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> O -> Layout.query_output(layout,route) & (O & Maybe<&2,E>)
type OutputEach<-S:Data,-H:Type,-O:Type,-E:Data> is Type:
  OutputEach{run:H -> O -> H & (O & Report<E>)}
def OutputOps(~S:Data,~O:Type,~E:Data,H:Type) -> Type:OutputEach<S,H,O,E>
def handle_choice(~S:Data,handle:W.Handle<S>,rest:Maybe<&2,W.Handle<S>>,same:Bool) -> Maybe<&2,W.Handle<S>>:
  match same:
    case True{}:Some{handle}
    case False{}:rest
def selected_handle(~S:Data,+index:U32,handles:List<&2,W.Handle<S>>) -> Maybe<&2,W.Handle<S>>:
  match handles:
    case []:None{}
    case +handle <> rest:handle_choice(~S,handle,selected_handle(~S,index,rest),U32.is_eq(U32.add(index,1),W.handle_index(~S,handle)))
def output_body_found(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),output:O,found:Maybe<&2,W.Handle<S>>) -> Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>):
  match found:
    case None{}:(owner,(output,None{}))
    case Some{handle}:Layout.rewrite(~Layout.subtree(layout,route),~Layout.InRight{Layout.AtLeaf{}},O & Maybe<&2,E>,payload=>body(handle,view,payload,output),owner)
def output_body(~S:Data,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),handles:List<&2,W.Handle<S>>,index:U32,view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),output:O) -> Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>):
  output_body_found(~S,~layout,~route,~O,~E,~body,view,owner,output,selected_handle(~S,index,handles))
def output_returned(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,rest:Layout.subtree_rest(~S,layout,route),resource:R,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,result:Q.OutputRun<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),O,E>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & (O & Report<E>):
  match result:
    case Q.OutputRun{read,write,output,errors,aligned}:(State.Scope{layout_put(~S,~C,~layout,~route,~same,~shape,rest,Product.Owner{read,write}),resource,handles,tick,prior,lifecycleView},(output,report(~E,errors,aligned)))
def output_taken(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),output:O,resource:R,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,+mode:Mode,+selected:List<&2,U32>,result:Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>,+lifecycleView:Notice.View<S>) -> State.Scope<S,C,R> & (O & Report<E>):
  match result:
    case (rest,Product.Owner{read,write}):output_returned(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,rest,resource,handles,tick,prior,Q.with_output(~S,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),~O,~Layout.query_view(layout,route),~List<&2,W.Handle<S>>,~E,~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route)),~output_body(~S,~layout,~route,~O,~E,~body),handles,read,write,output,0,tick,selection(mode,selected,prior)),lifecycleView)
def output_invoke_targets(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),mode:Mode,scope:State.Scope<S,C,R>,output:O,targets:Index.TargetCheck<S>) -> State.Scope<S,C,R> & (O & Report<E>):
  match scope targets:
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView} Index.Targets{_,Domain.Domain{selected}}:output_taken(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,~body,output,resource,handles,tick,prior,mode,selected,layout_take(~S,~C,~layout,~route,~same,~shape,store),lifecycleView)
    case scope Index.Refused{_}:(scope,(output,LayoutRefused{}))
def output_invoke(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),mode:Mode,scope:State.Scope<S,C,R>,output:O) -> State.Scope<S,C,R> & (O & Report<E>):
  match scope:
    case State.Scope{store,resource,+handles,tick,prior,+lifecycleView}:output_invoke_targets(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,~body,mode,State.Scope{store,resource,handles,tick,prior,lifecycleView},output,Index.targets(~S,view_namespace(~S,lifecycleView),handles))
def output_declaration(~S:Data,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~E:Data,~body:OutputBody(~S,~layout,~route,~O,~E),mode:Mode) -> D.Declaration<S,C,R,OutputOps(~S,~O,~E)>:
  D.Declaration{OutputEach{output_invoke(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,~body,mode)},[D.Access{Layout.query_read_key(layout,route),D.ComponentAccess{},D.Exclusive{},D.ReadOnly{}},D.Access{Layout.query_write_key(layout,route),D.ComponentAccess{},D.Exclusive{},D.Writable{}}]}
def each_output(~S:Data,~H:Type,~O:Type,~E:Data,cap:OutputEach<S,H,O,E>) -> H -> O -> H & (O & Report<E>):
  match cap:
    case OutputEach{run}:run

type GeneralRow<-S:Data,-V:Data> is Data:
  GeneralRow{handle:W.Handle<S>,view:Maybe<&2,V>}
type GeneralLookup<-V:Data> is Data:
  MissingEntity{}
  NotMatched{}
  LookupRefused{}
  Matched{view:Maybe<&2,V>}
type GeneralReport<-S:Data,-V:Data> is Data:
  SelectedRows{rows:List<&2,GeneralRow<S,V>>}
  SelectionRefused{}
type GeneralCount is Data:
  CountSelectionRefused{}
  SelectedCount{count:U32}
type GeneralSingle<-S:Data,-V:Data> is Data:
  SingleSelectionRefused{}
  NoSelectedRow{}
  OneSelectedRow{row:GeneralRow<S,V>}
  MultipleSelectedRows{}
def general_rows_count(~S:Data,~V:Data,rows:List<&2,GeneralRow<S,V>>) -> U32:
  match rows:
    case []:0
    case _ <> rest:U32.add(1,general_rows_count(~S,~V,rest))
def general_count(~S:Data,~V:Data,report:GeneralReport<S,V>) -> GeneralCount:
  match report:
    case SelectionRefused{}:CountSelectionRefused{}
    case SelectedRows{rows}:SelectedCount{general_rows_count(~S,~V,rows)}
def general_rows_single(~S:Data,~V:Data,rows:List<&2,GeneralRow<S,V>>) -> GeneralSingle<S,V>:
  match rows:
    case []:NoSelectedRow{}
    case row <> []:OneSelectedRow{row}
    case _ <> _ <> _:MultipleSelectedRows{}
def general_single(~S:Data,~V:Data,report:GeneralReport<S,V>) -> GeneralSingle<S,V>:
  match report:
    case SelectionRefused{}:SingleSelectionRefused{}
    case SelectedRows{rows}:general_rows_single(~S,~V,rows)
type GeneralReader<-S:Data,-H:Type,-V:Data> is Type:
  GeneralReader{query:H -> H & GeneralReport<S,V>,get:H -> W.Handle<S> -> H & GeneralLookup<V>}
  UnsupportedReader{}
type GeneralEdit<-P:Type,-Out:Type> is Type:
  GeneralEdited{output:Out}
  GeneralUnchanged{unused:P -> P & Out}
type GeneralTargets<-S:Data> is Data:
  AllMatched{}
  ExplicitHandles{handles:List<&2,W.Handle<S>>}
type GeneralWriter<-S:Data,-H:Type,-P:Type,-V:Data> is Type:
  GeneralWriter{read:GeneralReader<S,H,V>,modify:@-Out:Type -> H -> W.Handle<S> -> (P -> P & Out) -> H & GeneralEdit<P,Out>}
  UnsupportedWriter{}
type GeneralOutputWriter<-S:Data,-H:Type,-P:Type,-V:Data,-O:Type,-E:Data> is Type:
  GeneralOutputWriter{read:GeneralReader<S,H,V>,modify:@-Out:Type -> H -> W.Handle<S> -> (P -> P & Out) -> H & GeneralEdit<P,Out>,traverse:Mode -> H -> O -> GeneralTargets<S> -> H & (O & Report<E>)}
  UnsupportedOutputWriter{}
def GeneralOutputOps(~S:Data,~P:Type,~V:Data,~O:Type,~E:Data,H:Type) -> Type:
  GeneralOutputWriter<S,H,P,V,O,E>
def general_traverse(~S:Data,~H:Type,~P:Type,~V:Data,~O:Type,~E:Data,writer:GeneralOutputWriter<S,H,P,V,O,E>,mode:Mode,scope:H,output:O,targets:GeneralTargets<S>) -> H & (O & Report<E>):
  match writer:
    case GeneralOutputWriter{_,_,traverse}:traverse(mode,scope,output,targets)
    case UnsupportedOutputWriter{}:(scope,(output,LayoutRefused{}))
def GeneralOps(~S:Data,~P:Type,~V:Data,kind:Recipe.QueryKind,H:Type) -> Type:
  match kind:
    case Recipe.ReadRows{}:GeneralReader<S,H,V>
    case Recipe.WriteRows{}:GeneralWriter<S,H,P,V>

def SequentialOutputBody(~S:Data,~Permit:Data,~F:Type -> Type,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data) -> Type:
  W.Handle<S> -> Layout.query_view(layout,route) -> Layout.query_output(layout,route) -> O -> F(Layout.query_output(layout,route) & (O & Maybe<&2,E>))
type SequentialOutputEach<-S:Data,-Permit:Data,-F:Type -> Type,-H:Type,-O:Type,-E:Data> is Type:
  SequentialOutputEach{run:H -> O -> F(H & (O & Report<E>))}
def SequentialOutputOps(~S:Data,~Permit:Data,~F:Type -> Type,~O:Type,~E:Data,H:Type) -> Type:SequentialOutputEach<S,Permit,F,H,O,E>
def sequential_output_body_found(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data,~body:SequentialOutputBody(~S,~Permit,~F,~layout,~route,~O,~E),view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),output:O,found:Maybe<&2,W.Handle<S>>) -> F(Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>)):
  match owner found:
    case owner None{}:Effects.pure(~F,(Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>)),effects,(owner,(output,None{})))
    case Layout.Viewed{payload,_} Some{handle}:Effects.map(~F,Layout.query_output(layout,route) & (O & Maybe<&2,E>),(Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>)),effects,body(handle,view,payload,output),result=>Layout.rewritten(Layout.query_output(layout,route),Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),O & Maybe<&2,E>,Layout.initialize(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),result))
def sequential_output_body(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~layout:Layout.Layout,~route:Layout.Route,~O:Type,~E:Data,~body:SequentialOutputBody(~S,~Permit,~F,~layout,~route,~O,~E),handles:List<&2,W.Handle<S>>,index:U32,view:Layout.query_view(layout,route),owner:Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),output:O) -> F(Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}) & (O & Maybe<&2,E>)):
  sequential_output_body_found(~S,~Permit,~F,~effects,~layout,~route,~O,~E,~body,view,owner,output,selected_handle(~S,index,handles))
def sequential_output_taken(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~body:SequentialOutputBody(~S,~Permit,~F,~layout,~route,~O,~E),output:O,resource:R,+handles:List<&2,W.Handle<S>>,+tick:Tick.Tick,+prior:Maybe<&2,Tick.Tick>,+mode:Mode,+selected:List<&2,U32>,result:Layout.subtree_rest(~S,layout,route) & Product.Owner<Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}})>,Col.Column<S,Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}})>>,+lifecycleView:Notice.View<S>) -> F(State.Scope<S,C,R> & (O & Report<E>)):
  match result:
    case (rest,Product.Owner{read,write}):Effects.map(~F,Q.OutputRun<S,Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),O,E>,(State.Scope<S,C,R> & (O & Report<E>)),effects,Q.effect_with_output(~S,~F,~effects,~Layout.stored(Layout.subtree(layout,route),Layout.InLeft{Layout.AtLeaf{}}),~Layout.stored(Layout.subtree(layout,route),Layout.InRight{Layout.AtLeaf{}}),~O,~Layout.query_view(layout,route),~List<&2,W.Handle<S>>,~E,~Layout.read(~Layout.query_input(layout,route),~Layout.query_view(layout,route)),~sequential_output_body(~S,~Permit,~F,~effects,~layout,~route,~O,~E,~body),handles,read,write,output,0,tick,selection(mode,selected,prior)),result=>output_returned(~S,~C,~R,~layout,~route,~same,~shape,~O,~E,rest,resource,handles,tick,prior,result,lifecycleView))
def sequential_output_invoke_targets(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~body:SequentialOutputBody(~S,~Permit,~F,~layout,~route,~O,~E),mode:Mode,scope:State.Scope<S,C,R>,output:O,targets:Index.TargetCheck<S>) -> F(State.Scope<S,C,R> & (O & Report<E>)):
  match scope targets:
    case State.Scope{store,resource,handles,tick,prior,+lifecycleView} Index.Targets{_,Domain.Domain{selected}}:sequential_output_taken(~S,~Permit,~F,~effects,~C,~R,~layout,~route,~same,~shape,~O,~E,~body,output,resource,handles,tick,prior,mode,selected,layout_take(~S,~C,~layout,~route,~same,~shape,store),lifecycleView)
    case scope Index.Refused{_}:Effects.pure(~F,(State.Scope<S,C,R> & (O & Report<E>)),effects,(scope,(output,LayoutRefused{})))
def sequential_output_invoke(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~O:Type,~E:Data,~body:SequentialOutputBody(~S,~Permit,~F,~layout,~route,~O,~E),mode:Mode,scope:State.Scope<S,C,R>,output:O) -> F(State.Scope<S,C,R> & (O & Report<E>)):
  match scope:
    case State.Scope{store,resource,+handles,tick,prior,+lifecycleView}:sequential_output_invoke_targets(~S,~Permit,~F,~effects,~C,~R,~layout,~route,~same,~shape,~O,~E,~body,mode,State.Scope{store,resource,handles,tick,prior,lifecycleView},output,Index.targets(~S,view_namespace(~S,lifecycleView),handles))
def sequential_output_declaration(~S:Data,~Permit:Data,~F:Type -> Type,~effects:Effects.Effects<F>,~C:Type,~R:Type,~layout:Layout.Layout,~route:Layout.Route,~same:{C == Layout.columns(~S,layout) : Type},~shape:{Layout.columns(~S,Layout.subtree(layout,route)) == Layout.query_pair(~S,~layout,~route) : Type},~valid:{Layout.query_valid(~layout,~route) == True{} : Bool},~O:Type,~E:Data,~body:SequentialOutputBody(~S,~Permit,~F,~layout,~route,~O,~E),mode:Mode) -> D.Declaration<S,C,R,SequentialOutputOps(~S,~Permit,~F,~O,~E)>:
  D.Declaration{SequentialOutputEach{sequential_output_invoke(~S,~Permit,~F,~effects,~C,~R,~layout,~route,~same,~shape,~O,~E,~body,mode)},[D.Access{Layout.query_read_key(layout,route),D.ComponentAccess{},D.Exclusive{},D.ReadOnly{}},D.Access{Layout.query_write_key(layout,route),D.ComponentAccess{},D.Exclusive{},D.Writable{}}]}
def each_sequential_output(~S:Data,~Permit:Data,~F:Type -> Type,~H:Type,~O:Type,~E:Data,cap:SequentialOutputEach<S,Permit,F,H,O,E>) -> H -> O -> F(H & (O & Report<E>)):
  match cap:
    case SequentialOutputEach{run}:run

def SequentialGeneralBody(~S:Data,~Permit:Data,~F:Type -> Type,~P:Type,~V:Data,~O:Type,~E:Data) -> Type:
  W.Handle<S> -> V -> P -> O -> F(P & (O & Maybe<&2,E>))
