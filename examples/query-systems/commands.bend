import Base
import ./commands-core.bend as Commands
import ../../src/ecs/execution-deferred-settings.bend as Settings

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/final=" ++ Commands.run(~First,Settings.defaults()) ++ "\nFirst/retained=" ++ Commands.run(~First,Settings.Settings{True{},False{},[],[]}) ++ "\nSecond/final=" ++ Commands.run(~Second,Settings.defaults()) ++ "\nSecond/retained=" ++ Commands.run(~Second,Settings.Settings{True{},False{},[],[]}))
