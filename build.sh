#!/bin/bash
# Adapted from Doloreng/Go2Shell develop, commit dae08b58adbcdd07338ac980723a9bbd33c04467.
# Rebuild using this Mac's AppleScript runtime, including its native arm64 launcher.
set -euo pipefail
cd "$(dirname "$0")"

names=(Go2Shell_iTerm Go2Shell_iTerm_newWin Go2Shell_Term Go2Shell_Term_newWin Go2Shell_Warp)
work="$(mktemp -d "${TMPDIR:-/tmp}/go2shell-build.XXXXXX")"
trap 'rm -rf "$work"' EXIT

# Compile and verify every variant before replacing any existing application.
for name in "${names[@]}"; do
	app="${name}.app"
	built="${work}/${app}"
	osacompile -o "$built" "scripts/${name}.applescript"

	if [[ -f "${app}/Contents/Resources/applet.icns" ]]; then
		cp "${app}/Contents/Resources/applet.icns" "${built}/Contents/Resources/applet.icns"
	fi
	rm -f "${built}/Contents/Resources/Assets.car"

	plist="${built}/Contents/Info.plist"
	/usr/bin/plutil -replace CFBundleName -string go2shell "$plist"
	/usr/bin/plutil -replace CFBundleIdentifier -string com.apple.ScriptEditor.id.go2shell "$plist"
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
