import Base

type CompiledBinding<-Compilation:Type,-Owner:Type> is Type:
  CompiledBinding{-Held:Type,held:Held,same:{Held == Compilation & Owner : Type}}

def pack(-Compilation:Type,-Owner:Type,compilation:Compilation,owner:Owner) -> CompiledBinding<Compilation,Owner>:
  CompiledBinding{Compilation & Owner,(compilation,owner),{==}}
def unpack(-Compilation:Type,-Owner:Type,binding:CompiledBinding<Compilation,Owner>) -> Compilation & Owner:
  match binding:
    case CompiledBinding{Held,held,same}:
      %same : _
      held
def pack_pair(-Compilation:Type,-Owner:Type,pair:Compilation & Owner) -> CompiledBinding<Compilation,Owner>:
  match pair:
    case (compilation,owner):pack(Compilation,Owner,compilation,owner)
def owner_pair(-Compilation:Type,-Owner:Type,pair:Compilation & Owner) -> Owner:
  match pair:
    case (_,owner):owner
def owner(-Compilation:Type,-Owner:Type,binding:CompiledBinding<Compilation,Owner>) -> Owner:
  owner_pair(Compilation,Owner,unpack(Compilation,Owner,binding))
def owner_mapped(-Compilation:Type,-Owner:Type,-Out:Type,compilation:Compilation,result:Owner & Out) -> CompiledBinding<Compilation,Owner> & Out:
  match result:
    case (owner,out):(pack(Compilation,Owner,compilation,owner),out)
def owner_map_unpacked(-Compilation:Type,-Owner:Type,-Out:Type,observe:Owner -> Owner & Out,pair:Compilation & Owner) -> CompiledBinding<Compilation,Owner> & Out:
  match pair:
    case (compilation,owner):owner_mapped(Compilation,Owner,Out,compilation,observe(owner))
def map_owner(-Compilation:Type,-Owner:Type,-Out:Type,observe:Owner -> Owner & Out,binding:CompiledBinding<Compilation,Owner>) -> CompiledBinding<Compilation,Owner> & Out:
  owner_map_unpacked(Compilation,Owner,Out,observe,unpack(Compilation,Owner,binding))
