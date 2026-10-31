import ../../src/ecs/execution-effects.bend as Effects
import Base
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-resource-access.bend as Resource
import ../../src/ecs/execution-resource-store.bend as Store
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/capabilities.bend as Cap
import ../../src/ecs/world.bend as W

type Position is Type:Position{token:Array<U32>,x:U32}
type Counter is Type:Counter{token:Array<U32>,count:U32,optional:Maybe<&1,Array<U32>>}
type Local<-S:Data> is Type:Local{token:Array<U32>,runs:U32,entity:W.Handle<S>}
def position_seen(+x:U32,result:Array<U32> & U32) -> Position & String:
  match result:
    case (token,id):(Position{token,x},U32.show(id) ++ ":" ++ U32.show(x))
def position(owner:Position) -> Position & String:
  match owner:
    case Position{token,x}:position_seen(x,Array.get(U32,token,0))
def counter_seen(+count:U32,optional:Maybe<&1,Array<U32>>,result:Array<U32> & U32) -> Counter & String:
  match result:
    case (token,id):(Counter{token,count,optional},U32.show(id) ++ ":" ++ U32.show(count))
def counter(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,count,optional}:counter_seen(count,optional,Array.get(U32,token,0))
def move(owner:Position) -> Position & String:
  match owner:
    case Position{token,x}:position(Position{token,U32.add(x,1)})
def increment(owner:Counter) -> Counter & String:
  match owner:
    case Counter{token,count,optional}:counter(Counter{token,U32.add(count,1),optional})
def Ops(~S:Data,Permit:Data,F:(Type -> Type),H:Type) -> Type:Cap.Bundle<Q.GeneralWriter<S,H,Position,String>,Resource.Writer<H,Counter,String>>
def Family(~S:Data) -> Data -> (Type -> Type) -> Type -> Type:Ops(~S)
def moved(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,local:Local<S>,result:H & Q.GeneralEdit<Position,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match result:
    case (scope,Q.GeneralEdited{pack}):(scope,(local,Sys.Success{pack}))
    case (scope,Q.GeneralUnchanged{_}):(scope,(local,Sys.Success{"absent"}))
def counted(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,positions:Q.GeneralWriter<S,H,Position,String>,local:Local<S>,result:H & Store.Edit<Counter,String>) -> H & (Local<S> & Sys.Completion<String,String>):
  match positions local result:
    case Q.GeneralWriter{_,modify} Local{token,runs,+entity},(scope,Store.Edited{_}):moved(~S,~Permit,~F,~H,Local{token,U32.add(runs,1),entity},modify(String,scope,entity,move))
    case _ local,(scope,_):(scope,(local,Sys.BodyError{"counter unavailable","local retained"}))
def body_caps(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,caps:Ops(~S,Permit,F,H),scope:H,local:Local<S>) -> H & (Local<S> & Sys.Completion<String,String>):
  match caps:
    case Cap.Bundle{positions,Resource.Writer{_,own,_}}:counted(~S,~Permit,~F,~H,positions,local,own(String,scope,increment))
    case _:(scope,(local,Sys.BodyError{"counter unsupported","local retained"}))
def body(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~caps:Ops(~S,Permit,F,H),scope:H,local:Local<S>) -> F(H & (Local<S> & Sys.Completion<String,String>)):
  Effects.pure(~F,(H & (Local<S> & Sys.Completion<String,String>)),effects,body_caps(~S,~Permit,~F,~H,caps,scope,local))
