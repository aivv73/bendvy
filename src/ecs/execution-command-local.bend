import Base
import ./execution-effects.bend as E
import ./world.bend as W
import ./execution-system.bend as Sys
import ./execution-command-buffer.bend as Buffer
import ./execution-command-permission.bend as Permission

# The buffer is a separate affine owner from gameplay scope and user captures.
# This wrapper is the registered system's Local, so every executor outcome
# returns it through the existing system owner, including refusal/body error.
type Local<-S:Data,-P:Type,-D:Type,-User:Type> is Type:
  Local{user:User,commands:Buffer.Buffer<S,P,D>,permission:Permission.Permission}
type Commands<-Q:Type,-S:Data,-P:Type> is Type:
  Commands{insert:Q -> W.Handle<S> -> P -> Q,remove:Q -> W.Handle<S> -> Q}
def fresh(~S:Data,~P:Type,~D:Type,~User:Type,user:User,permission:Permission.Permission) -> Local<S,P,D,User>:
  Local{user,Buffer.empty(~S,~P,~D),permission}
def insert_field(~Q:Type,~S:Data,~P:Type,commands:Commands<Q,S,P>) -> Q -> W.Handle<S> -> P -> Q:
  match commands:
    case Commands{insert,_}:insert
def remove_field(~Q:Type,~S:Data,~P:Type,commands:Commands<Q,S,P>) -> Q -> W.Handle<S> -> Q:
  match commands:
    case Commands{_,remove}:remove
def returned(~S:Data,~P:Type,~D:Type,~User:Type,~Error:Data,~Out:Data,~H:Type,permission:Permission.Permission,result:H & (Buffer.Buffer<S,P,D> & (User & Sys.Completion<Error,Out>))) -> H & (Local<S,P,D,User> & Sys.Completion<Error,Out>):
  match result:
    case (scope,(commands,(user,completion))):(scope,(Local{user,commands,permission},completion))

# Internal body adapter; the ordinary registration layer must select the
# component family from its closed schema and inventory this buffer for barriers.
# Both H and Q remain abstract to gameplay. The body never sees a World,
# the allocator, the concrete buffer constructor, or an application callback.
def canonical(~S:Data,~P:Type,~D:Type) -> Commands<Buffer.Buffer<S,P,D>,S,P>:
  Commands{Buffer.insert(~S,~P,~D),Buffer.remove(~S,~P,~D)}
def invoke(~S:Data,~P:Type,~D:Type,~Permit:Data,~F:Type -> Type,~effects:E.Effects<F>,~User:Type,~Error:Data,~Out:Data,~Ops:Data -> (Type -> Type) -> Type -> Type -> Type,~body:@-Permit:Data -> @-F:(Type -> Type) -> @-effects:E.Effects<F> -> @-H:Type -> @-Q:Type -> @-caps:Ops(Permit,F,H,Q) -> @-commands:Commands<Q,S,P> -> H -> Q -> User -> F(H & (Q & (User & Sys.Completion<Error,Out>))),~H:Type,~caps:Ops(Permit,F,H,Buffer.Buffer<S,P,D>),scope:H,local:Local<S,P,D,User>) -> F(H & (Local<S,P,D,User> & Sys.Completion<Error,Out>)):
  match local:
    case Local{user,commands,permission}:E.map(~F,(H & (Buffer.Buffer<S,P,D> & (User & Sys.Completion<Error,Out>))),(H & (Local<S,P,D,User> & Sys.Completion<Error,Out>)),effects,body(Permit,F,effects,H,Buffer.Buffer<S,P,D>,caps,canonical(~S,~P,~D),scope,commands,user),result => returned(~S,~P,~D,~User,~Error,~Out,~H,permission,result))
