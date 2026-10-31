import Base
import ./execution-query-matches.bend as Q
import ./lifecycle.bend as Life

type Lookup<-V:Data> is Data:
  OutsideDomain{}
  Known{view:Maybe<&2,V>}
def cached_lookup_here(-V:Data,view:Maybe<&2,V>,next:Lookup<V>,found:Bool) -> Lookup<V>:
  match found:
    case False{}:next
    case True{}:Known{view}
def cached_lookup(-V:Data,rows:List<&2,Q.Row<V>>,+offset:U32) -> Lookup<V>:
  match rows:
    case []:OutsideDomain{}
    case +row <> rest:cached_lookup_here(V,Q.row_view(V,row),cached_lookup(V,rest,offset),U32.is_eq(Q.row_offset(V,row),offset))
def cached_stamp(-V:Data,rows:List<&2,Q.Row<V>>,+index:U32) -> Life.Stamp:
  match rows:
    case []:Life.Stamp{None{},None{}}
    case +row <> rest:Life.choose(U32.is_eq(index,Q.row_offset(V,row)),Q.row_stamp(V,row),cached_stamp(V,rest,index))
