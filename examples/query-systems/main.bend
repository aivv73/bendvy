import Base
import ./application.bend as Application
import ../../src/ecs/execution-query.bend as Query

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First=" ++ Application.run(~First,~Query.AllRows{}) ++ "\nSecond=" ++ Application.run(~Second,~Query.AllRows{}) ++ "\nFirst/error=" ++ Application.run_error(~First,~Query.AllRows{}))
