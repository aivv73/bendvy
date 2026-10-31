import Base
import ./schema.bend as S
import ./declarations.bend as D
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec

def motion_dispatch() -> D.MotionOwners() -> S.World() -> U32 -> D.MotionOwners() & (S.World() & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~S.World(),~D.MotionNode(),~D.MotionNode(),~String,~String,~D.motion_dispatch(),~D.motion_dispatch())
def labels_dispatch() -> D.LabelsOwners() -> S.World() -> U32 -> D.LabelsOwners() & (S.World() & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~S.World(),~D.LabelsNode(),~D.LabelsNode(),~String,~String,~D.labels_dispatch(),~D.labels_dispatch())
def run() -> D.Owners() -> S.World() -> U32 -> D.Owners() & (S.World() & Exec.Invocation<String,String>):
  Reg.paired_dispatch(~S.World(),~D.MotionOwners(),~D.LabelsOwners(),~String,~String,~motion_dispatch(),~labels_dispatch())
