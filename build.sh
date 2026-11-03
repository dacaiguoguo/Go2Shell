#!/bin/bash
# Adapted from Doloreng/Go2Shell develop, commit dae08b58adbcdd07338ac980723a9bbd33c04467.
# Rebuild using this Mac's AppleScript runtime, including its native arm64 launcher.
set -euo pipefail
cd "$(dirname "$0")"

all_names=(Go2Shell_iTerm Go2Shell_iTerm_newWin Go2Shell_Term Go2Shell_Term_newWin Go2Shell_Warp "Open in Codex")
names=()
if (( $# == 0 )); then
	names=("${all_names[@]}")
else
	for target in "$@"; do
		valid=false
		for name in "${all_names[@]}"; do
			if [[ "$target" == "$name" ]]; then valid=true; break; fi
		done
		if [[ "$valid" != true ]]; then
			echo "Unknown build target: $target" >&2
			exit 1
		fi
		names+=("$target")
	done
fi
work="$(mktemp -d "${TMPDIR:-/tmp}/go2shell-build.XXXXXX")"
trap 'rm -rf "$work"' EXIT

# Compile and verify every variant before replacing any existing application.
for name in "${names[@]}"; do
	app="${name}.app"
	built="${work}/${app}"
	if [[ "$name" == "Open in Codex" ]]; then
		source="scripts/Open_in_Codex.applescript"
	else
		source="scripts/${name}.applescript"
	fi
	osacompile -o "$built" "$source"

	if [[ "$name" == "Open in Codex" ]]; then
		cp assets/Open_in_Codex.icns "${built}/Contents/Resources/applet.icns"
	elif [[ -f "${app}/Contents/Resources/applet.icns" ]]; then
		cp "${app}/Contents/Resources/applet.icns" "${built}/Contents/Resources/applet.icns"
	fi
	rm -f "${built}/Contents/Resources/Assets.car"

	plist="${built}/Contents/Info.plist"
	if [[ "$name" == "Open in Codex" ]]; then
		/usr/bin/plutil -replace CFBundleName -string "Open in Codex" "$plist"
		/usr/bin/plutil -insert CFBundleDisplayName -string "Open in Codex" "$plist"
		/usr/bin/plutil -replace CFBundleIdentifier -string io.github.go2shell.open-in-codex "$plist"
		/usr/bin/plutil -replace NSAppleEventsUsageDescription -string "Open in Codex reads the current Finder folder to open it in Codex." "$plist"
	else
		/usr/bin/plutil -replace CFBundleName -string go2shell "$plist"
		/usr/bin/plutil -replace CFBundleIdentifier -string com.apple.ScriptEditor.id.go2shell "$plist"
	fi
	/usr/bin/plutil -replace CFBundleShortVersionString -string 1.1 "$plist"
	/usr/bin/plutil -replace CFBundleVersion -string 2 "$plist"
	/usr/libexec/PlistBuddy -c 'Delete :CFBundleIconName' "$plist"
	/usr/bin/xattr -cr "$built"
	/usr/bin/lipo -verify_arch "$(uname -m)" "${built}/Contents/MacOS/applet"
	/usr/bin/codesign --force --deep --sign - "$built"
	/usr/bin/codesign --verify --deep --strict "$built"
done

for name in "${names[@]}"; do
	app="${name}.app"
	rm -rf "$app"
	/usr/bin/ditto --norsrc "${work}/${app}" "$app"
	/usr/bin/codesign --verify --deep --strict "$app"
	echo "built ${app}"
done
