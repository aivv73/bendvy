import Base
import ./authority-case.bend as Case
import ../../../src/ecs/execution-system-registration.bend as Registration

def reconstitute(result:Registration.Meta<Case.Owner(~Unit)> & Unit) -> Case.Owner(~Array<U32>):
  match result:
    case (meta,local):Registration.restored(~Case.Schema,~Array<U32>,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.program(~Array<U32>),~Case.body,meta,local)
def launder(owner:Case.Owner(~Unit)) -> Case.Owner(~Array<U32>):
  reconstitute(Registration.detached(~Case.Schema,~Unit,~Unit,~Unit,~Unit,~Case.Ops,~Unit,~String,~Unit,~Case.program(~Unit),~Case.body,owner))
