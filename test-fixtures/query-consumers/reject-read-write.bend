import Base
import ./schema.bend as S
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/change-tick.bend as Tick

def write(~H:Type,cap:Q.GeneralReader<S.SchemaA,H,U32>) -> Q.GeneralWriter<S.SchemaA,H,S.Position,U32>:
  cap
