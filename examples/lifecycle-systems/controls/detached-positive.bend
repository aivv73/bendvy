import Base
import ./authority-case.bend as Case
import ../../../src/ecs/execution-system-registration.bend as Registration

def restored(result:Registration.Meta<Case.Owner(~Unit)> & Unit) -> Case.Owner(~Unit):
  match result:
    case (meta,local):Registration.restored(~Case.Schema,~Unit,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.program(~Unit),~Case.body,meta,local)
def roundtrip(owner:Case.Owner(~Unit)) -> Case.Owner(~Unit):
  restored(Registration.detached(~Case.Schema,~Unit,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.program(~Unit),~Case.body,owner))
