# Modern Pokemon UI — preview

Optional battle presentation for Gen1Recomp 0.3.51 and later, across Gen 1, 2
and 3. No other mod is required. Install this folder as `mods/MODERN_POKEMON_UI`.
Use **MODERN UI → MODERN BATTLE UI** in the generation's own settings menu.
Turning it off delegates to the native battle UI without altering saved battles.

Standalone, the mod adds palette-safe black/white Gen1/2 status frames and applies a silver
Gen3 healthbox palette while retaining engine text,
HP animations, status conditions, input and commands. With Battle Art's optional
public stage adapter, it enables overhead status cards and modern commands.
Doubles can also opt into its own compatible renderer. Battle Art and doubles
continue working without this mod. No gameplay, encounter, party or network
rules are changed.

This is an early preview, not a complete game-wide UI replacement. Party, bag,
Pokedex and overworld menus remain native. Gen 1 WIDE keeps its original status HUDs. The full
battle transition/animation matrix remains unverified. Standalone
modern commands are not implemented yet.

## Optional public interface

`mod.find('MODERN_POKEMON_UI').exports` advertises `apiVersion = 1`, `enabled()`
and `battleTheme`. Consumers must check availability/version and fall back to
the engine when absent, disabled or incompatible. No consumer should require
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
