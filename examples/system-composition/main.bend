import Base
import ./forms.bend as Forms
import ./bootstrap.bend as Bootstrap
import ./registration.bend as Registration
import ./application.bend as Application
import ./observation.bend as Observe
import ./provisioning.bend as Provisioning
import ../../src/ecs/dependency-composer-program.bend as Scoped
import ../../src/ecs/dependency-plan.bend as Plan

def completed(prefix:String,result:Application.Application() & Application.Report()) -> String:
  match result:
    case (application,report):prefix ++ Observe.report(report) ++ "|" ++ Observe.application(application)
def missing(application:Application.Application()) -> String:
  completed("",Application.run(application))
def twice_returned(repeated:Bool,first:String,result:Application.Application() & Application.Report()) -> String:
  match repeated result:
    case False{},(application,report):first ++ Observe.report(report) ++ "|" ++ Observe.application(application)
    case True{},(application,report):completed(first ++ Observe.report(report) ++ "|",Application.run(application))
def first_returned(repeated:Bool,result:Application.Application() & Application.Report()) -> String:
  match result:
    case (application,report):twice_returned(repeated,Observe.report(report) ++ "|",Application.run(Provisioning.extra(Provisioning.install(application))))
def provided(application:Application.Application()) -> String:
  first_returned(False{},Application.run(application))
def repeated(application:Application.Application()) -> String:
  first_returned(True{},Application.run(application))
def boot(finish:Application.Application() -> String,result:Bootstrap.Outcome) -> String:
  match result:
    case Bootstrap.Registered{Registration.Registered{application}}:finish(application)
    case result:Observe.bootstrap(result)
def invalid_groups() -> List<&2,Scoped.Nested>:
  [Scoped.Nested{[0],[Plan.Edge{1,3}]}]
def printed(prefix:String,value:String,next:Unit -> IO(Unit)) -> IO(Unit):
  IO.bind(Unit,Unit,IO.print(prefix ++ value ++ "\n"),_ => next(Unit{}))
def main() -> IO(Unit):
  printed("missing=",boot(missing,Bootstrap.run(Application.groups())),_ => printed("provided=",boot(provided,Bootstrap.run(Application.groups())),_ => printed("repeated=",boot(repeated,Bootstrap.run(Application.groups())),_ => printed("invalid-nesting=",boot(missing,Bootstrap.run(invalid_groups())),_ => printed("optional-none=",boot(missing,Bootstrap.run_optional_none(Application.groups())),_ => IO.print("validation=" ++ Forms.validation() ++ "\nschema-collision=" ++ Forms.schema_refusal() ++ "\nnamespace-refusal=" ++ Forms.namespace_refusal()))))))
