import Base
import ../guarded-nodes.bend as Nodes

def escape(~S:Data,~Permit:Data,~F:(Type -> Type),~H:Type,cap:Nodes.RightOps(Permit,F,H),scope:H) -> Nodes.R(~S):scope
