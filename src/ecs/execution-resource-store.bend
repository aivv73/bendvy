import Base
import ./lifecycle.bend as Life

type Lookup<-V:Data> is Data:
  Viewed{view:V,stamp:Life.Stamp}
  LookupRefused{}
type Edit<-P:Type,-Out:Type> is Type:
  Edited{output:Out}
  Unchanged{unused:P -> P & Out}
