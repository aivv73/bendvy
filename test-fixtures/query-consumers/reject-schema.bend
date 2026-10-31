import Base
import ./schema.bend as S
import ../../src/ecs/execution-composer-layout.bend as L

def cross(slot:L.ColumnSlot<S.SchemaA,L.Viewed<S.Position,U32>,"Position",S.positions()>) -> L.ColumnSlot<S.SchemaB,L.Viewed<S.Position,U32>,"Position",S.positions()>:
  slot
