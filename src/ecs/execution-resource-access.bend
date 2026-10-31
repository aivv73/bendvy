import Base
import ./execution-resource-store.bend as Store
import ./change-tick.bend as Tick

type Reader<-H:Type,-V:Data> is Type:
  Reader{get:H -> H & Store.Lookup<V>}
  UnsupportedReader{}
type Writer<-H:Type,-P:Type,-V:Data> is Type:
  Writer{read:Reader<H,V>,own:@-Out:Type -> H -> (P -> P & Out) -> H & Store.Edit<P,Out>,own_at:@-Out:Type -> H -> (Tick.Tick -> P -> P & Out) -> H & Store.Edit<P,Out>}
  UnsupportedWriter{}
def Reads(~V:Data,H:Type) -> Type:Reader<H,V>
def Writes(~P:Type,~V:Data,H:Type) -> Type:Writer<H,P,V>
