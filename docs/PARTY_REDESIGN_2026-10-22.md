# Party inventory redesign

Reference: user-provided mNJSjOj.png. Cyan chamfered card outlines, teal/white
selection, separate dark HP number wells, visible gender/status, retained native
Pokemon icon art. Shared party cards and navy/cyan panels apply across generations.

The five Gen 3 editions now use a screen-resolution two-column inventory for
normal list, reorder and action menus. Native action labels, callbacks, party
records and summary remain authoritative. Direction navigation follows the new
card positions; empty slots are skipped and Cancel remains reachable. Input
continues through the native controller, including virtual mobile buttons.
Gen 1/2 retain their existing single-column responsive roster/controller.

Special item/healing, battle switching, multi-selection, scripted demonstration,
and summary modes retain existing renderers. This is intentional preservation of
native workflow, not a claim that every screen has a new bespoke layout. Dedicated
bag, shop, Pokedex and trainer-card redesigns remain outstanding.

Verification: official engine 0.3.95 on native Linux LÖVE shell 0.3.89. Isolated
profiles passed party ON/OFF, right selection, action menu, summary, return and
cancel in FireRed, LeafGreen, Ruby, Sapphire and Emerald. 360x640 portrait captures
were generated alongside landscape. Physical Android/iOS remains unverified.
QA evidence lives outside source at .scratch/modern-party-20261022/<edition>.
