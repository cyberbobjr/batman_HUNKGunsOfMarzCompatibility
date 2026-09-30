# H.U.N.K Profession - Guns of Marz Compatibility

Compatibility patch for Project Zomboid Build 42.21: the HUNK starting kit from [H.U.N.K Profession](https://steamcommunity.com/sharedfiles/filedetails/?id=3678932953) by Too Much Jello works with [Guns of Marz](https://steamcommunity.com/sharedfiles/filedetails/?id=3722134990) by Marz.

- Steam Workshop: [3810695874](https://steamcommunity.com/sharedfiles/filedetails/?id=3810695874)
- Mod id: `batman_HUNKGunsOfMarzCompatibility` (requires `HUNKPro` and `GunsOfMarz`, loads after both)

## What it does

When the Guns of Marz sandbox option **Vanilla Weapon Replacement** is on, Guns of Marz swaps vanilla guns, magazines, ammo and attachments for random Guns of Marz models one tick after they reach a container. The HUNK kit lost its sights, lasers and loaded magazines. This patch builds the kit directly with Guns of Marz items (M16A2, Beretta M92FS or Colt Python, loaded magazines, matching ammo boxes, sights and lasers). When the replacement is off, the original kit is given unchanged.

## Files

- `Contents/mods/batman_HUNKGunsOfMarzCompatibility/42.21/media/lua/shared/HUNKPro_Profession_items.lua` replaces the file of the same path in H.U.N.K Profession. It must be updated whenever that file changes upstream.
- `docs/make_poster.py` builds `preview.png` and `poster.png` from the posters of both mods (read from a local Steam Workshop folder).
- `README.steam`, `README.steam.fr`: Workshop descriptions; `CHANGELOG.md`: release notes.

## Credits and rights

H.U.N.K Profession by Too Much Jello, Guns of Marz by Marz: all the content, the original starting kit and the source of `HUNKPro_Profession_items.lua` are theirs, as are the posters used for this mod's image. This repository has no license of its own and grants no rights over their work; it is published for transparency, alongside the Workshop item.
