# Modern Pokemon UI — preview

Optional battle presentation for Gen1Recomp 0.3.51 and later, across Gen 1, 2
and 3. No other mod is required. Install this folder as `mods/MODERN_POKEMON_UI`.
Use **MODERN UI → MODERN BATTLE UI** in the generation's own settings menu.
Turning it off delegates to the native battle UI without altering saved battles.

Standalone, the preview frames Gen1/2 native status HUDs and applies a silver
Gen3 healthbox palette while retaining engine text,
HP animations, status conditions, input and commands. With Battle Art's optional
public stage adapter, it enables overhead status cards and modern commands.
Doubles can also opt into its own compatible renderer. Battle Art and doubles
continue working without this mod. No gameplay, encounter, party or network
rules are changed.

This is an early preview, not a complete game-wide UI replacement. Party, bag,
Pokedex and overworld menus remain native. Gen 1 wide-layout framing and all
battle transition/animation combinations still require visual QA. Standalone
modern commands are not implemented yet.

## Optional public interface

`mod.find('MODERN_POKEMON_UI').exports` advertises `apiVersion = 1`, `enabled()`
and `battleTheme`. Consumers must check availability/version and fall back to
the engine when absent, disabled or incompatible. No consumer should require
this mod to run its own gameplay or world renderer.

`luajit tests/native_frames_test.lua` checks native fallbacks, frame adapters in
all three generations, stage ownership and safe uninstallation. Rendered QA is
recorded separately from these mocked adapter tests.

Rendered QA: Emerald, official engine 0.3.51, standalone and with all partners.
The native settings row toggles OFF/ON successfully; captures inspected.
Gen1/2 standalone adapters currently have mocked tests only.
