# Reminders-Notes-Mail-Interactions
A repo handling interaction among Apple's native apps: Reminders, Notes, Mail

## Scripts

### Reminders Manager (`read_reminders_of_list_account.applescript`)

This AppleScript provides a comprehensive interface for interacting with Apple's Reminders app, allowing users to extract and save reminder data.

#### Features

- **Account Selection**: Lists all available accounts in Reminders and lets the user select one
- **List Navigation**: Displays all reminder lists within the selected account
- **Viewing Options**:
  - View reminders from a specific list
  - View all reminders across all lists in an account
- **Detailed Information**: Extracts comprehensive details for each reminder, including:
  - Basic properties (name, ID, completion status)
  - Dates (creation, modification, completion, due date)
  - Priority levels
  - Flag status
  - Notes/body content
  - URLs
  - All-day due dates
  - Remind me dates
- **Data Export**: Saves all extracted reminder data to a text file with date-stamped filename
- **Progress Tracking**: Shows loading progress and allows cancellation during lengthy operations
- **Error Handling**: Robust error handling for all operations
- **Limits**: Implements sensible limits (50 reminders per list, 100 total) to prevent performance issues

#### How to Run

From the command line:
```bash
osascript /path/to/read_reminders_of_list_account.applescript
```

Or make it executable:
```bash
chmod +x /path/to/read_reminders_of_list_account.applescript
./read_reminders_of_list_account.applescript
```

#### Workflow

1. The script presents a list of available Reminders accounts
2. User selects an account
3. User chooses to view a specific list or all reminders
4. If viewing a specific list, user selects which list to view
5. The script extracts and displays reminder details
6. User selects a location to save the extracted data
7. Data is saved to a text file with format: `[ListName]_reminders_read_on_[Date].txt`

This script is useful for backing up reminder data, migrating between systems, or analyzing reminder usage patterns.
