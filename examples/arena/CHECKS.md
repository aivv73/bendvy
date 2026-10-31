# Current execution evidence

The sequential application and its existing combat fixtures pass the concrete
source check. The stock 2.0.37 compiler emitted the game and fixture JavaScript
modules. The existing `host-smoke.mjs` passed its keyboard, draw, pause, focus,
tab visibility and restart checks, followed by its controlled health-bar,
area-pulse and chain-projectile checks. Its fixture overrides now consume the
same compiled IO protocol as the browser.

This harness uses a DOM/canvas stub. It does not establish real-browser rendering,
throughput or a native gameplay result. The separate `test.mjs` and
`browser-smoke.mjs` retain older synchronous API assumptions and were not run.

`check.sh` still runs the maintained browser build only. To exercise the host
harness, emit both `game.bend` and `fixtures.bend` to the corresponding files in
`dist/`, then run `node examples/arena/host-smoke.mjs` from the repository root.

Earlier execution observations remain historical evidence at commit
`431266bac`; they are not results from this sequential application.
