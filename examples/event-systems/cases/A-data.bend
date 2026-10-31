import Base
import ../scheduled.bend as Scenario
import ../payloads.bend as P

def run() -> IO(String):Scenario.run(~P.SchemaA,~U32,~P.reusable,90,[101,102,103,104])
def main() -> IO(Unit):IO.bind(String,Unit,run(),value=>IO.print("A-data=" ++ value))
