# Modern Pokemon UI

Optional battle presentation for Gen1Recomp 0.3.51 and later, across Gen 1, 2
and 3. No other mod is required. Install this folder as `mods/MODERN_POKEMON_UI`.
Use **MODERN UI → MODERN BATTLE UI** in the generation's own settings menu.
Turning it off delegates to the native battle UI without altering saved battles.

Standalone, the mod adds palette-safe black/white Gen1/2 status frames and applies a silver
Gen3 healthbox palette while retaining engine text,
HP animations, status conditions, input and commands. Commands and move lists render at window resolution with native navigation, move PP/type details, and safe native fallbacks for special prompts. With Battle Art's optional
public stage adapter, it enables overhead status cards and modern commands.
Doubles can also opt into its own compatible renderer. Battle Art and doubles
continue working without this mod. No gameplay, encounter, party or network
rules are changed.

This is a battle presentation mod; it is not a game-wide UI replacement. Party, bag,
Pokedex and overworld menus remain native. Gen 1 WIDE keeps its original status HUDs. The full online battle transition/animation matrix remains unverified. Standalone commands and move lists are supported. Native move-reordering prompts remain native.

## Optional public interface

`mod.find('MODERN_POKEMON_UI').exports` advertises `apiVersion = 1`, `enabled()`
and `battleTheme`. Consumers must check availability/version and fall back to
the engine when absent, disabled or incompatible. `battleTheme.statusCard` accepts
an optional final `{paper={r,g,b,a}}` style for per-card palettes without changing
the shared theme. No consumer should require
this mod to run its own gameplay or world renderer.

`luajit tests/native_frames_test.lua` checks native fallbacks, frame adapters in
all three generations, stage ownership and safe uninstallation. Rendered QA is
recorded separately from these mocked adapter tests.

Rendered QA (official engine 0.3.51): Yellow, Crystal, LeafGreen and Emerald,
standalone and with Battle Art and the partner mods. Native settings toggles
OFF/ON reach the actual renderer. Captures were inspected. This covers wild
single battles at command selection, not every attack or online/double battle.

## Release 0.1.0

First public battle-presentation release. Fixes GB palette remapping, keeps the
player frame within the native HUD bounds, follows Gen1 HUD shake and safely
disarms retained wrappers on unload. Battle Art 1.31.1 consumes this mod's theme
through the optional public API; neither package requires the other.

## 0.2.0 verification

Actual v0.3.51 runtime: Yellow, Crystal, Emerald standalone Fight → moves →
cancel → attack → command return, plus OFF/ON; LeafGreen standalone OFF/ON.
Emerald staged trainer doubles rendered all four actors/cards; staged singles
and Crystal integration were also inspected. Shared text fits whole numeric
labels and nicknames instead of truncating levels/HP. Icons and selection outlines
keep command choices readable without relying on colour alone.

Unit checks: `luajit tests/native_commands_test.lua`,
`luajit tests/native_frames_test.lua`, `luajit tests/theme_test.lua`.
Runtime evidence: `/home/admin/Projects/.scratch/modern-finish-20261005/results/`.
This does not certify every online or special battle sequence.

Post-release transition QA uses `tools/qa/battle-transitions.lua` with isolated
profiles. Emerald standalone/staged and LeafGreen standalone trainer doubles
pass native Party/Bag navigation and cancellation, target changes and cancellation,
second-battler selection, a complete turn and return. Crystal companion doubles
also passed target cancellation without PP loss and damage to either chosen foe
at 2560×1440. Online transport testing remains separate from this UI evidence.

Gen1 WIDE command/move presentation is supported (`QA_WIDE=1` with
`tools/qa/gb-battle.lua`); it retains native wide healthboxes and grid navigation.
The existing local ENet Gen1 doubles fixture also passed 12 complete turns with
Modern UI loaded, state hashes and save-party integrity intact. That fixture
starts at command selection, so it does not certify the lobby/intro path.

## Latest runtime recheck

Official 0.3.52: Emerald native trainer doubles, standalone and staged, passed
party/bag cancellation, target selection/cancellation, partner commands and a
complete turn/return. Yellow WIDE and Crystal standalone passed ON/OFF, move
selection/cancel and attack/return. Updated rendered captures were inspected.
The doubles driver excludes connected physical controllers so automated input
and camera checks remain deterministic. These checks do not certify every
special battle or online lobby transition.

`tools/qa/battle-endings.lua` additionally exercises real Gen3 knockout and run
transitions. Emerald staged 0.3.52 retains scenery through the closing fade,
removes command controls during messages, and returns to the overworld cleanly.

## Two-client room verification (0.3.52)

`tools/qa/room-battle-gb.lua` and `room-battle-gen3.lua` exercise separate
host/guest processes, actual room presence/chat, invitation acceptance through
the room UI, native handshake/intro, commands, targeting, damage/faints,
forced reserves, outcomes and connected overworld return. No intro bypass.

| Game | Singles | Doubles |
| --- | --- | --- |
| Yellow | Passed | Passed |
| Crystal | Passed | Passed |
| Emerald | Passed | Passed |
| LeafGreen | Passed | Passed |

All runs used private QA saves and local ENet transport; captures were inspected.
This supersedes the older command-phase-only online fixture limitation for the
listed paths. Internet latency/disconnects, all special moves and every regional variant
remain separate coverage. Standalone Gen1 doubles retains the companion's
native target menu and reduced partner sprites; projected artwork requires the
optional scene renderer.

The real Crystal tests exposed duplicate empty backplates and partially dimmed
cards. Modern UI now respects companion ownership; the companion takes the
optional Modern theme directly and composites after native letterboxing with
space for both ally cards and commands. Staged targeting/cancel/damage was
rechecked at 2560×1440 after that change.

## Special native-screen checks (0.3.52)

Emerald room singles additionally passed the native online item restriction and
voluntary reserve switch, followed by completed battle and connected return
(`QA_OPTIONS=1` with `room-battle-gen3.lua`). Other generations have verified
forced reserves; voluntary switch/item rules remain separate coverage.

LeafGreen Teachy TV battle, type-matchup and catching lessons passed their native
assertions, including scripted switches, ball selection, player party/bag
restoration and return to the lesson list. Modern commands now leave scripted
POKé DUDE/tutorial screens native. Yellow's old-man bag and Mimic move-copy
chooser were visually checked. A separate trainer SHIFT probe with companion
trainer doubles disabled passed the native YES/NO and replacement-party screens;
no modern controls covered either menu.

Emerald staged capture → caught Dex → nickname entry → overworld passed with
clean native naming and no retained battle UI. `tools/qa/capture-naming.lua` uses
the real BattleBridge entry, which owns field/fade restoration; calling the
low-level Battle.start alone does not model an overworld encounter's return.
These checks cover the listed paths, not every tutorial cancellation or evolution.

LeafGreen native Safari passed bait, rock, ball consumption and exit. The render
check found a companion HUD replacing the Safari counter with a fake Pokémon
card; its special-battle fallback was corrected and the rerun shows the native
SAFARI BALLS counter. Native stone evolution also passed bag/party navigation,
unsupported-target messaging, Nidorina/Pikachu evolution and inventory updates,
then restored the party list. Scene/menu captures were inspected.

Crystal's native Cyndaquil → Quilava evolution also passed the engine timing,
cry/music ordering, animated-picture and party-update assertions. Evolution
frames were inspected with no battle cards or command UI leaking into the scene.
