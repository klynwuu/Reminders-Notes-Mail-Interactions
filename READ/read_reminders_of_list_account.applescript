#!/usr/bin/osascript

-- Reminders Manager
-- This script interacts with Apple Reminders to manage reminder items
--
-- HOW TO RUN FROM COMMAND LINE:
-- 1. Save this file (e.g., as reminders_manager.applescript)
-- 2. Open Terminal
-- 3. Run the script using osascript:
--    osascript /path/to/reminders_manager.applescript
--
-- You can also make the script executable:
-- 1. chmod +x /path/to/reminders_manager.applescript
-- 2. Add a shebang line at the top of this file: #!/usr/bin/osascript
-- 3. Then run directly: /path/to/reminders_manager.applescript

-- Step 1: Read and prompt which iCloud account is available in Apple Reminders
on getAvailableAccounts()
    set accountsList to {}
    
    tell application "Reminders"
        set allAccounts to accounts
        repeat with currentAccount in allAccounts
            set accountName to name of currentAccount
            set end of accountsList to accountName
        end repeat
    end tell
    
    -- Display available accounts to the user
    if (count of accountsList) is 0 then
        display dialog "No accounts found in Reminders." buttons {"OK"} default button "OK"
        return false
    else
        -- Use choose from list instead of display dialog with text input
        set selectedAccount to choose from list accountsList with prompt "Select an account:" with title "Available Accounts" OK button name "Next" cancel button name "Cancel"
        
        if selectedAccount is false then
            -- User clicked Cancel
            return false
        else
            -- User selected an account
            return item 1 of selectedAccount
        end if
    end if
end getAvailableAccounts

-- Step 2: Show which lists are available in the selected account
on getAvailableLists(accountName)
    set listsList to {}
    
    tell application "Reminders"
        set selectedAccount to account accountName
        set allLists to lists of selectedAccount
        
        repeat with currentList in allLists
            set listName to name of currentList
            set end of listsList to listName
        end repeat
    end tell
    
    -- Display available lists to the user
    if (count of listsList) is 0 then
        display dialog "No lists found in account " & accountName & "." buttons {"OK"} default button "OK"
        return false
    else
        -- Use choose from list instead of display dialog with text input
        set selectedList to choose from list listsList with prompt "Select a list from account " & accountName & ":" with title "Available Lists" OK button name "Next" cancel button name "Cancel"
        
        if selectedList is false then
            -- User clicked Cancel
            return false
        else
            -- User selected a list
            return item 1 of selectedList
        end if
    end if
end getAvailableLists

-- Function to save reminder details to a file
on saveRemindersToFile(reminderDetails, listName)
    -- Get current date in format YYYY-MM-DD
    set currentDate to do shell script "date +%Y-%m-%d"
    
    -- Create filename
    set fileName to listName & "_reminders_read_on_" & currentDate & ".txt"
    
    -- Ask user to select a folder to save the file
    try
        set targetFolder to choose folder with prompt "Select a folder to save the reminders file:"
        set filePath to (POSIX path of targetFolder) & fileName
        
        -- Write to file
        try
            -- Write the reminder details to the file
            do shell script "echo " & quoted form of reminderDetails & " > " & quoted form of filePath
            return filePath
        on error errMsg
            display dialog "Error saving reminders to file: " & errMsg buttons {"OK"} default button "OK"
            return false
        end try
    on error
        -- User canceled folder selection
        display dialog "File save canceled." buttons {"OK"} default button "OK"
        return false
    end try
end saveRemindersToFile

-- Step 3: Display reminder items with their properties and details
on displayReminders(accountName, listName)
    set reminderDetails to ""
    set maxRemindersToShow to 50 -- Limit the number of reminders to prevent hanging
    
    tell application "Reminders"
        set selectedAccount to account accountName
        set selectedList to list listName of selectedAccount
        
        -- Show a progress dialog
        display dialog "Loading reminders from list '" & listName & "'..." buttons {"Cancel"} default button "Cancel" giving up after 1 with title "Loading Reminders"
        
        -- Get reminders with a timeout to prevent hanging
        try
            set allReminders to reminders of selectedList
            
            if (count of allReminders) is 0 then
                set reminderDetails to "No reminders found in list " & listName & "."
            else
                set totalCount to count of allReminders
                set displayCount to totalCount
                
                -- Limit the number of reminders to display if there are too many
                if totalCount > maxRemindersToShow then
                    set displayCount to maxRemindersToShow
                    set reminderDetails to "Showing first " & maxRemindersToShow & " of " & totalCount & " reminders:" & return & return
                end if
                
                -- Process only up to the maximum number of reminders
                repeat with i from 1 to displayCount
                    set currentReminder to item i of allReminders
                    
                    -- Get basic properties with error handling
                    try
                        set reminderName to name of currentReminder
                    on error
                        set reminderName to "[Error reading name]"
                    end try
                    
                    try
                        set reminderId to id of currentReminder
                    on error
                        set reminderId to "[Error reading ID]"
                    end try
                    
                    try
                        set reminderCompleted to completed of currentReminder
                    on error
                        set reminderCompleted to "[Error reading status]"
                    end try
                    
                    -- Start building the details string
                    set reminderDetails to reminderDetails & "Reminder #" & i & ":" & return
                    set reminderDetails to reminderDetails & "  Name: " & reminderName & return
                    set reminderDetails to reminderDetails & "  ID: " & reminderId & return
                    set reminderDetails to reminderDetails & "  Completed: " & reminderCompleted & return
                    set reminderDetails to reminderDetails & "  List: " & listName & return
                    
                    -- Get creation date if available
                    try
                        set reminderCreationDate to creation date of currentReminder
                        set reminderDetails to reminderDetails & "  Creation Date: " & reminderCreationDate & return
                    on error
                        set reminderDetails to reminderDetails & "  Creation Date: Not available" & return
                    end try
                    
                    -- Get modification date if available
                    try
                        set reminderModDate to modification date of currentReminder
                        set reminderDetails to reminderDetails & "  Modification Date: " & reminderModDate & return
                    on error
                        set reminderDetails to reminderDetails & "  Modification Date: Not available" & return
                    end try
                    
                    -- Get completion date if available
                    try
                        if reminderCompleted then
                            set reminderCompletionDate to completion date of currentReminder
                            set reminderDetails to reminderDetails & "  Completion Date: " & reminderCompletionDate & return
                        end if
                    on error
                        -- Skip if not completed or error
                    end try
                    
                    -- Get due date if available (with timeout)
                    try
                        set reminderDueDate to due date of currentReminder
                        set reminderDetails to reminderDetails & "  Due Date: " & reminderDueDate & return
                    on error
                        set reminderDetails to reminderDetails & "  Due Date: Not set" & return
                    end try
                    
                    -- Get all-day due date if available
                    try
                        set reminderAllDayDueDate to allday due date of currentReminder
                        set reminderDetails to reminderDetails & "  All-Day Due Date: " & reminderAllDayDueDate & return
                    on error
                        -- Skip if not set
                    end try
                    
                    -- Get remind me date if available
                    try
                        set reminderRemindDate to remind me date of currentReminder
                        set reminderDetails to reminderDetails & "  Remind Me Date: " & reminderRemindDate & return
                    on error
                        -- Skip if not set
                    end try
                    
                    -- Get priority if available (with timeout)
                    try
                        set reminderPriority to priority of currentReminder
                        set priorityText to "None"
                        if reminderPriority is 0 then
                            set priorityText to "No Priority"
                        else if reminderPriority ³ 1 and reminderPriority ² 4 then
                            set priorityText to "High"
                        else if reminderPriority is 5 then
                            set priorityText to "Medium"
                        else if reminderPriority ³ 6 and reminderPriority ² 9 then
                            set priorityText to "Low"
                        end if
                        set reminderDetails to reminderDetails & "  Priority: " & priorityText & " (" & reminderPriority & ")" & return
                    on error
                        set reminderDetails to reminderDetails & "  Priority: Not set" & return
                    end try
                    
                    -- Get flagged status if available
                    try
                        set reminderFlagged to flagged of currentReminder
                        set reminderDetails to reminderDetails & "  Flagged: " & reminderFlagged & return
                    on error
                        set reminderDetails to reminderDetails & "  Flagged: Not available" & return
                    end try
                    
                    -- Get notes if available (with timeout)
                    try
                        set reminderNotes to body of currentReminder
                        if reminderNotes is not "" then
                            -- Truncate long notes to prevent display issues
                            if (count of reminderNotes) > 100 then
                                set reminderNotes to text 1 thru 100 of reminderNotes & "..."
                            end if
                            set reminderDetails to reminderDetails & "  Notes: " & reminderNotes & return
                        else
                            set reminderDetails to reminderDetails & "  Notes: None" & return
                        end if
                    on error
                        set reminderDetails to reminderDetails & "  Notes: None" & return
                    end try
                    
                    -- Get URL if available
                    try
                        set reminderURL to url of currentReminder
                        if reminderURL is not "" then
                            set reminderDetails to reminderDetails & "  URL: " & reminderURL & return
                        end if
                    on error
                        -- Skip if no URL
                    end try
                    
                    set reminderDetails to reminderDetails & return
                    
                    -- Check if we should continue every 5 items (to allow cancellation)
                    if i mod 5 = 0 and i < displayCount then
                        try
                            display dialog "Loading reminders (" & i & " of " & displayCount & ")..." buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel" giving up after 1 with title "Loading Reminders"
                        on error
                            -- User canceled, stop processing
                            set reminderDetails to reminderDetails & "Processing canceled by user." & return
                            exit repeat
                        end try
                    end if
                end repeat
            end if
        on error errMsg
            set reminderDetails to "Error loading reminders: " & errMsg
        end try
    end tell
    
    -- Save reminders to file
    set filePath to saveRemindersToFile(reminderDetails, listName)
    
    -- Display the reminders
    if filePath is not false then
        display dialog "Reminders in list " & listName & ":" & return & return & reminderDetails & return & return & "Reminders saved to: " & filePath buttons {"OK"} default button "OK" with title "Reminder Details"
    else
        display dialog "Reminders in list " & listName & ":" & return & return & reminderDetails buttons {"OK"} default button "OK" with title "Reminder Details"
    end if
    
    -- Return the reminder details
    return reminderDetails
end displayReminders

-- Step 4: Display all reminders across all lists with their column information
on displayAllReminders(accountName)
    set reminderDetails to ""
    set maxRemindersPerList to 20 -- Limit the number of reminders per list to prevent hanging
    set totalRemindersShown to 0
    set maxTotalReminders to 100 -- Overall limit across all lists
    
    tell application "Reminders"
        set selectedAccount to account accountName
        set allLists to lists of selectedAccount
        
        -- Show a progress dialog
        display dialog "Loading all reminders from account '" & accountName & "'..." buttons {"Cancel"} default button "Cancel" giving up after 1 with title "Loading Reminders"
        
        -- Process each list
        set listCount to count of allLists
        repeat with i from 1 to listCount
            set currentList to item i of allLists
            set currentListName to name of currentList
            
            -- Update progress
            try
                display dialog "Loading list " & i & " of " & listCount & ": " & currentListName buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel" giving up after 1 with title "Loading Lists"
            on error
                -- User canceled
                set reminderDetails to reminderDetails & "Processing canceled by user." & return
                exit repeat
            end try
            
            -- Get reminders for this list
            try
                set listReminders to reminders of currentList
                set listReminderCount to count of listReminders
                
                if listReminderCount > 0 then
                    set reminderDetails to reminderDetails & "===== LIST: " & currentListName & " (" & listReminderCount & " reminders) =====" & return & return
                    
                    -- Limit reminders per list
                    set displayCount to listReminderCount
                    if displayCount > maxRemindersPerList then
                        set displayCount to maxRemindersPerList
                        set reminderDetails to reminderDetails & "Showing first " & maxRemindersPerList & " of " & listReminderCount & " reminders in this list" & return & return
                    end if
                    
                    -- Process reminders in this list
                    repeat with j from 1 to displayCount
                        set currentReminder to item j of listReminders
                        
                        -- Get basic properties with error handling
                        try
                            set reminderName to name of currentReminder
                        on error
                            set reminderName to "[Error reading name]"
                        end try
                        
                        try
                            set reminderId to id of currentReminder
                        on error
                            set reminderId to "[Error reading ID]"
                        end try
                        
                        try
                            set reminderCompleted to completed of currentReminder
                        on error
                            set reminderCompleted to "[Error reading status]"
                        end try
                        
                        -- Start building the details string
                        set reminderDetails to reminderDetails & "Reminder #" & j & ":" & return
                        set reminderDetails to reminderDetails & "  Name: " & reminderName & return
                        set reminderDetails to reminderDetails & "  ID: " & reminderId & return
                        set reminderDetails to reminderDetails & "  Completed: " & reminderCompleted & return
                        set reminderDetails to reminderDetails & "  List: " & currentListName & return
                        
                        -- Get due date if available
                        try
                            set reminderDueDate to due date of currentReminder
                            set reminderDetails to reminderDetails & "  Due Date: " & reminderDueDate & return
                        on error
                            -- Skip if not set
                        end try
                        
                        -- Get all-day due date if available
                        try
                            set reminderAllDayDueDate to allday due date of currentReminder
                            set reminderDetails to reminderDetails & "  All-Day Due Date: " & reminderAllDayDueDate & return
                        on error
                            -- Skip if not set
                        end try
                        
                        -- Get remind me date if available
                        try
                            set reminderRemindDate to remind me date of currentReminder
                            set reminderDetails to reminderDetails & "  Remind Me Date: " & reminderRemindDate & return
                        on error
                            -- Skip if not set
                        end try
                        
                        -- Get flagged status if available
                        try
                            set reminderFlagged to flagged of currentReminder
                            set reminderDetails to reminderDetails & "  Flagged: " & reminderFlagged & return
                        on error
                            -- Skip if not available
                        end try
                        
                        -- Get notes if available
                        try
                            set reminderNotes to body of currentReminder
                            if reminderNotes is not "" then
                                -- Truncate long notes to prevent display issues
                                if (count of reminderNotes) > 100 then
                                    set reminderNotes to text 1 thru 100 of reminderNotes & "..."
                                end if
                                set reminderDetails to reminderDetails & "  Notes: " & reminderNotes & return
                            end if
                        on error
                            -- Skip if error
                        end try
                        
                        -- Get URL if available
                        try
                            set reminderURL to url of currentReminder
                            if reminderURL is not "" then
                                set reminderDetails to reminderDetails & "  URL: " & reminderURL & return
                            end if
                        on error
                            -- Skip if no URL
                        end try
                        
                        set reminderDetails to reminderDetails & return
                        
                        -- Increment total count
                        set totalRemindersShown to totalRemindersShown + 1
                        
                        -- Check if we've hit the overall limit
                        if totalRemindersShown ³ maxTotalReminders then
                            set reminderDetails to reminderDetails & "Maximum total reminders limit reached (" & maxTotalReminders & ")." & return
                            exit repeat
                        end if
                    end repeat
                end if
                
                -- Check if we've hit the overall limit
                if totalRemindersShown ³ maxTotalReminders then
                    exit repeat
                end if
                
            on error errMsg
                set reminderDetails to reminderDetails & "Error loading list " & currentListName & ": " & errMsg & return & return
            end try
        end repeat
    end tell
    
    -- Save reminders to file
    set filePath to saveRemindersToFile(reminderDetails, "All_Lists_" & accountName)
    
    -- Display the reminders
    if filePath is not false then
        display dialog "All Reminders in Account " & accountName & ":" & return & return & reminderDetails & return & return & "Reminders saved to: " & filePath buttons {"OK"} default button "OK" with title "All Reminder Details"
    else
        display dialog "All Reminders in Account " & accountName & ":" & return & return & reminderDetails buttons {"OK"} default button "OK" with title "All Reminder Details"
    end if
    
    -- Return the reminder details
    return reminderDetails
end displayAllReminders

-- Main script
on run
    -- Step 1: Get available accounts
    set selectedAccount to getAvailableAccounts()
    
    if selectedAccount is not false then
        -- Ask user if they want to view a specific list or all reminders
        set viewOption to choose from list {"View a specific list", "View all reminders across all lists"} with prompt "What would you like to do?" with title "Reminders Options" OK button name "Select" cancel button name "Cancel"
        
        if viewOption is not false then
            set selectedOption to item 1 of viewOption
            
            if selectedOption is "View a specific list" then
                -- Step 2: Get available lists for the selected account
                set selectedList to getAvailableLists(selectedAccount)
                
                if selectedList is not false then
                    -- Step 3: Display reminders in the selected list
                    displayReminders(selectedAccount, selectedList)
                end if
            else
                -- Step 4: Display all reminders across all lists
                displayAllReminders(selectedAccount)
            end if
        end if
    end if
end run 