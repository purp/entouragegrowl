(*
	Public Domain, 2004
	http://holocore.com/
	jacob@verse.org
	
	modifications by Jim Meyer, 2007, 2009
	http://www.geekdaily.org/
	also placed in the public domain
	
	This script notifies the receipt of new messages in
	Entourage using the Growl Notification framework.
	http://growl.info/

	To be executed by a rule in Entourage (e.g. all messages as your last rule, or 'from' 'is in Address Book'). Notifications for high priority messages will be sticky, normal messages auto-dismiss after a few seconds, and low priority messages are ignored. No notifications are posted when Entourage is frontmost.
*)


on run
	set minNotice to 1
	set minSticky to 2
	
	if frontmost is false then
		tell application "Microsoft Entourage"
			set theMessages to the current messages
		end tell
		
		repeat with thisMessage in theMessages
			# Set initial defaults
			set noticeStickiness to no
			set noticePriority to 0
			set mailDescriptor to "new"
			set mailSubject to ""
			set mailSender to ""
			set mailPriority to ""
			
			# Get info from Entourage
			tell application "Microsoft Entourage"
				set mailSubject to get the subject of thisMessage
				set mailPriority to the priority of thisMessage
				set mailSender to the display name of sender of thisMessage as string
				if mailSender is "" then
					set mailSender to the address of sender of thisMessage as string
				end if
				
				# Translate Entourage priorities to Growl priorities and refine urgency description
				if mailPriority is lowest then
					set noticePriority to -2
				else if mailPriority is low then
					set noticePriority to -1
				else if mailPriority is normal then
					set noticePriority to 0
				else if mailPriority is high then
					set noticePriority to 1
					set mailDescriptor to "important"
				else if mailPriority is highest then
					set noticePriority to 2
					set mailDescriptor to "urgent"
				end if
			end tell
			
			# Is it a sticky notice?
			if noticePriority is greater than or equal to minSticky then
				set noticeStickiness to yes
			end if
			
			# Show the notification if we should
			if noticePriority is greater than or equal to minNotice then
				tell application "GrowlHelperApp"
					notify with name "New Email" title ("You have " & mailDescriptor & " email") description ("From " & mailSender & " about " & mailSubject) application name "Microsoft Entourage" priority noticePriority sticky noticeStickiness
				end tell
			end if
		end repeat
	end if
end run