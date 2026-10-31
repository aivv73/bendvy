import Base
import ./execution-deferred-settings.bend as Settings
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./execution-publication-order.bend as Order

type BoundaryKind is Data:
  Sync{ids:List<&2,U32>}
  Final{}
type Boundary is Data:
  ApplyEntered{kind:BoundaryKind,requested:List<&2,U32>}
  ApplyReturned{kind:BoundaryKind,remaining:List<&2,U32>}
type TraceState is Data:
  Off{}
  On{reverse:List<&2,Boundary>}
type Metadata is Data:
  Metadata{syncs:List<&2,U32>,publication:List<&2,U32>}
type Context<-Actual:Type> is Type:
  Context{state:Actual,unapplied:List<&2,U32>,metadata:Metadata,trace:TraceState}
type Outcome<-Actual:Type,Error:Data,Out:Data> is Type:
  Outcome{result:Exec.ExecutionResult<Actual,String,Error,Out>,unapplied:List<&2,U32>}
type Observed<-Actual:Type,-Error:Data,-Out:Data> is Type:
  Observed{outcome:Outcome<Actual,Error,Out>,boundaries:List<&2,Boundary>}
def is_sync(metadata:Metadata,id:U32) -> Bool:
  match metadata:
    case Metadata{syncs,_}:Settings.member(id,syncs)
def publication(metadata:Metadata) -> List<&2,U32>:
  match metadata:
    case Metadata{_,order}:order
def sync_entered(state:TraceState,id:U32,unapplied:List<&2,U32>) -> TraceState:
  match state:
    case Off{}:Off{}
    case On{reverse}:On{ApplyEntered{Sync{[id]},unapplied} <> reverse}
def sync_returned(state:TraceState,id:U32,unapplied:List<&2,U32>) -> TraceState:
  match state:
    case Off{}:Off{}
    case On{reverse}:On{ApplyReturned{Sync{[id]},unapplied} <> reverse}
def final_entered(state:TraceState,unapplied:List<&2,U32>) -> TraceState:
  match state:
    case Off{}:Off{}
    case On{reverse}:On{ApplyEntered{Final{},unapplied} <> reverse}
def final_returned(state:TraceState,unapplied:List<&2,U32>) -> TraceState:
  match state:
    case Off{}:Off{}
    case On{reverse}:On{ApplyReturned{Final{},unapplied} <> reverse}
def boundaries(state:TraceState) -> List<&2,Boundary>:
  match state:
    case Off{}:[]
    case On{reverse}:List.reverse(&2,Boundary,reverse)
def include(+id:U32,+ids:List<&2,U32>) -> List<&2,U32>:
  Bool.pick(List<&2,U32>,Settings.member(id,ids),ids,id <> ids)
def admitted(~Error:Data,~Out:Data,+status:Exec.Invocation<Error,Out>,id:U32,ids:List<&2,U32>) -> List<&2,U32>:
  match status:
    case Exec.Completed{_}:include(id,ids)
    case Exec.BodyError{_,_}:include(id,ids)
    case Exec.AdmissionRefused{}:ids
def condition_returned(~Actual:Type,~Error:Data,syncs:Metadata,unapplied:List<&2,U32>,trace:TraceState,result:Actual & Exec.Condition<Error>) -> Context<Actual> & Exec.Condition<Error>:
  match result:
    case (state,value):(Context{state,unapplied,syncs,trace},value)
def condition_adapter(~Actual:Type,~Error:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,context:Context<Actual>,id:U32) -> Context<Actual> & Exec.Condition<Error>:
  match context:
    case Context{state,unapplied,syncs,trace}:condition_returned(~Actual,~Error,syncs,unapplied,trace,condition(state,id))
def dispatch_returned(~Actual:Type,~Error:Data,~Out:Data,syncs:Metadata,unapplied:List<&2,U32>,trace:TraceState,id:U32,result:Actual & Exec.Invocation<Error,Out>) -> Context<Actual> & Exec.Invocation<Error,Out>:
  match result:
    case (state,+status):(Context{state,admitted(~Error,~Out,status,id,unapplied),syncs,trace},status)
def dispatch_id(~Actual:Type,~Error:Data,~Out:Data,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,context:Context<Actual>,+id:U32) -> Context<Actual> & Exec.Invocation<Error,Out>:
  match context:
    case Context{state,unapplied,syncs,trace}:dispatch_returned(~Actual,~Error,~Out,syncs,unapplied,trace,id,dispatch(state,id))
def dispatch_adapter(~Actual:Type,~Error:Data,~Out:Data,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,context:Context<Actual>,id:U32) -> Context<Actual> & Exec.Invocation<Error,Out>:
  dispatch_id(~Actual,~Error,~Out,~dispatch,context,id)
def handled(~Actual:Type,syncs:Metadata,unapplied:List<&2,U32>,trace:TraceState,result:Actual & Exec.Handling) -> Context<Actual> & Exec.Handling:
  match result:
    case (state,handling):(Context{state,unapplied,syncs,trace},handling)
def handler_adapter(~Actual:Type,~Error:Data,~handler:Actual -> Error -> Actual & Exec.Handling,context:Context<Actual>,error:Error) -> Context<Actual> & Exec.Handling:
  match context:
    case Context{state,unapplied,syncs,trace}:handled(~Actual,syncs,unapplied,trace,handler(state,error))
def applied(~Actual:Type,syncs:Metadata,id:U32,trace:TraceState,result:Actual & List<&2,U32>) -> Context<Actual>:
  match result:
    case (state,+unapplied):Context{state,unapplied,syncs,sync_returned(trace,id,unapplied)}
def synchronize(~Actual:Type,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,context:Context<Actual>,+id:U32) -> Context<Actual>:
  match context:
    case Context{state,+unapplied,+syncs,trace}:applied(~Actual,syncs,id,sync_entered(trace,id,unapplied),Order.apply(~Actual,~apply,publication(syncs),unapplied,state))

def selected(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,next:Context<Actual> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<Context<Actual>,String,Error,Out>,context:Context<Actual>,+id:U32,events:List<&2,Exec.Observation<Error,Out>>,isSync:Bool) -> Exec.ExecutionResult<Context<Actual>,String,Error,Out>:
  match isSync:
    case True{}:next(synchronize(~Actual,~apply,context,id),events)
    case False{}:Exec.conditioned(~Context<Actual>,~String,~Error,~Out,~dispatch_adapter(~Actual,~Error,~Out,~dispatch),~handler_adapter(~Actual,~Error,~handler),next,condition_adapter(~Actual,~Error,~condition,context,id),id,events)
def step(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,next:Context<Actual> -> List<&2,Exec.Observation<Error,Out>> -> Exec.ExecutionResult<Context<Actual>,String,Error,Out>,context:Context<Actual>,+id:U32,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<Context<Actual>,String,Error,Out>:
  match context:
    case Context{state,unapplied,+syncs,trace}:selected(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,next,Context{state,unapplied,syncs,trace},id,events,is_sync(syncs,id))
# Synthetic sync IDs apply buffers before the next condition and produce no body event.
def execute(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,order:List<&2,Plan.Node<String>>,context:Context<Actual>,events:List<&2,Exec.Observation<Error,Out>>) -> Exec.ExecutionResult<Context<Actual>,String,Error,Out>:
  match order:
    case []:Exec.Finished{context,events}
    case Plan.Node{id,_} <> rest:step(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,context => events => execute(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,rest,context,events),context,id,events)
def planned(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,plan:Plan.Build<String>,context:Context<Actual>) -> Exec.ExecutionResult<Context<Actual>,String,Error,Out>:
  match plan:
    case Plan.Rejected{reason}:Exec.Invalid{context,reason}
    case Plan.Planned{order,_}:execute(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,order,context,[])
def final_applied(~Actual:Type,~Error:Data,~Out:Data,trace:TraceState,events:List<&2,Exec.Observation<Error,Out>>,result:Actual & List<&2,U32>) -> Observed<Actual,Error,Out>:
  match result:
    case (state,+unapplied):Observed{Outcome{Exec.Finished{state,events},unapplied},boundaries(final_returned(trace,unapplied))}
def finish(~Actual:Type,~Error:Data,~Out:Data,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,order:List<&2,U32>,finalApply:Bool,state:Actual,+unapplied:List<&2,U32>,trace:TraceState,events:List<&2,Exec.Observation<Error,Out>>) -> Observed<Actual,Error,Out>:
  match finalApply:
    case False{}:Observed{Outcome{Exec.Finished{state,events},unapplied},boundaries(trace)}
    case True{}:final_applied(~Actual,~Error,~Out,final_entered(trace,unapplied),events,Order.apply(~Actual,~apply,order,unapplied,state))
def finished(~Actual:Type,~Error:Data,~Out:Data,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,finalApply:Bool,result:Exec.ExecutionResult<Context<Actual>,String,Error,Out>) -> Observed<Actual,Error,Out>:
  match result:
    case Exec.Finished{Context{state,unapplied,syncs,trace},events}:finish(~Actual,~Error,~Out,~apply,publication(syncs),finalApply,state,unapplied,trace,events)
    case Exec.Stopped{Context{state,unapplied,_,trace},error,events}:Observed{Outcome{Exec.Stopped{state,error,events},unapplied},boundaries(trace)}
    case Exec.Invalid{Context{state,unapplied,_,trace},reason}:Observed{Outcome{Exec.Invalid{state,reason},unapplied},boundaries(trace)}
def run_ordered(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,trace:TraceState,settings:Settings.Settings,syncs:List<&2,U32>,order:List<&2,U32>,plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> Observed<Actual,Error,Out>:
  match settings:
    case Settings.Settings{_,finalApply,_,_}:finished(~Actual,~Error,~Out,~apply,finalApply,planned(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,plan,Context{state,unapplied,Metadata{syncs,order},trace}))
def run_mode(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,trace:TraceState,settings:Settings.Settings,+syncs:List<&2,U32>,+plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> Observed<Actual,Error,Out>:
  run_ordered(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,trace,settings,syncs,Order.from_plan(plan,syncs),plan,state,unapplied)
def run_observed(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,settings:Settings.Settings,syncs:List<&2,U32>,plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> Observed<Actual,Error,Out>:
  run_mode(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,On{[]},settings,syncs,plan,state,unapplied)
def unobserved(~Actual:Type,~Error:Data,~Out:Data,value:Observed<Actual,Error,Out>) -> Outcome<Actual,Error,Out>:
  match value:
    case Observed{outcome,_}:outcome
def run(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,settings:Settings.Settings,syncs:List<&2,U32>,plan:Plan.Build<String>,state:Actual,unapplied:List<&2,U32>) -> Outcome<Actual,Error,Out>:
  unobserved(~Actual,~Error,~Out,run_mode(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,Off{},settings,syncs,plan,state,unapplied))
