import Base
import ./schema.bend as S
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/execution-composer-layout.bend as L

def duplicate(column:Col.Column<S.SchemaA,L.Viewed<S.Position,U32>>) -> Col.Column<S.SchemaA,L.Viewed<S.Position,U32>> & Col.Column<S.SchemaA,L.Viewed<S.Position,U32>>:
  (column,column)
