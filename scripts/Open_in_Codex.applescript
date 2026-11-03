try
	tell application "Finder"
		-- Finder window = brow; its target folder = fvtg (Finder.sdef).
		-- Explicit codes keep builds independent of scripting-dictionary lookup.
		if (count of «class brow») is 0 then
			set targetFolder to path to desktop folder
		else
			set targetFolder to «property fvtg» of front «class brow» as alias
		end if
	end tell
	do shell script "/usr/bin/open -b com.openai.codex " & quoted form of POSIX path of targetFolder
on error errorMessage number errorNumber
	display dialog "Could not open the Finder folder in Codex: " & errorMessage with title "Open in Codex" buttons {"OK"} default button "OK" with icon stop
end try
