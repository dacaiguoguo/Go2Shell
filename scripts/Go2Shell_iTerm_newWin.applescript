tell application "Finder"
	set pathList to (quoted form of POSIX path of (folder of the front window as alias))
end tell

tell application "System Events"
	do shell script "open -a iTerm -n " & pathList
end tell
