import Base
import ../query-systems/commands-core.bend as Application
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/execution-deferred-settings.bend as Settings

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.print("First/added=" ++ Application.run_mode(~First,~Query.Where{Life.Added{}},Settings.defaults()) ++ "\nFirst/changed=" ++ Application.run_mode(~First,~Query.Where{Life.Changed{}},Settings.defaults()) ++ "\nFirst/changed-retained=" ++ Application.run_mode(~First,~Query.Where{Life.Changed{}},Settings.Settings{True{},False{},[],[]}) ++ "\nSecond/added=" ++ Application.run_mode(~Second,~Query.Where{Life.Added{}},Settings.defaults()) ++ "\nSecond/changed=" ++ Application.run_mode(~Second,~Query.Where{Life.Changed{}},Settings.defaults()) ++ "\nSecond/changed-retained=" ++ Application.run_mode(~Second,~Query.Where{Life.Changed{}},Settings.Settings{True{},False{},[],[]}))
