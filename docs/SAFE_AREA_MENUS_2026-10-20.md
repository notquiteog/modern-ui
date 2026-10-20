# Menu safe areas and small text — 2026-10-20

The optional full-window GB party, summary and storage screens and GBA summary
screen now size and center their content inside the public engine SafeArea
viewport. The backdrop still covers the window. If the usable area cannot fit
one complete layout, the original native screen remains visible. Native input,
party/box transactions, animation clocks, egg privacy and OFF remain unchanged.

Capture review also exposed existing small-screen readability defects. At less
than one screen pixel per source font pixel, nearest sampling discarded entire
PlainPixel glyph strokes. Linear sampling now preserves their coverage in that
case; integer enlargement retains the original nearest-filtered face. Font
assets, Unicode coverage and text fitting are unchanged. The custom party's own
prompt/action text now uses a dark custom panel, and selected storage rows use
dark ink on their pale selection background. Native text delegates retain their
white-paper contract.

## Evidence

Latest official v0.3.91 was checked before the batch. The unmodified official
engine ran through the established LÖVE11.5 NVIDIA desktop shell, with isolated
seven-mod QA profiles. Old driver helpers are QA support only. No normal player
save or engine source was changed.

All eleven editions pass actual window-overlay panel-bound assertions at
640×360 with public safe rect(30,12,580,320), and360×640 with rect(14,36,332,576).
GB/GBC checked party, summary and storage; all five GBA editions checked summary.
All46 initial captures were inspected. These established inset routing and
exposed the font/contrast defects above, so they are not readability approval.

After those corrections, Yellow/Crystal menus and Emerald summary plus paired
battle pass both sizes; all16 final captures were inspected. Full-size party,
storage and summary samples show complete glyph strokes and contrasting labels.
An isolated raster comparison confirms the downsampling cause. All15 source
suites pass, including usable-area thresholds, exact scale/origin, selected ink,
original fallback, controller state and font-filter transitions.

Scratch: `voxel-parity-20261020/safe-menu-0391` (initial all11),
`safe-menu-final-0391` (final16), `font-probe` (isolated comparison), and driver
`native-menu-safe.lua`. The shared voxel350/0/58 suite predates this menu-only
batch; it is not presented as a second run after these changes.

## Limits

Desktop insets and rendering do not certify physical Android/iOS readability,
touch, memory or safe-area backend behavior. Very small rectangles deliberately
retain native UI. Existing native portrait palettes and specialized native menu
layouts remain engine-owned; this is not a complete Modern UI redesign of every
screen. Other optional packages remain independent.
