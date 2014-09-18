set numServes to do shell script "ps ax | grep SimpleHTTPServer | grep -v grep | wc -l | tr -d ' '"
if numServes > 0 then
	set servers to do shell script "ps ax | grep SimpleHTTPServer | awk /python/'{print $1, $8}'"
	set AppleScript's text item delimiters to "
"
	set procList to {}
	set serverList to text items of servers
	repeat with proc in serverList
		set AppleScript's text item delimiters to " "
		set procInfo to text items of proc
		set procNum to ""
		try
			set procNum to item 2 of procInfo as integer
			copy (item 2 of procInfo & " - " & item 1 of procInfo) as string to end of procList
		end try
	end repeat
	
	set selectedProc to (choose from list procList with title "Running DropServers" with prompt "Choose DropServer to kill" OK button name "Kill")
	set AppleScript's text item delimiters to " - "
	if selectedProc is not false then
		set proc to item 2 of text items of (item 1 of selectedProc)
		do shell script "kill " & proc
		set procsLeft to (do shell script "ps ax | grep " & proc & " | grep -v grep | wc -l | tr -d ' '") as integer
		delay 1
		if procsLeft is numServes then
			set myAnswer to display dialog "There may have been a problem killing the server" buttons {"Ignore", "Terminal"} default button "Terminal" with icon 1
			if button returned of myAnswer is "Terminal" then
				tell application "Terminal"
					activate
					do script "ps ax | grep SimpleHTTPServer"
				end tell
			end if
		end if
		
	end if
else
	display dialog "Drop a file or folder on me on to start serving.
Run me as an app to kill servers." buttons {"OK"} default button 1
end if

on open names
	set iPath to item 1 of names
	set basePort to 8000
	if folder of (info for iPath) then
		set iPath to POSIX path of iPath as text
	else
		set iPath to POSIX path of iPath as text
		set AppleScript's text item delimiters to "/"
		set parentPath to (items 1 thru -2 of text items of iPath) as string
		set AppleScript's text item delimiters to ""
		set iPath to parentPath & "/"
	end if
	set myIP to do shell script "curl --silent http://automation.whatismyip.com/n09230945.asp"
	--set myIP to "localhost"
	set numServes to do shell script "ps ax | grep SimpleHTTPServer | grep -v grep | wc -l | tr -d ' '"
	set myPort to basePort + numServes
	
	-- noisy mode
	--tell application "Terminal"
	--	activate
	--	do script "cd " & iPath & "; python -m SimpleHTTPServer " & myPort
	--end tell
	
	-- quiet mode
	set iPath to quoted form of iPath
	do shell script "cd " & iPath & "; python -m SimpleHTTPServer " & myPort & " > /dev/null 2>&1 &"
	delay 2
	open location "http://" & myIP & ":" & myPort
	return
end open