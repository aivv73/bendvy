import Base
import ../scheduled.bend as Scenario
import ../payloads.bend as P

def run() -> IO(String):Scenario.run_future(~P.SchemaA,~Array<U32>,~P.affine,ALeaf{90},[ALeaf{101},ALeaf{102},ALeaf{103},ALeaf{104}])
def main() -> IO(Unit):IO.bind(String,Unit,run(),value=>IO.print("A-affine-future=" ++ value))
