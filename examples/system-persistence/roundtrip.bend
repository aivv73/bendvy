import Base
import ./declarations.bend as Ordinary
import ./receiver.bend as Receiver
import ./execution.bend as Execution
import ./setup.bend as Setup
import ../../src/ecs/execution-save-plan.bend as Plan
import ../../src/ecs/execution-save-data.bend as Saved
import ../../src/ecs/execution-save-gate.bend as Gate
import ../../src/ecs/execution-save-recipe.bend as Recipe
import ../../src/ecs/dependency-application.bend as App

type Outcome<-S:Data> is Type:
  SetupRefused{result:Setup.Defined<S>}
  SaveRefused{schema:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)>,app:Execution.Application(~S),firstReport:App.Report<String,String>,outcome:Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>}
  Continued{firstReport:App.Report<String,String>,result:Execution.Resumed<S>}
def continued(~S:Data,firstReport:App.Report<String,String>,result:Execution.Resumed<S>) -> Outcome<S>:Continued{firstReport,result}
def saved(~S:Data,firstReport:App.Report<String,String>,result:Plan.Schema<S,Ordinary.components(~S),Ordinary.resources(~S)> & (Execution.Application(~S) & Gate.Outcome<Saved.Snapshot<S>,Recipe.Refusal>)) -> Outcome<S>:
  match result:
    case (schema,(app,Gate.Saved{input})):continued(~S,firstReport,Execution.resume(~S,Execution.restore(~S,schema,input,app)))
    case (schema,(app,outcome)):SaveRefused{schema,app,firstReport,outcome}
def first_completed(~S:Data,result:Execution.Application(~S) & App.Report<String,String>) -> Outcome<S>:
  match result:
    case (app,report):saved(~S,report,Execution.save(~S,Ordinary.schema(~S),app))
def defined(~S:Data,result:Setup.Defined<S>) -> Outcome<S>:
  match result:
    case Setup.ReaderRefused{world,reason}:SetupRefused{Setup.ReaderRefused{world,reason}}
    case Setup.LeftRefused{world,local,reader}:SetupRefused{Setup.LeftRefused{world,local,reader}}
    case Setup.RightRefused{world,left,local}:SetupRefused{Setup.RightRefused{world,left,local}}
    case Setup.Defined{app}:first_completed(~S,Execution.run(~S,app))
# Save the actual returned schedule, restore the retained receiver, and resume
# only after complete restoration. Every refusal returns its recovery owners.
def roundtrip(~S:Data,world:Receiver.World(~S)) -> Outcome<S>:defined(~S,Setup.setup(~S,world))
def alpha(world:Receiver.World(~Ordinary.Alpha)) -> Outcome<Ordinary.Alpha>:roundtrip(~Ordinary.Alpha,world)
def beta(world:Receiver.World(~Ordinary.Beta)) -> Outcome<Ordinary.Beta>:roundtrip(~Ordinary.Beta,world)
