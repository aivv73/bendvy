import Base
import ../pending-boundaries.bend as Ordinary
import ../../../src/ecs/dependency-application.bend as App
import ../../../src/ecs/dependency-executor.bend as Exec

# Draft, unapproved and unproved. Actual affine applications are erased logical
# binders, not reusable owner projections. These laws constrain result handling,
# not whole-run scheduling, physical concurrency or native IO.

# Guarantees: the actual machine completion hook preserves a Stopped application,
# its error and observations, including every queued owner it already contains.
# Bevy code: https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_app/src/sub_app.rs#L145-L159
# Bevy behavior: tracker maintenance follows the default schedule update.
# Bend adaptation: explicit Stopped does not complete an update or rotate stream
# generations. This does not prove the executor chooses Stopped on escalation.
law stopped_machine_application_exact:
  for -app:Ordinary.Application()
  for -error:String
  for -events:List<&2,Exec.Observation<String,String>>
  {Ordinary.completed((app,App.Stopped{error,events})) == (app,App.Stopped{error,events}) : (Ordinary.Application() & App.Report<String,String>)}
