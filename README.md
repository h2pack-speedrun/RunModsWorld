# TODO_ModName

> TODO: Short description of what this mod does.

## Features

- TODO: List features

## Installation

Install via [r2modman](https://thunderstore.io/c/hades-ii/) or manually place in your `ReturnOfModding/plugins` folder.

## Configuration

This mod can be configured in-game. 
- **With H2 Modpack Core**: Press the designated hotkey (default: `F10`) to open the unified Modpack UI and toggle this mod or adjust its settings.
- **Standalone**: If you do not have the Core installed, this mod will provide its own standalone configuration menu in-game.

## Development

This module is part of the [H2 Modular Modpack](https://github.com/h2-modpack/h2-modular-modpack). Please read the main project documentation for information on architecture and conventions.

- **[Architecture](https://github.com/h2-modpack/h2-modular-modpack/blob/main/ARCHITECTURE.md)**: Framework, Lib, staging pattern, hash pipeline, module contract.
- **[Framework CONTRIBUTING.md](https://github.com/h2-modpack/adamant-ModpackFramework/blob/main/CONTRIBUTING.md)**: Discovery system, UI rendering, theme contract.
- **[Lib CONTRIBUTING.md](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/CONTRIBUTING.md)**: Public API reference and shared utilities.

### Local Setup

1. Clone this repo
2. Run `Setup/init_repo.bat` (Windows) or `Setup/init_repo.sh` (Linux) to configure git hooks and branch protection
3. Run `Setup/deploy_local.bat` (Windows, as admin) or `Setup/deploy_local.sh` (Linux) to copy assets, generate manifest, and symlink into your r2modman profile

## How this fits into the modpack

This mod is designed to work standalone **or** as part of the [H2 Modpack](https://github.com/h2-modpack/h2-modular-modpack), which provides a unified UI, config hashing, and profile management across all modules via the Framework.

> **Discovery is automatic** — no registration needed. Set `modpack = PACK_ID` in `public.definition` and the Framework will discover this mod at runtime. Add this repo as a submodule under `Submodules/` in the shell repo and run `python Setup/deploy_all.py`.

## Special modules — how staging works

> This section only applies if you're building a **special module** (`src/main_special.lua`). Simple modules can ignore this.

Special modules have custom state beyond a simple on/off toggle — things like weapon selections, aspect choices, or multi-field configurations. This creates a challenge: ImGui renders every frame and reads values constantly, but writing to Chalk (the config persistence layer) on every frame is expensive.

The solution is a **staging table** — a plain Lua table that mirrors your config and is fast to read/write during UI interaction. Chalk is only written when the user confirms a change.

The lifecycle works like this:

- **`SnapshotStaging()`** — copies the current config values into the staging table. Call this to re-sync staging after config changes happen outside the UI (e.g. after `ApplyConfigHash` loads a profile).
- **`SyncToConfig()`** — flushes the staging table back to Chalk. Framework calls this when the user interacts with your UI. You can also pass it as the `onChanged` callback directly.
- **`stateSchema`** — a list of field descriptors that tells Framework the shape of your state. Framework uses this to include your module's values in the config hash and profiles. You don't encode or decode anything yourself — just declare the fields and Framework handles it.

In practice: read from `staging` in your UI, call `onChanged` (which is `SyncToConfig`) after any interaction, and declare your fields in `stateSchema`. The template's `FILL` markers show exactly where each piece goes.
