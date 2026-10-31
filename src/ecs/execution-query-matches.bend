import Base
import ./lifecycle.bend as Life
import ./execution-query-domain.bend as D

type Recipe is Data:
  Read{domain:D.Domain}
  Write{domain:D.Domain}
  Both{left:Recipe,right:Recipe}
type Presence is Data:
  Optional{}
  Required{}
  With{}
  Without{}
type Row<-V:Data> is Data:
  Row{offset:U32,view:Maybe<&2,V>}
  StampedRow{offset:U32,view:Maybe<&2,V>,stamp:Life.Stamp}
# Raw Row carries unknown lifecycle metadata; canonical caches use StampedRow.
def row_offset(-V:Data,row:Row<V>) -> U32:
  match row:
    case Row{offset,_}:offset
    case StampedRow{offset,_,_}:offset
def row_view(-V:Data,row:Row<V>) -> Maybe<&2,V>:
  match row:
    case Row{_,view}:view
    case StampedRow{_,view,_}:view
def row_stamp(-V:Data,row:Row<V>) -> Life.Stamp:
  match row:
    case Row{_,_}:Life.Stamp{None{},None{}}
    case StampedRow{_,None{},_}:Life.Stamp{None{},None{}}
    case StampedRow{_,Some{_},stamp}:stamp
type Single<-V:Data> is Data:
  NoMatch{}
  One{row:Row<V>}
  Multiple{}
def present(-V:Data,value:Maybe<&2,V>) -> Bool:
  match value:
    case None{}:False{}
    case Some{_}:True{}
def membership(-V:Data,presence:Presence,value:Maybe<&2,V>) -> Bool:
  match presence:
    case Optional{}:True{}
    case Required{}:present(V,value)
    case With{}:present(V,value)
    case Without{}:Bool.not(present(V,value))
def selected_row(-V:Data,offset:U32,view:Maybe<&2,V>,rows:List<&2,Row<V>>,matched:Bool) -> List<&2,Row<V>>:
  match matched:
    case False{}:rows
    case True{}:Row{offset,view} <> rows
def single(-V:Data,rows:List<&2,Row<V>>) -> Single<V>:
  match rows:
    case []:NoMatch{}
    case row <> []:One{row}
    case _ <> _ <> _:Multiple{}
def count(-V:Data,rows:List<&2,Row<V>>) -> U32:
  match rows:
    case []:0
    case _ <> rest:U32.add(1,count(V,rest))

def inventory_valid(result:D.Validation) -> Bool:
  match result:
    case D.Valid{}:True{}
    case _:False{}
def validate_recipe(+capacity:U32,recipe:Recipe) -> Bool:
  match recipe:
    case Read{domain}:inventory_valid(D.validate(capacity,domain))
    case Write{domain}:inventory_valid(D.validate(capacity,domain))
    case Both{left,right}:Bool.and(validate_recipe(capacity,left),validate_recipe(capacity,right))
