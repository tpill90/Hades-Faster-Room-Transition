# Hades II mod template

This mod template can be used as basis for creating your own Hades II mods and publishing them on [Thunderstore](https://thunderstore.io/).

## Setup

- Create a new GitHub repository to host your mod.
- Download [**hades2-mod-template.zip**](https://github.com/SGG-Modding/Hades2ModTemplate/releases/latest/download/hades2-mod-template.zip) and extract it.
- Edit the following files:
  - `README.md`: everything about your mod (name, features, config options, etc.). It will be displayed on your Thunderstore mod page, so make sure it's easy to follow and properly structured.
  - `LICENSE`: replace `[year]` and `[fullname]`.
    - The [MIT license](https://choosealicense.com/licenses/mit/) is shipped by default, and is the one we recommend to use in the Hades modding community. If you want to use another license, make sure to change it now.
  - `icon.png`: your Thunderstore mod icon.
  - `thunderstore.toml`: your Thunderstore mod package definition (it will be used to generate your package's `manifest.json`). Edit the following entries as needed:
    - `namespace`: your Thunderstore team / namespace, a.k.a. author name.
    - `name`: your mod name. No spaces (allowed characters: `a-z A-Z 0-9 _`). Underscores get replaced with a space for display purposes on the website and mod manager. **Important:** this can not be changed later, aside from creating a new package.
    - `description`: short description of your mod (max 250 characters). It will be used by the Thunderstore search, so make sure to include words that people are likely to search for when looking for your mod.
    - `websiteUrl`: your GitHub repository (or website, or Discord server, if you prefer).
    - `[package.dependencies]`: your mod dependencies. Use the `AuthorName-ModName = "X.Y.Z"` format, with `X.Y.Z` being the version you depend on.
    - `[publish.categories]`: the categories you want your mod to appear under. [See the API](https://thunderstore.io/api/experimental/community/hades-ii/category/) for list of available categories.
- Push everything to your GitHub repository.
- From Thunderstore:
  - Go to [**Teams settings**](https://thunderstore.io/settings/teams/) and select your team.
  - Create a new **Service Account** for your mod (we recommend using the same name as the mod name).
  - You will get an **API token** associated to the new **Service Account**.
- From your GitHub repository:
  - Go to **Settings** > **Secrets and variables** > **Actions**.
  - Create a **new repository secret** named `TCLI_AUTH_TOKEN` and copy/paste the **API token** as its value.

That's it, you are now ready to [**develop**](#develop).

## Develop

<!-- TODO mess with thunderstore cli.  Look at how the publish works and do it locally -->
<!-- TODO mess with loading a mod manually in r2modman -->
* Create symlink with _CreateSymlink.ps1
* src folder must have a manifest.json with correct dependencies defined.
* Watch logs with `_TailLogs.ps1`

* VSCode install lua extension by sumneko
* Go on the Workspace tab, and in the search bar at the top type library (add a space before). Scroll down until you find Lua > Workspace Library. There you need to add two items : Content/Scripts/ and Mods/.
* Then search for preload and change Lua > Workspace: Preload File Size from 500 to 3000.hen search for preload and change Lua > Workspace: Preload File Size from 500 to 3000.

* Add to your run parameters in Steam.  Will let you see debug output from the game files  `/DebugDraw=true /DebugKeysEnabled=true /EnabledDebugDisplays=Default,Console,MissingTextures,TextSystem`

Cycle through debug views with Ctrl+D, can use `DebugPrint()` in the game scripts to see whats going on.


## Release

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
