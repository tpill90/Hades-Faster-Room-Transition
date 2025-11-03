<!-- TODO add plateup icon to my profile readme.  Add hades link + icon to profile -->
<!-- TODO post that I have a fixed version of this on thunderstore https://www.nexusmods.com/hades2/mods/58 -->
# Hades Faster Room Transition

Dramatically speeds up room transitions.  No longer do you need to wait for the long animations to play out each time,  you can start the next room almost immediately!

# Mod Installation
<!-- TODO -->

# Need Help?
If you are running into any issues, feel free to open up a Github issue on this repository.

You can also find me in the [**Hades Modding** Discord](https://discord.com/invite/KuMbyrN).

# Development
<!-- TODO -->

## Setup

* Install Thunderstore cli https://github.com/thunderstore-io/thunderstore-cli from the releases tab https://github.com/thunderstore-io/thunderstore-cli/releases
* `tcli build` in the project root will create a zip file under `/build`

* Create symlink with _SetupDevEnvironment.ps1
* src folder must have a manifest.json with correct dependencies defined.
<!-- TODO need to create + copy the manifest.json over wwithout committing it -->

* VSCode install lua extension by sumneko
* Go on the Workspace tab, and in the search bar at the top type library (add a space before). Scroll down until you find Lua > Workspace Library. There you need to add two items : Content/Scripts/ and Mods/.
* Then search for preload and change Lua > Workspace: Preload File Size from 500 to 3000

`F1` to open up modding UI

## Workflow

* Changes will be automatically picked up whenever any file is changed.
* You may need to sometimes restart the game in some scenarios.
* Watch logs with `_TailLogs.ps1`

## Publishing A Release

- From your GitHub repository, go to **Actions** and select the **Release** workflow on the left.
- Select the **Run workflow** dropdown on the right.
  - By default, your repository's default branch (`main` by default) is selected (this is why we recommended for planning on making releases from it). If you want to release from another branch, select it.
- Input the version to release, e.g. `1.2.0`.
  - For good practices on versioning, please see [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
- Click the **Run workflow** button.
- A new workflow run will be triggered, and will take care of:
  - Rotating version in `CHANGELOG.md` and `thunderstore.toml`.
  - Building the Thunderstore mod package.
  - Uploading the package to the workflow run as an artifact.
  - Pushing the changes and tagging the git repository.
  - Publishing the package on Thunderstore.
  - Making a new GitHub release.
  - Uploading the package to the GitHub release as an asset.
- After a new release has been published, it's a good idea to `git pull` the changes so as to ensure your local `CHANGELOG.md` and `thunderstore.toml` are up to date.

### Dry-run

- When ticking the dry-run checkbox, the workflow will only run the first steps:
  - Rotating version in `CHANGELOG.md` and `thunderstore.toml`.
  - Building the Thunderstore mod package.
  - Uploading the package to the workflow run as an artifact.
- No changes are made to the repository, and no releasing / publishing happens.
- This can be used to check if the Thunderstore package builds correctly and inspect its contents without publishing (e.g. if you are making changes to `thunderstore.toml`), by downloading the workflow run artifact.


