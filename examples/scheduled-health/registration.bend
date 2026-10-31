import Base
import ./schema.bend as D
import ./system.bend as Decay
import ./spawn.bend as Spawn
import ./enabled.bend as Enabled
import ./root.bend as Root
import ./application.bend as Application
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-generalized-system-leaf.bend as System
import ../../src/ecs/execution-retained-system.bend as Scope
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-command-system.bend as Cmd

def guarded(left:Root.Binding(),right:Root.PeerBinding(),result:Enabled.Compilation() & Sys.Defined<D.World(),Enabled.Owner(),Unit>) -> IO(Unit):
  match result:
    case (compilation,Sys.Defined{world,guard}):Application.start(Root.build(world,left,right,Scope.pack(Enabled.Compilation(),Enabled.Owner(),compilation,guard)))
    case _:IO.die(Unit,1,"enabled condition registration refused")
def peer(left:Root.Binding(),result:Root.PeerCompilation() & Sys.Defined<D.World(),Root.Peer(),Unit>) -> IO(Unit):
  match result:
    case (compilation,Sys.Defined{world,owner}):guarded(left,Scope.pack(Root.PeerCompilation(),Root.Peer(),compilation,owner),System.define_with_compilation(~D.Schema,~D.components(),~D.resources(),~Unit,~Enabled.Ops,~Unit,~String,~Bool,~Enabled.kernel,~Enabled.body,Enabled.construction(),world,"Health simulation enabled",Unit{}))
    case _:IO.die(Unit,1,"health decay registration refused")
def author(result:Root.Compilation() & Sys.Defined<D.World(),Root.Owner(),Cmd.Captures(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.User)>) -> IO(Unit):
  match result:
    case (compilation,Sys.Defined{world,owner}):peer(Scope.pack(Root.Compilation(),Root.Owner(),compilation,owner),System.define_with_compilation(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.Ops,~Unit,~String,~Unit,~Decay.kernel,~Decay.body,Decay.compiled(),world,"Health simulation",Unit{}))
    case _:IO.die(Unit,1,"health seed registration refused")
def attach(world:D.World()) -> IO(Unit):
  author(Author.define_with_compilation(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~{==},Spawn.compilation(),world,"Health deferred spawns",Spawn.initial()))
