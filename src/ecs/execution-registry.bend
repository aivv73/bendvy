import Base
import ./dependency-registration.bend as Reg
import ./dependency-executor.bend as Exec
import ./dependency-plan.bend as Plan

type Facts<-Registry:Type> is Type:
  Facts{registry:Registry,deferred:List<&2,U32>}
def ordinary(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),registry:Reg.Registry<World,Owners,Error,Out,dispatch>) -> Facts<Reg.Registry<World,Owners,Error,Out,dispatch>>:
  Facts{registry,[]}
def command(~World:Type,~Owners:Type,~Error:Data,~Out:Data,~dispatch:Owners -> World -> U32 -> Owners & (World & Exec.Invocation<Error,Out>),registry:Reg.Registry<World,Owners,Error,Out,dispatch>) -> Facts<Reg.Registry<World,Owners,Error,Out,dispatch>>:
  match registry:
    case Reg.Registry{owners,+nodes}:Facts{Reg.Registry{owners,nodes},Reg.ids(nodes)}
def paired(~World:Type,~L:Type,~R:Type,~Error:Data,~Out:Data,~leftDispatch:L -> World -> U32 -> L & (World & Exec.Invocation<Error,Out>),~rightDispatch:R -> World -> U32 -> R & (World & Exec.Invocation<Error,Out>),left:Facts<Reg.Registry<World,L,Error,Out,leftDispatch>>,right:Facts<Reg.Registry<World,R,Error,Out,rightDispatch>>) -> Facts<Reg.Registry<World,Reg.Product<L,R>,Error,Out,Reg.paired_dispatch(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch)>>:
  match left right:
    case Facts{left,ld} Facts{right,rd}:Facts{Reg.paired(~World,~L,~R,~Error,~Out,~leftDispatch,~rightDispatch,left,right),List.append(&2,U32,ld,rd)}
