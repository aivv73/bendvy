import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./pending.bend as Pending
import ./observation.bend as Observe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-composer-schema.bend as Schema
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-reservation-materialization.bend as Materialize
import ../../src/ecs/execution-reservation-bundle.bend as Bundle
import ../../src/ecs/execution-command-permission.bend as Permission
import ../../src/ecs/world.bend as W
import ../../src/ecs/world-io.bend as WorldIO
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/change-tick.bend as Tick

def observed(~S:Data,result:Pending.Outcome<S>) -> String:Pending.observed(~S,result)
def published(~S:Data,result:Bundle.Publication<S,Layout.columns(~S,Receiver.Components(~S)),Receiver.Resources(~S),Unit,Receiver.Components(~S)>) -> String:
  match result:
    case Bundle.Materialized{world,_,_}:observed(~S,Pending.run(~S,world))
    case Bundle.RefusedPublication{_,_,_,_}:"initial-publication-refused"
def clocked(~S:Data,handle:W.Handle<S>,result:Receiver.World(~S) & Tick.Tick) -> String:
  match result:
    case (world,tick):published(~S,Materialize.apply_at(~S,~Receiver.Resources(~S),~Unit,~Receiver.Components(~S),Permission.EntityStructural{},world,handle,Product.Owner{Some{Ordinary.Actor{"ordinary",ALeaf{41}}},Some{Ordinary.Scratch{ALeaf{808}}}},tick))
def reserved(~S:Data,result:Receiver.World(~S) & W.Reservation<S>) -> String:
  match result:
    case (world,W.Reserved{+handle}):clocked(~S,handle,W.write_clock(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,W.mark_pending(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,world,handle)))
    case (_,W.ReservationRejected{_}):"initial-reservation-refused"
def created(~S:Data,result:WorldIO.Creation<S,Layout.columns(~S,Receiver.Components(~S)),Receiver.Resources(~S),Unit>) -> IO(String):
  match result:
    case WorldIO.Created{world}:IO.pure(String,reserved(~S,W.reserve_id(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,Schema.initialized_world(~S,~Receiver.Components(~S),~Plan.layout(Ordinary.resources(~S)),~Unit,world))))
    case WorldIO.Refused{_}:IO.pure(String,"world-creation-refused")
def run(~S:Data) -> IO(String):
  IO.bind(WorldIO.Creation<S,Layout.columns(~S,Receiver.Components(~S)),Receiver.Resources(~S),Unit>,String,WorldIO.create(~S,~Layout.columns(~S,Receiver.Components(~S)),~Receiver.Resources(~S),~Unit,~Ordinary.empty(~S),Ordinary.initial_resources(~S)),result => created(~S,result))
def print_beta(_:Unit) -> IO(Unit):IO.bind(String,Unit,run(~Ordinary.Beta),value => IO.print("beta " ++ value))
def main() -> IO(Unit):IO.bind(Unit,Unit,IO.bind(String,Unit,run(~Ordinary.Alpha),value => IO.print("alpha " ++ value)),print_beta)
