# Go2Shell By AppleScript

## Introduce

Open an iTerm2, Terminal or Warp window at the current Finder folder by clicking the Finder toolbar icon.

## macOS 27 build

Version **1.1** was rebuilt on **macOS 27.0.1 (26A434), Apple silicon**. All five applets now contain native **arm64** and **x86_64** launchers and are ad-hoc signed. The Apple silicon launcher does not require Rosetta.

Verified on this Mac on 2026-10-28:

| App | Verification |
| --- | --- |
| `Go2Shell_Term.app` | Launched from a Finder folder; terminal shell working directory matched |
| `Go2Shell_Term_newWin.app` | New Terminal instance launched; shell working directory matched |
| `Go2Shell_Warp.app` | Warp launched; shell working directory matched |
| `Go2Shell_iTerm.app` | Built and signature verified; iTerm2 was not installed for a launch test |
| `Go2Shell_iTerm_newWin.app` | Built and signature verified; iTerm2 was not installed for a launch test |

The launch tests used folder names containing Chinese characters, spaces, single quotes, `$` and `;`. All original icons, terminal choices and `-n` new-instance options were preserved.

These checks cover an ordinary Finder folder window. They do not establish support for every Finder view or older macOS versions. The launchers come from the build machine's AppleScript runtime; rebuild on another macOS version before testing there.

![](./img/1.png)

## How to use

- Copy the corresponding app to the Application directory。
- Hold down the Command key and drag it to the toolbar.
- Click the icon, a iTerm2 window pop up with current directory.

If an older copy is already installed, replace it in `/Applications` with the newly built app. The local build does not automatically replace installed copies.

## Rebuild

The readable sources are in `scripts/`. On macOS with the command-line developer tools installed, run:

```bash
./build.sh
```

The build compiles and verifies all five variants before replacing the repository's app bundles. It preserves their icons and bundle identifier, sets version 1.1, verifies the host's native architecture, and signs and checks each app. Rebuild after changing a source script so its signature remains valid.

## Thanks

The main implementation comes from [wonderyue/Go2ShellAppleScript](https://github.com/wonderyue/Go2ShellAppleScript), I just changed the icon and added a new window to open iTerm2 like Go2Shell。

The macOS 27 rebuild approach and the four Terminal/iTerm AppleScript sources are adapted from [Doloreng/Go2Shell, develop branch, commit dae08b5](https://github.com/Doloreng/Go2Shell/commit/dae08b58adbcdd07338ac980723a9bbd33c04467). This repository also rebuilds its existing Warp variant.
