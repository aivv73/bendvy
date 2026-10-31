import Base
import ../query-systems/application.bend as Application
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/lifecycle.bend as Life

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/added=" ++ Application.run(~First,~Query.Where{Life.Added{}}) ++ "\nSecond/changed=" ++ Application.run(~Second,~Query.Where{Life.Changed{}}))
