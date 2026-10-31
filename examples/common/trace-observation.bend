import Base
import ../../src/ecs/execution-trace.bend as Trace

def status(value:Trace.Status<String>) -> String:
  match value:
    case Trace.SystemOk{}:"ok"
    case Trace.SystemError{error}:"error(" ++ error ++ ")"
def completion(value:Trace.Completion<String>) -> String:
  match value:
    case Trace.EndOk{}:"ok"
    case Trace.EndFailed{error}:"failed(" ++ error ++ ")"
    case Trace.EndRejected{}:"rejected"
    case Trace.EndMissing{}:"missing"
def trace_event(value:Trace.TraceEvent<String>) -> String:
  match value:
    case Trace.SystemOutcome{id,value}:"system(" ++ U32.show(id) ++ "," ++ status(value) ++ ")"
    case Trace.ConditionOutcome{id,value}:"condition(" ++ U32.show(id) ++ "," ++ status(value) ++ ")"
    case Trace.InvocationRefused{id}:"invocation-refused(" ++ U32.show(id) ++ ")"
    case Trace.ConditionRefused{id}:"condition-refused(" ++ U32.show(id) ++ ")"
    case Trace.SystemSkipped{id}:"skipped(" ++ U32.show(id) ++ ")"
    case Trace.DependencyObserved{before,after}:"dependency(" ++ U32.show(before) ++ "," ++ U32.show(after) ++ ")"
    case Trace.ScheduleEnded{value}:"end(" ++ completion(value) ++ ")"
    case _:"unobserved-trace-variant"
def batch(value:Trace.Batch<String>) -> String:
  match value:
    case Trace.Disabled{}:"disabled"
    case Trace.BendvyReady{events}:"ready" ++ List.show(&2,Trace.TraceEvent<String>,trace_event,events)
