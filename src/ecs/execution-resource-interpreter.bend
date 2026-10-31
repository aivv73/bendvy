import Base
import ./execution-resource-store.bend as Store
import ./execution-resource-access.bend as A
import ./execution-composer-layout.bend as L
import ./execution-layout-access.bend as Access
import ./execution-state.bend as State
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./change-tick.bend as Tick

def read_slot(-S:Data,-P:Type,-V:Data,-key:String,-origin:L.Layout,-Rest:Type,-Resources:Type,put:Rest -> L.ResourceSlot<S,L.Viewed<P,V>,key,origin> -> Resources,result:Rest & L.ResourceSlot<S,L.Viewed<P,V>,key,origin>) -> Resources & Store.Lookup<V>:
  match result:
    case (rest,L.ResourceSlot{L.Viewed{owner,+cache},+stamp}):(put(rest,L.ResourceSlot{L.Viewed{owner,cache},stamp}),Store.Viewed{cache,stamp})
def scope_returned(-S:Data,-C:Type,-Resources:Type,-Out:Type,columns:C,handles:List<&2,W.Handle<S>>,tick:Tick.Tick,prior:Maybe<&2,Tick.Tick>,view:Notice.View<S>,result:Resources & Out) -> State.Scope<S,C,Resources> & Out:
  match result:
    case (resources,value):(State.Scope{columns,resources,handles,tick,prior,view},value)
def read_scope(-S:Data,-C:Type,-Resources:Type,-V:Data,read:Resources -> Resources & Store.Lookup<V>,source:State.Scope<S,C,Resources>,valid:Bool) -> State.Scope<S,C,Resources> & Store.Lookup<V>:
  match source valid:
    case source False{}:(source,Store.LookupRefused{})
    case State.Scope{columns,resources,handles,tick,prior,view} True{}:scope_returned(S,C,Resources,Store.Lookup<V>,columns,handles,tick,prior,view,read(resources))
def edited_slot(-Slot:Type,-Rest:Type,-Resources:Type,-P:Type,-Out:Type,put:Rest -> Slot -> Resources,rest:Rest,result:Slot & Out) -> Resources & Store.Edit<P,Out>:
  match result:
    case (slot,out):(put(rest,slot),Store.Edited{out})
def edit_slot(-Slot:Type,-Rest:Type,-Resources:Type,-P:Type,-Out:Type,put:Rest -> Slot -> Resources,rewrite:Slot -> Slot & Out,result:Rest & Slot) -> Resources & Store.Edit<P,Out>:
  match result:
    case (rest,slot):edited_slot(Slot,Rest,Resources,P,Out,put,rest,rewrite(slot))
def edit_scope(-S:Data,-C:Type,-Resources:Type,-P:Type,-Out:Type,own:Tick.Tick -> (P -> P & Out) -> Resources -> Resources & Store.Edit<P,Out>,source:State.Scope<S,C,Resources>,transform:Tick.Tick -> P -> P & Out,valid:Bool) -> State.Scope<S,C,Resources> & Store.Edit<P,Out>:
  match source valid:
    case State.Scope{columns,resources,handles,+tick,prior,view} False{}:(State.Scope{columns,resources,handles,tick,prior,view},Store.Unchanged{transform(tick)})
    case State.Scope{columns,resources,handles,+tick,prior,view} True{}:scope_returned(S,C,Resources,Store.Edit<P,Out>,columns,handles,tick,prior,view,own(tick,transform(tick),resources))
def read_caps(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,local:{R == L.resources(~S,full) : Type}) -> A.Reader<State.Scope<S,C,R>,L.view(full,route)>:
  %Equal.sym(Type,R,L.resources(~S,full),local) : A.Reader<State.Scope<S,C,_>,L.view(full,route)>
  A.Reader{source => read_scope(S,C,L.resources(~S,full),L.view(full,route),resources => read_slot(S,L.payload(full,route),L.view(full,route),L.key(full,route),L.origin(full,route),L.resource_rest(~S,full,route),L.resources(~S,full),L.resource_put(~S,full,route),L.resource_take(~S,full,route,resources)),source,L.valid(full,route))}
def write_caps(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,local:{R == L.resources(~S,full) : Type}) -> A.Writer<State.Scope<S,C,R>,L.payload(full,route),L.view(full,route)>:
  %Equal.sym(Type,R,L.resources(~S,full),local) : A.Writer<State.Scope<S,C,_>,L.payload(full,route),L.view(full,route)>
  A.Writer{
        A.Reader{source => read_scope(S,C,L.resources(~S,full),L.view(full,route),resources => read_slot(S,L.payload(full,route),L.view(full,route),L.key(full,route),L.origin(full,route),L.resource_rest(~S,full,route),L.resources(~S,full),L.resource_put(~S,full,route),L.resource_take(~S,full,route,resources)),source,L.valid(full,route))},
        Out => source => transform => edit_scope(S,C,L.resources(~S,full),L.payload(full,route),Out,tick => update => resources => edit_slot(Access.resource_slot(~S,full,route),L.resource_rest(~S,full,route),L.resources(~S,full),L.payload(full,route),Out,L.resource_put(~S,full,route),slot => Access.resource_rewrite(~S,~full,~route,Out,tick,update,slot),L.resource_take(~S,full,route,resources)),source,tick => transform,L.valid(full,route)),
        Out => source => transform => edit_scope(S,C,L.resources(~S,full),L.payload(full,route),Out,tick => update => resources => edit_slot(Access.resource_slot(~S,full,route),L.resource_rest(~S,full,route),L.resources(~S,full),L.payload(full,route),Out,L.resource_put(~S,full,route),slot => Access.resource_rewrite(~S,~full,~route,Out,tick,update,slot),L.resource_take(~S,full,route,resources)),source,transform,L.valid(full,route))}
# Closed ordinary framework dictionary; callers select no independent grants.
def read_dictionary(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~valid:{L.grant_valid(~full,~route) == True{} : Bool},~local:{R == L.resources(~S,full) : Type}) -> A.Reader<State.Scope<S,C,R>,L.view(full,route)>:
  read_caps(~S,~C,~R,~full,~route,local)
def write_dictionary(~S:Data,~C:Type,~R:Type,~full:L.Layout,~route:L.Route,~valid:{L.resource_write_valid(~full,~route) == True{} : Bool},~local:{R == L.resources(~S,full) : Type}) -> A.Writer<State.Scope<S,C,R>,L.payload(full,route),L.view(full,route)>:
  write_caps(~S,~C,~R,~full,~route,local)
