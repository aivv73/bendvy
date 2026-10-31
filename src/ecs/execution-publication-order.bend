import Base
import ./dependency-plan.bend as Plan
import ./execution-deferred-settings.bend as Settings

# Only actual system IDs enter the retained publication order. Synthetic sync
# nodes are execution boundaries, never registered command owners.
def include(id:U32,selected:Bool,rest:List<&2,U32>) -> List<&2,U32>:
  match selected:
    case True{}:id <> rest
    case False{}:rest
def node_ids(nodes:List<&2,Plan.Node<String>>,+syncs:List<&2,U32>) -> List<&2,U32>:
  match nodes:
    case []:[]
    case Plan.Node{+id,_} <> rest:include(id,Bool.not(Settings.member(id,syncs)),node_ids(rest,syncs))
def from_plan(plan:Plan.Build<String>,syncs:List<&2,U32>) -> List<&2,U32>:
  match plan:
    case Plan.Rejected{_}:[]
    case Plan.Planned{nodes,_}:node_ids(nodes,syncs)
def from_built(built:Settings.Built) -> List<&2,U32>:
  match built:
    case Settings.Built{plan,syncs}:from_plan(plan,syncs)
def selected(order:List<&2,U32>,+ids:List<&2,U32>) -> List<&2,U32>:
  match order:
    case []:[]
    case +id <> rest:include(id,Settings.member(id,ids),selected(rest,ids))
def unknown(+order:List<&2,U32>,ids:List<&2,U32>) -> List<&2,U32>:
  match ids:
    case []:[]
    case +id <> rest:include(id,Bool.not(Settings.member(id,order)),unknown(order,rest))
def returned(~Actual:Type,order:List<&2,U32>,unknown:List<&2,U32>,result:Actual & List<&2,U32>) -> Actual & List<&2,U32>:
  match result:
    case (state,remaining):(state,List.append(&2,U32,selected(order,remaining),unknown))
def apply_selected(~Actual:Type,~apply:List<&2,U32> -> Actual -> Actual & List<&2,U32>,order:List<&2,U32>,unknown:List<&2,U32>,ids:List<&2,U32>,state:Actual) -> Actual & List<&2,U32>:
  match ids:
    case []:(state,unknown)
    case id <> rest:returned(~Actual,order,unknown,apply(id <> rest,state))
def apply(~Actual:Type,~publish:List<&2,U32> -> Actual -> Actual & List<&2,U32>,+order:List<&2,U32>,+ids:List<&2,U32>,state:Actual) -> Actual & List<&2,U32>:
  apply_selected(~Actual,~publish,order,unknown(order,ids),selected(order,ids),state)
