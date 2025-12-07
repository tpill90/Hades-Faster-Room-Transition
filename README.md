<!-- TODO post that I have a fixed version of this on thunderstore https://www.nexusmods.com/hades2/mods/58 -->
<!-- TODO should probably create a video to demonstrate this -->
# Hades Faster Room Transition

Dramatically speeds up room transitions.  No longer do you need to wait for the long animations to play out each time,  you can start the next room almost immediately!

# Mod Installation

Download and install the latest version of [r2modman](https://github.com/ebkr/r2modmanPlus/releases) for your platform.  You can then easily install this mod from [Thunderstore - Faster Room Transitions](https://thunderstore.io/c/hades-ii/p/tpill90/FasterRoomTransitions).

# Need Help?
If you are running into any issues, feel free to open up a Github issue on this repository.

You can also find me in the [**Hades Modding** Discord](https://discord.com/invite/KuMbyrN).

# Development
<!-- TODO Document how debug.lua works.  Finish writing this section up -->

## Setup

* Install R2ModMan and install required mod dependencies
* Create symlink with _SetupDevEnvironment.ps1
* https://thunderstore.io/c/hades-ii/p/PonyWarrior/PonyMenu/

## Workflow

* Changes will be automatically picked up whenever any file is changed.
* You may need to sometimes restart the game in some scenarios.
* Watch logs with `_TailLogs.ps1`
* `I` will open up the inventory, and going over to the last tab will let you add remove boons for testing.
* `CTRL + C` will set a room that you can teleport to for testing.  See debug.lua
* `CTRL + F` will kill all enemies on screen.

# Publishing A Release

- From your GitHub repository, go to **Actions** and select the **Release** workflow on the left.
- Select the **Run workflow** dropdown on the right.
- Input the version to release, e.g. `1.2.0`.
- Click the **Run workflow** button.


## Resources

- https://github.com/SGG-Modding/ModUtil/wiki
- https://github.com/SGG-Modding/Hell2Modding/tree/master/docs/lua
- https://github.com/SGG-Modding/sgg-mod-format/wiki