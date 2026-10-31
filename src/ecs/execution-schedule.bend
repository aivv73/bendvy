import Base
import ./dependency-plan.bend as Plan
import ./dependency-executor.bend as Exec
import ./dependency-application.bend as App
import ./execution-deferred-settings.bend as Settings
import ./execution-deferred-schedule.bend as DeferredSchedule
import ./execution-publication-order.bend as Order

type Deferred is Data:
  Deferred{systems:List<&2,U32>,settings:Settings.Settings,unapplied:List<&2,U32>,compiled:Settings.Built,publication:List<&2,U32>}
type Scheduled<-Actual:Type> is Type:
  Scheduled{state:Actual,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,deferred:Deferred}
type ObservedScheduled<-Actual:Type,-Error:Data,-Out:Data> is Type:
  ObservedScheduled{scheduled:Scheduled<Actual>,report:App.Report<Error,Out>,boundaries:List<&2,DeferredSchedule.Boundary>}
def created(~Actual:Type,state:Actual,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,systems:List<&2,U32>,settings:Settings.Settings,unapplied:List<&2,U32>,+compiled:Settings.Built) -> Scheduled<Actual>:
  Scheduled{state,plan,bindings,Deferred{systems,settings,unapplied,compiled,Order.from_built(compiled)}}
def create(~Actual:Type,state:Actual,+plan:Plan.Build<String>,bindings:List<&2,App.Binding>,+systems:List<&2,U32>,+settings:Settings.Settings,unapplied:List<&2,U32>) -> Scheduled<Actual>:
  created(~Actual,state,plan,bindings,systems,settings,unapplied,Settings.compile(settings,systems,plan))
def configure(~Actual:Type,settings:Settings.Settings,scheduled:Scheduled<Actual>) -> Scheduled<Actual>:
  match scheduled:
    case Scheduled{state,plan,bindings,Deferred{systems,_,unapplied,_,_}}:create(~Actual,state,plan,bindings,systems,settings,unapplied)
def set_final_apply(~Actual:Type,finalApply:Bool,scheduled:Scheduled<Actual>) -> Scheduled<Actual>:
  match scheduled:
    case Scheduled{state,plan,bindings,Deferred{systems,Settings.Settings{automatic,_,ignored,explicit},unapplied,compiled,publication}}:Scheduled{state,plan,bindings,Deferred{systems,Settings.Settings{automatic,finalApply,ignored,explicit},unapplied,compiled,publication}}
def trace(on:Bool) -> DeferredSchedule.TraceState:
  match on:
    case True{}:DeferredSchedule.On{[]}
    case False{}:DeferredSchedule.Off{}
def returned(~Actual:Type,~Error:Data,~Out:Data,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,systems:List<&2,U32>,settings:Settings.Settings,compiled:Settings.Built,publication:List<&2,U32>,unapplied:List<&2,U32>,boundaries:List<&2,DeferredSchedule.Boundary>,result:Exec.ExecutionResult<Actual,String,Error,Out>) -> ObservedScheduled<Actual,Error,Out>:
  match result:
    case Exec.Finished{state,events}:ObservedScheduled{Scheduled{state,plan,bindings,Deferred{systems,settings,unapplied,compiled,publication}},App.Finished{events},boundaries}
    case Exec.Stopped{state,error,events}:ObservedScheduled{Scheduled{state,plan,bindings,Deferred{systems,settings,unapplied,compiled,publication}},App.Stopped{error,events},boundaries}
    case Exec.Invalid{state,reason}:ObservedScheduled{Scheduled{state,plan,bindings,Deferred{systems,settings,unapplied,compiled,publication}},App.Invalid{reason},boundaries}
def completed(~Actual:Type,~Error:Data,~Out:Data,completion:Exec.ExecutionResult<Actual,String,Error,Out> -> Exec.ExecutionResult<Actual,String,Error,Out>,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,systems:List<&2,U32>,settings:Settings.Settings,compiled:Settings.Built,publication:List<&2,U32>,result:DeferredSchedule.Observed<Actual,Error,Out>) -> ObservedScheduled<Actual,Error,Out>:
  match result:
    case DeferredSchedule.Observed{DeferredSchedule.Outcome{result,unapplied},boundaries}:returned(~Actual,~Error,~Out,plan,bindings,systems,settings,compiled,publication,unapplied,boundaries,completion(result))
def run_built(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,completion:Exec.ExecutionResult<Actual,String,Error,Out> -> Exec.ExecutionResult<Actual,String,Error,Out>,on:Bool,plan:Plan.Build<String>,bindings:List<&2,App.Binding>,systems:List<&2,U32>,+settings:Settings.Settings,state:Actual,unapplied:List<&2,U32>,+publication:List<&2,U32>,built:Settings.Built) -> ObservedScheduled<Actual,Error,Out>:
  match built:
    case Settings.Built{+compiled,+syncs}:completed(~Actual,~Error,~Out,completion,plan,bindings,systems,settings,Settings.Built{compiled,syncs},publication,DeferredSchedule.run_ordered(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,trace(on),settings,syncs,publication,compiled,state,unapplied))
def run_observed_with_completion(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,completion:Exec.ExecutionResult<Actual,String,Error,Out> -> Exec.ExecutionResult<Actual,String,Error,Out>,on:Bool,scheduled:Scheduled<Actual>) -> ObservedScheduled<Actual,Error,Out>:
  match scheduled:
    case Scheduled{state,plan,bindings,Deferred{systems,settings,unapplied,compiled,publication}}:run_built(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,completion,on,plan,bindings,systems,settings,state,unapplied,publication,compiled)
def unobserved(~Actual:Type,~Error:Data,~Out:Data,value:ObservedScheduled<Actual,Error,Out>) -> Scheduled<Actual> & App.Report<Error,Out>:
  match value:
    case ObservedScheduled{scheduled,report,_}:(scheduled,report)
def run_with_completion(~Actual:Type,~Error:Data,~Out:Data,~condition:Actual -> U32 -> Actual & Exec.Condition<Error>,~dispatch:Actual -> U32 -> Actual & Exec.Invocation<Error,Out>,~handler:Actual -> Error -> Actual & Exec.Handling,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,completion:Exec.ExecutionResult<Actual,String,Error,Out> -> Exec.ExecutionResult<Actual,String,Error,Out>,scheduled:Scheduled<Actual>) -> Scheduled<Actual> & App.Report<Error,Out>:
  unobserved(~Actual,~Error,~Out,run_observed_with_completion(~Actual,~Error,~Out,~condition,~dispatch,~handler,~apply,completion,False{},scheduled))
