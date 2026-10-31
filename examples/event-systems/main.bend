import Base
import ./scheduled.bend as Scenario
import ./payloads.bend as P

def run_affine(~S:Data) -> IO(String):Scenario.run(~S,~Array<U32>,~P.affine,ALeaf{90},[ALeaf{101},ALeaf{102},ALeaf{103},ALeaf{104}])
def run_data(~S:Data) -> IO(String):Scenario.run(~S,~U32,~P.reusable,90,[101,102,103,104])
def a_affine() -> IO(Unit):IO.bind(String,Unit,run_affine(~P.SchemaA),value=>IO.print("A-affine=" ++ value))
def b_affine() -> IO(Unit):IO.bind(String,Unit,run_affine(~P.SchemaB),value=>IO.print("B-affine=" ++ value))
def a_data() -> IO(Unit):IO.bind(String,Unit,run_data(~P.SchemaA),value=>IO.print("A-data=" ++ value))
def b_data() -> IO(Unit):IO.bind(String,Unit,run_data(~P.SchemaB),value=>IO.print("B-data=" ++ value))
def main() -> IO(Unit):IO.bind(Unit,Unit,a_affine(),_=>IO.bind(Unit,Unit,b_affine(),_=>IO.bind(Unit,Unit,a_data(),_=>b_data())))
