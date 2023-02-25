-- SPDX-FileCopyrightText: © 2021 ratojakuf <https://stackoverflow.com/users/4008381/ratojakuf>
--
-- SPDX-License-Identifier: CC-BY-SA-4.0

property targetVolume : "BOOTCAMP" # find name of required volume inside System Preference > Startup Disk
property passwordValue : "yourSystemPassword" # Can be empty

tell application "System Events"
	tell application "System Preferences"
		set current pane to pane id "com.apple.preference.startupdisk"
		activate
	end tell
	tell application process "System Preferences"
		tell window "Startup Disk"
			set volumePosition to {0, 0}
			set lockFound to false
			
			# Check if auth required
			set authButtonText to "Click the lock to make changes."
			if exists button authButtonText then
				click button authButtonText
				
				# Wait for auth modal
				set unlockButtonText to "Unlock"
				repeat
					if (exists sheet 1) and (exists button unlockButtonText of sheet 1) then exit repeat
				end repeat
				
				# Autofill password if setted
				if passwordValue is not equal to "" then
					set value of text field 1 of sheet 1 to passwordValue
					click button unlockButtonText of sheet 1
				end if
				
				# Wait for auth success
				repeat
					if exists button "Click the lock to prevent further changes." then exit repeat
				end repeat
			end if
			
			# Wait until loading volumes list
			repeat
				if exists group 1 of list 1 of scroll area 1 then exit repeat
			end repeat
			
			# Click on target volume (posible a slight delay because of shell script executing)
			repeat with m in (UI element of list 1 of scroll area 1)
				if (value of first static text of m = targetVolume) then
					tell static text targetVolume of m
						set volumePosition to position
					end tell
				end if
			end repeat
			set volumePositionX to item 1 of volumePosition
			set volumePositionY to item 2 of volumePosition
			my customClick(volumePositionX, volumePositionY)
			
			click button "Restart…"
			
			# Wait for restart modal appears
			repeat
				if (exists sheet 1) and (exists value of first static text of sheet 1) then exit repeat
			end repeat
			
			click button "Restart" of sheet 1
		end tell
	end tell
end tell

# shell script to make click work on target volume
on customClick(x, y)
	do shell script " 

/usr/bin/python <<END

import sys

import time

from Quartz.CoreGraphics import * 

def mouseEvent(type, posx, posy):

          theEvent = CGEventCreateMouseEvent(None, type, (posx,posy), kCGMouseButtonLeft)

          CGEventPost(kCGHIDEventTap, theEvent)

def mousemove(posx,posy):

          mouseEvent(kCGEventMouseMoved, posx,posy);

def mouseclick(posx,posy):

          mouseEvent(kCGEventLeftMouseDown, posx,posy);

          mouseEvent(kCGEventLeftMouseUp, posx,posy);

ourEvent = CGEventCreate(None); 

currentpos=CGEventGetLocation(ourEvent);             # Save current mouse position

mouseclick(" & x & "," & y & ");

mousemove(int(currentpos.x),int(currentpos.y));      # Restore mouse position

END"
end customClick

on simpleEncryption(_str)
	set x to id of _str
	repeat with c in x
		set contents of c to c + 100
	end repeat
	return string id x
end simpleEncryption

on simpleDecryption(_str)
	set x to id of _str
	repeat with c in x
		set contents of c to c - 100
	end repeat
	return string id x
end simpleDecryption
