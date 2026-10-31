import Base
import ../../src/ecs/world.bend as W
import ./query-systems.bend as Run
import ./query-observations.bend as Snapshot

def main() -> IO(Unit):
  IO.bind(Run.SeedRun,Unit,Run.run(W.factory()),result => Snapshot.printed("baseline=",result))
