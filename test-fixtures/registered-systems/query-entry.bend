import Base
import ../../examples/query-systems/commands-core.bend as Commands
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/execution-deferred-settings.bend as Settings

type Schema is Data:
  Schema{}
def main() -> IO(Unit):
  IO.print("query=" ++ Commands.run_mode(~Schema,~Query.AllRows{},Settings.defaults()))
