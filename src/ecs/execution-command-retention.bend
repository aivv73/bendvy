import Base
import ./dependency-registration.bend as Reg
import ./change-tick.bend as Tick
import ./execution-deferred-settings.bend as Settings

def pending_none(~World:Type,~Owners:Type,_:List<&2,U32>,world:World,owners:Owners) -> World & (Owners & Bool):
  (world,(owners,False{}))
def publish_none(~World:Type,~Owners:Type,_:List<&2,U32>,_:Tick.Tick,world:World,owners:Owners) -> World & Owners:
  (world,owners)
def collect_none(~Owners:Type,_:List<&2,U32>,owners:Owners) -> Owners & List<&2,U32>:
  (owners,[])
def pending_right(~World:Type,~L:Type,~R:Type,left:L,routing:List<&2,U32>,leftPending:Bool,result:World & (R & Bool)) -> World & (Reg.Product<L,R> & Bool):
  match result:
    case (world,(right,rightPending)):(world,(Reg.Product{left,right,routing},Bool.or(leftPending,rightPending)))
def pending_left(~World:Type,~L:Type,~R:Type,~rightPending:List<&2,U32> -> World -> R -> World & (R & Bool),ids:List<&2,U32>,right:R,routing:List<&2,U32>,result:World & (L & Bool)) -> World & (Reg.Product<L,R> & Bool):
  match result:
    case (world,(left,leftPending)):pending_right(~World,~L,~R,left,routing,leftPending,rightPending(ids,world,right))
def pending_pair(~World:Type,~L:Type,~R:Type,~leftPending:List<&2,U32> -> World -> L -> World & (L & Bool),~rightPending:List<&2,U32> -> World -> R -> World & (R & Bool),ids:List<&2,U32>,world:World,owners:Reg.Product<L,R>) -> World & (Reg.Product<L,R> & Bool):
  match ids owners:
    case +ids Reg.Product{left,right,routing}:pending_left(~World,~L,~R,~rightPending,ids,right,routing,leftPending(ids,world,left))
def published_right(~World:Type,~L:Type,~R:Type,left:L,routing:List<&2,U32>,result:World & R) -> World & Reg.Product<L,R>:
  match result:
    case (world,right):(world,Reg.Product{left,right,routing})
def published_left(~World:Type,~L:Type,~R:Type,right:R,routing:List<&2,U32>,result:World & L) -> World & Reg.Product<L,R>:
  match result:
    case (world,left):(world,Reg.Product{left,right,routing})
def publish_side(~World:Type,~L:Type,~R:Type,~leftPublish:List<&2,U32> -> Tick.Tick -> World -> L -> World & L,~rightPublish:List<&2,U32> -> Tick.Tick -> World -> R -> World & R,id:U32,tick:Tick.Tick,world:World,left:L,right:R,routing:List<&2,U32>,inLeft:Bool) -> World & Reg.Product<L,R>:
  match inLeft:
    case True{}:published_left(~World,~L,~R,right,routing,leftPublish([id],tick,world,left))
    case False{}:published_right(~World,~L,~R,left,routing,rightPublish([id],tick,world,right))
def publish_one(~World:Type,~L:Type,~R:Type,~leftPublish:List<&2,U32> -> Tick.Tick -> World -> L -> World & L,~rightPublish:List<&2,U32> -> Tick.Tick -> World -> R -> World & R,+id:U32,tick:Tick.Tick,world:World,owners:Reg.Product<L,R>) -> World & Reg.Product<L,R>:
  match owners:
    case Reg.Product{left,right,+routing}:publish_side(~World,~L,~R,~leftPublish,~rightPublish,id,tick,world,left,right,routing,Settings.member(id,routing))
def published_next(~World:Type,~L:Type,~R:Type,next:World -> Reg.Product<L,R> -> World & Reg.Product<L,R>,result:World & Reg.Product<L,R>) -> World & Reg.Product<L,R>:
  match result:
    case (world,owners):next(world,owners)
# The schedule has selected actual IDs in topological order. Each ID follows
# one Product route; sibling owners are retained without visiting their buffers.
def publish_pair(~World:Type,~L:Type,~R:Type,~leftPublish:List<&2,U32> -> Tick.Tick -> World -> L -> World & L,~rightPublish:List<&2,U32> -> Tick.Tick -> World -> R -> World & R,ids:List<&2,U32>,tick:Tick.Tick,world:World,owners:Reg.Product<L,R>) -> World & Reg.Product<L,R>:
  match ids tick:
    case [] _:(world,owners)
    case id <> rest +tick:published_next(~World,~L,~R,world => owners => publish_pair(~World,~L,~R,~leftPublish,~rightPublish,rest,tick,world,owners),publish_one(~World,~L,~R,~leftPublish,~rightPublish,id,tick,world,owners))
def collected_right(~L:Type,~R:Type,left:L,routing:List<&2,U32>,leftIds:List<&2,U32>,result:R & List<&2,U32>) -> Reg.Product<L,R> & List<&2,U32>:
  match result:
    case (right,rightIds):(Reg.Product{left,right,routing},List.append(&2,U32,leftIds,rightIds))
def collected_left(~L:Type,~R:Type,~rightCollect:List<&2,U32> -> R -> R & List<&2,U32>,ids:List<&2,U32>,right:R,routing:List<&2,U32>,result:L & List<&2,U32>) -> Reg.Product<L,R> & List<&2,U32>:
  match result:
    case (left,leftIds):collected_right(~L,~R,left,routing,leftIds,rightCollect(ids,right))
# Queue retention is independent of registration applicability, so refused
# publication keeps the actual payloads and IDs for retry and pending-save.
def collect_pair(~L:Type,~R:Type,~leftCollect:List<&2,U32> -> L -> L & List<&2,U32>,~rightCollect:List<&2,U32> -> R -> R & List<&2,U32>,ids:List<&2,U32>,owners:Reg.Product<L,R>) -> Reg.Product<L,R> & List<&2,U32>:
  match ids owners:
    case +ids Reg.Product{left,right,routing}:collected_left(~L,~R,~rightCollect,ids,right,routing,leftCollect(ids,left))
