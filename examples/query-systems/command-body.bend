import ../../src/ecs/execution-effects.bend as Effects
import Base
import ./payloads.bend as P
import ./declarations.bend as D
import ./body.bend as Body
import ./command-row.bend as Row
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-command-local.bend as Local
import ../../src/ecs/execution-system.bend as Sys

type User is Type:
  User{token:Array<U32>,runs:U32}
def completed(~H:Type,~O:Type,token:Array<U32>,runs:U32,result:H & (O & Q.Report<String>)) -> H & (O & (User & Sys.Completion<String,String>)):
  match result:
    case (scope,(output,Q.Completed{errors})):(scope,(output,(User{token,runs},Body.completion(errors))))
    case (scope,(output,Q.LayoutRefused{})):(scope,(output,(User{token,runs},Sys.BodyError{"query-refused","not-invoked"})))
def counted(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~O:Type,~caps:Q.OutputEach<S,H,O,String>,~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,runs:U32,result:Array<U32> & U32) -> F(H & (O & (User & Sys.Completion<String,String>))):
  match result:
    case (token,id):Effects.pure(~F,(H & (O & (User & Sys.Completion<String,String>))),effects,completed(~H,~O,Array.set(U32,token,0,U32.add(id,1)),U32.add(runs,1),Q.each_output(~S,~H,~O,~String,caps)(scope,output)))
def run(~S:Data,~Permit:Data,~F:(Type -> Type),~effects:Effects.Effects<F>,~H:Type,~O:Type,~caps:Q.OutputEach<S,H,O,String>,~commands:Local.Commands<O,S,P.Output>,scope:H,output:O,user:User) -> F(H & (O & (User & Sys.Completion<String,String>))):
  match user:
    case User{token,runs}:counted(~S,~Permit,~F,~effects,~H,~O,~caps,~commands,scope,output,runs,Array.get(U32,token,0))
