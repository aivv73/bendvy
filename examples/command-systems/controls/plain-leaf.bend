import Base
import ./registered.bend as R
import ./positive.bend as P
import ../../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../../src/ecs/execution-composer-layout.bend as Layout
import ../../../src/ecs/execution-command-system.bend as Cmd

def bad(~S:Data,owner:R.Node(~S)) -> Leaf.Node(~S,~R.layout(),~Layout.EmptyLayout{},~Unit,~Cmd.ScopedOps(~S,~R.layout(),~Layout.EmptyLayout{},~Layout.AtLeaf{},~R.Ops),~Cmd.Captures(~S,~R.layout(),~Layout.EmptyLayout{},~Layout.AtLeaf{},~P.Capture<S>),~String,~Unit,~Cmd.program_for_buffer(~S,~(Layout.columns(~S,R.layout())),~Unit,~R.layout(),~Layout.EmptyLayout{},~Layout.AtLeaf{},~R.Ops,~R.declaration(~S)),~P.body(~S)):
  owner
