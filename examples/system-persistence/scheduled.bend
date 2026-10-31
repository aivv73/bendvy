import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./restore.bend as Restore
import ./restore-receipt.bend as Receipt
import ./staging.bend as Stage
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-world.bend as Save
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-schedule.bend as Schedule
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-plan.bend as Build
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import ../../src/ecs/world.bend as W

def Application(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type) -> Type:Schedule.Scheduled<App.State<Receiver.World(~S),Owners,Guards,Handler>>
type Held<-Owners:Type,-Guards:Type,-Handler:Type> is Type:
  Held{owners:Owners,guards:Guards,handler:Handler,stateBindings:List<&2,App.Binding>,plan:Build.Build<String>,appBindings:List<&2,App.Binding>,deferred:Schedule.Deferred}
def rejoin(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Owners,Guards,Handler>,world:Receiver.World(~S)) -> Application(~S,~Owners,~Guards,~Handler):
  match held:
    case Held{owners,guards,handler,stateBindings,plan,appBindings,deferred}:Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,deferred}
def saved(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Owners,Guards,Handler>,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Receiver.World(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S,~Owners,~Guards,~Handler) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (schema,(world,outcome)):(schema,(rejoin(~S,~Owners,~Guards,~Handler,held,world),outcome))
def save_checked(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,result:Application(~S,~Owners,~Guards,~Handler) & Bool) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S,~Owners,~Guards,~Handler) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  match result:
    case (app,True{}):(schema,(app,Gate.RefusedPending{}))
    case (Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,deferred},False{}):saved(~S,~Owners,~Guards,~Handler,Held{owners,guards,handler,stateBindings,plan,appBindings,deferred},Save.save(~S,~Ordinary.components(~S),~Ordinary.resources(~S),~Unit,schema,world))
def restored(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Owners,Guards,Handler>,result:Receiver.World(~S) & Receipt.Receipt<S>) -> Application(~S,~Owners,~Guards,~Handler) & Receipt.Receipt<S>:
  match result:
    case (world,receipt):(rejoin(~S,~Owners,~Guards,~Handler,held,world),receipt)
def restore_checked(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,result:Application(~S,~Owners,~Guards,~Handler) & Bool) -> Application(~S,~Owners,~Guards,~Handler) & Receipt.Receipt<S>:
  match result:
    case (app,True{}):(app,Receipt.Receipt{Stage.empty(~S,schema),input,[],[],[],[],None{},[],Receipt.Pending{}})
    case (Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,deferred},False{}):restored(~S,~Owners,~Guards,~Handler,Held{owners,guards,handler,stateBindings,plan,appBindings,deferred},Receipt.extract(~S,Restore.restore(~S,schema,input,world)))
def LeftColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Receiver.Components(~S),Layout.InLeft{Layout.AtLeaf{}}))
def RightColumn(~S:Data) -> Type:Layout.columns(~S,Layout.subtree(Receiver.Components(~S),Layout.InRight{Layout.AtLeaf{}}))
def LeftResource(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InLeft{Layout.AtLeaf{}}))
def RightResource(~S:Data) -> Type:Layout.resources(~S,Layout.subtree(Plan.layout(Ordinary.resources(~S)),Layout.InRight{Layout.AtLeaf{}}))
def registered(+id:U32,entries:List<&2,W.RegistrationMeta>) -> Bool:
  match entries:
    case []:False{}
    case W.RegistrationMeta{other,_,_} <> rest:Bool.or(U32.is_eq(id,other),registered(id,rest))
def unknown(ids:List<&2,U32>,+entries:List<&2,W.RegistrationMeta>) -> Bool:
  match ids:
    case []:False{}
    case id <> rest:Bool.or(Bool.not(registered(id,entries)),unknown(rest,entries))
def pending_returned(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,held:Held<Unit,Guards,Handler>,blocked:Bool,result:Receiver.World(~S) & (Owners & Bool)) -> Application(~S,~Owners,~Guards,~Handler) & Bool:
  match held result:
    case Held{_,guards,handler,stateBindings,plan,appBindings,deferred}, (world,(owners,pending)):(rejoin(~S,~Owners,~Guards,~Handler,Held{owners,guards,handler,stateBindings,plan,appBindings,deferred},world),Bool.or(blocked,pending))
def pending_world(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,~hasPending:List<&2,U32> -> Receiver.World(~S) -> Owners -> Receiver.World(~S) & (Owners & Bool),guards:Guards,handler:Handler,stateBindings:List<&2,App.Binding>,plan:Build.Build<String>,appBindings:List<&2,App.Binding>,+deferred:Schedule.Deferred,world:Receiver.World(~S),owners:Owners) -> Application(~S,~Owners,~Guards,~Handler) & Bool:
  match deferred world:
    case Schedule.Deferred{systems,_,unapplied,_,_}, W.World{namespace,allocator,columns,resources,events,pending,+registrations,next,clock,lifecycle}:pending_returned(~S,~Owners,~Guards,~Handler,Held{Unit{},guards,handler,stateBindings,plan,appBindings,deferred},unknown(unapplied,registrations),hasPending(systems,W.World{namespace,allocator,columns,resources,events,pending,registrations,next,clock,lifecycle},owners))
def pending(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,~hasPending:List<&2,U32> -> Receiver.World(~S) -> Owners -> Receiver.World(~S) & (Owners & Bool),app:Application(~S,~Owners,~Guards,~Handler)) -> Application(~S,~Owners,~Guards,~Handler) & Bool:
  match app:
    case Schedule.Scheduled{App.State{world,owners,guards,handler,stateBindings},plan,appBindings,deferred}:pending_world(~S,~Owners,~Guards,~Handler,~hasPending,guards,handler,stateBindings,plan,appBindings,deferred,world,owners)
def save(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,~hasPending:List<&2,U32> -> Receiver.World(~S) -> Owners -> Receiver.World(~S) & (Owners & Bool),schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,app:Application(~S,~Owners,~Guards,~Handler)) -> Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Application(~S,~Owners,~Guards,~Handler) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>):
  save_checked(~S,~Owners,~Guards,~Handler,schema,pending(~S,~Owners,~Guards,~Handler,~hasPending,app))
def restore(~S:Data,~Owners:Type,~Guards:Type,~Handler:Type,~hasPending:List<&2,U32> -> Receiver.World(~S) -> Owners -> Receiver.World(~S) & (Owners & Bool),schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,input:Saved.Snapshot<S>,app:Application(~S,~Owners,~Guards,~Handler)) -> Application(~S,~Owners,~Guards,~Handler) & Receipt.Receipt<S>:
  restore_checked(~S,~Owners,~Guards,~Handler,schema,input,pending(~S,~Owners,~Guards,~Handler,~hasPending,app))
