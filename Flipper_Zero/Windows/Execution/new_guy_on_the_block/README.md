# The New Guy On The Block
# Flipper Zero: Create Admin User Payload

## Overview

This payload automates the process of creating a new local administrator account on a target Windows machine. It leverages the Flipper Zero as a USB Human Interface Device (HID) to inject keystrokes, effectively emulating a user performing the task manually but at superhuman speed. The script is designed to be stealthy and efficient.

## Usage

1.  **Customize the payload:** Before running, edit the `payload.txt` file and replace the placeholder values for `PLACEHOLDER_USERNAME` and `PLACEHOLDER_PASSWORD` with your desired username and a strong password. The password should meet the target system's complexity requirements.

2.  **Ensure a clear path:** Make sure the target PC's desktop is visible and ready. The script will handle the User Account Control (UAC) prompt automatically, but a clean starting state is recommended for best results.

3.  **Deploy the payload:** Plug the Flipper Zero into the target machine. The device will be recognized as a keyboard, and the script will begin executing automatically. The total runtime is approximately 10 seconds.

## Script Breakdown

The script uses a series of DuckyScript commands with delays to ensure proper execution:

-   `GUI r`: This command opens the Windows Run dialog box.
-   `STRING powershell`: This types "powershell" into the Run dialog.
-   `CTRL SHIFT ENTER`: This launches PowerShell with administrative privileges, which is necessary to create a new user and add them to the admin group.
-   `LEFTARROW` + `ENTER`: This sequence is designed to bypass the User Account Control (UAC) prompt, selecting "Yes" to run PowerShell as an administrator.
-   `STRING $user = "..."`: This creates a PowerShell variable to hold the new username.
-   `STRING $pass = "..."`: This creates a PowerShell variable for the password.
-   `STRING New-LocalUser -Name $user`: This command creates the new local user account.
-   `STRING Add-LocalGroupMember -Group "Administrators" -Member $user`: This command elevates the newly created user to an administrator.
-   `ALT F4`: This command closes the active PowerShell window, leaving no trace of the script's execution on the desktop.

### **WARNING**
This script is intended for use in an authorized penetration testing or educational environment. Unauthorized use is a violation of the law. Please ensure you have explicit permission before using this tool.
```