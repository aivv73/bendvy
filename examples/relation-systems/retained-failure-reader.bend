import Base
import ./actor.bend as Actor
import ./failure-reader.bend as Existing
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/execution-retained-system.bend as Retained
import ../../src/ecs/execution-declaration.bend as Decl

type Schema is Data:
  RetainedScene{}
def C() -> Type:Layout.columns(~Schema,Actor.components())
def R() -> Type:Layout.resources(~Schema,Actor.resources(~Schema))
def WC() -> Type:C()
def Local() -> Type:Existing.State(~Schema)
def Owner() -> Type:Existing.Owner(~Schema)
def Node() -> Type:Existing.Node(~Schema)
def retire(node:Node()) -> Owner():
  Retained.owner(Decl.Compilation<Schema,WC(),C(),R(),Existing.Ops(~Schema)>,Owner(),node)
