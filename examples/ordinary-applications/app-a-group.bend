import Base
import ./app-a-payloads.bend as P
import ./app-a-schema.bend as D
import ./app-a-commands.bend as Author
import ./app-a-systems.bend as Systems
import ./app-a-captures.bend as Captures
import ../../src/ecs/execution-generalized-system-leaf.bend as Leaf
import ../../src/ecs/execution-registry.bend as Registry
import ../../src/ecs/dependency-registration.bend as Reg
import ../../src/ecs/dependency-executor.bend as Exec
def writer_dispatch() -> Systems.WriterNode() -> Systems.World() -> U32 -> Systems.WriterNode() & (Systems.World() & Exec.Invocation<String,String>):Leaf.dispatch(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Systems.WriterOps,~Systems.WriterLocal,~String,~String,~Systems.writer_kernel,~Systems.writer_body,~Systems.writer_compiled())
def writer_facts(node:Systems.WriterNode()) -> Registry.Facts<Reg.Registry<Systems.World(),Systems.WriterNode(),String,String,writer_dispatch()>>:Registry.ordinary(~Systems.World(),~Systems.WriterNode(),~String,~String,~writer_dispatch(),Leaf.facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Systems.WriterOps,~Systems.WriterLocal,~String,~String,~Systems.writer_kernel,~Systems.writer_body,~Systems.writer_compiled(),node))
def query_dispatch() -> Systems.QueryNode() -> Systems.World() -> U32 -> Systems.QueryNode() & (Systems.World() & Exec.Invocation<String,String>):Leaf.dispatch(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Systems.QueryOps,~Systems.QueryLocal,~String,~String,~Systems.query_kernel,~Systems.query_body,~Systems.query_compiled())
def query_facts(node:Systems.QueryNode()) -> Registry.Facts<Reg.Registry<Systems.World(),Systems.QueryNode(),String,String,query_dispatch()>>:Registry.ordinary(~Systems.World(),~Systems.QueryNode(),~String,~String,~query_dispatch(),Leaf.facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Systems.QueryOps,~Systems.QueryLocal,~String,~String,~Systems.query_kernel,~Systems.query_body,~Systems.query_compiled(),node))
def reader_dispatch() -> Systems.ReaderNode() -> Systems.World() -> U32 -> Systems.ReaderNode() & (Systems.World() & Exec.Invocation<String,String>):Leaf.dispatch(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Systems.ReaderOps,~Array<U32>,~String,~String,~Systems.reader_kernel,~Systems.reader_body,~Systems.reader_compiled())
def reader_facts(node:Systems.ReaderNode()) -> Registry.Facts<Reg.Registry<Systems.World(),Systems.ReaderNode(),String,String,reader_dispatch()>>:Registry.ordinary(~Systems.World(),~Systems.ReaderNode(),~String,~String,~reader_dispatch(),Leaf.facts(~P.AuditWorkshop,~D.components(),~Author.resources(),~Unit,~Systems.ReaderOps,~Array<U32>,~String,~String,~Systems.reader_kernel,~Systems.reader_body,~Systems.reader_compiled(),node))
def Tail() -> Type:Captures.Tail()
def tail_dispatch() -> Tail() -> Systems.World() -> U32 -> Tail() & (Systems.World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~Systems.World(),~Systems.QueryNode(),~Systems.ReaderNode(),~String,~String,~query_dispatch(),~reader_dispatch())
def run() -> Captures.Nodes() -> Systems.World() -> U32 -> Captures.Nodes() & (Systems.World() & Exec.Invocation<String,String>):Reg.paired_dispatch(~Systems.World(),~Systems.WriterNode(),~Tail(),~String,~String,~writer_dispatch(),~tail_dispatch())
def facts(writer:Systems.WriterNode(),query:Systems.QueryNode(),reader:Systems.ReaderNode()) -> Registry.Facts<Reg.Registry<Systems.World(),Captures.Nodes(),String,String,run()>>:Registry.paired(~Systems.World(),~Systems.WriterNode(),~Tail(),~String,~String,~writer_dispatch(),~tail_dispatch(),writer_facts(writer),Registry.paired(~Systems.World(),~Systems.QueryNode(),~Systems.ReaderNode(),~String,~String,~query_dispatch(),~reader_dispatch(),query_facts(query),reader_facts(reader)))
