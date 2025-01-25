# ADUserAccountTools
Bulk create, delete, enable, or disable AD users from a CSV or TXT file. 

Accepts pipeline input and returns the results of the operation as an object which can be pipelined further. 

**I make no guarantees that this script won't break something. Use it at your own risk.**
## Why I made it
I created this script to improve my PowerShell scripting ability and to serve as a portfolio piece. 
## What it does (Elevator pitch)
1. Run the appropriate cmdlet.
2. A file dialog will appear. Select the CSV or TXT file containing employee data.
3. Cmdlet will create, delete, enable, or disable the user accounts listed in the CSV or TXT file.
4. Cmdlet returns operation result as objects, allowing you to pipeline further.

## What it does (In-depth)
There are 4 main cmdlets:
1. **New-BulkADUser**
2. **Remove-BulkADUser** 
3. **Enable-BulkADUser**
4. **Disable-BulkADuser**

Each cmdlet works similarly, and what they do should be obvious, so I'll only go over how the **New-BulkADUser** cmdlet works to create new AD user accounts.

### Calling the cmdlet
After running the script, type **New-BulkADUser** with no arguments into the terminal. 

![Opened up a file dialog](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_file-dialog.JPG?raw=true)

This will bring up the file dialog where you can navigate to where your CSV file is.

Alternatively, you can call the cmdlet two other ways:

1. With an argument: **New-BulkADUser -LoadUsers 'C:\Path\to\File.csv'**

2. By pipeline: **Import-Csv -Path 'C:\Path\to\File.csv' | New-BulkADUser**

### Creating the accounts

Once you've selected your CSV file, the cmdlet will automatically run:

![Account creation success](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-created.JPG?raw=true)

You can see the function updating you on the progress of the operation in the terminal ("Successfully created an account").

At the end of the operation, it returns the results as objects. This means you can pipeline it further, like so:

**New-BulkADUser -LoadUsers 'C:\Path\to\File.csv' | Export-Csv -Path 'C:\Path\to\Results.csv' -NoTypeInformation**

Congratulations, you just created a batch of AD user accounts from a CSV file and exported the results into another CSV file.

Now let's try creating 100 users.

![100 accounts created](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_create-100-accounts.JPG?raw=true)

There were so many accounts created, the results are cut off.

## Results
![Accounts in ADUC](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_accounts-in-AD.JPG?raw=true)

The accounts were created in the correct OU (Only the user objects in the Sales OU shown).

![Account properties filled in](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-properties.JPG?raw=true)

The accounts also have the information provided by the CSV filled in (don't worry, they are all fake).

## Failure States
What happens if something goes wrong? Here are the most common errors.

### The account(s) failed to be created for some reason

![Account creation failure](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-not-created.JPG?raw=true)
**Common Reasons:**
1. The account already exists.
2. The CSV file was formatted improperly or contains illegal characters.
3. You lack the permission to create user accounts.
4. The code is broken (sorry!).

### File dialog cancelled
![File dialog cancelled](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_file-dialog-cancelled.JPG?raw=true)
If you press Cancel on the file dialog, the function will stop running and you need to call it again.

### Improper file selected
![Improper file selected](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_invalid-csv.JPG?raw=true)
If you enter the wrong file path or a file that is not a CSV, an error message will trigger.

## How do the other functions work?
If you understood how the New-BulkADUsers function works, then you basically also understand how the other ones work.

![Disabled accounts](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/disable-bulkaduser_disabled-accounts.JPG?raw=true)

**Disable-BulkADUser** disables the accounts listed in the CSV or TXT file.

![Enabled accounts](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/enable-bulkadusers_enabled-accounts.JPG?raw=true)

**Enable-BulkADuser** enables the accounts listed in the CSV or TXT file.

![Removed accounts](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/remove-bulkaduser_removed-accounts.JPG?raw=true)

**Remove-BulkADUser** deletes the accounts listed in the CSV or TXT file.

## Conclusion
If you want to bulk create, remove, disable, or enable AD users from a CSV or TXT file, the functions provided by ADUserAccountTools can help you do that.

I created this project to get a better understanding of not only PowerShell, but also Active Directory and its hierarchical structure. In a real world scenario with real data, I am confident I can create an even better script.

ADUserAccountTools was created almost entirely on Windows PowerShell ISE, on a VM running Windows Server 2022. This allowed me to freely test my functions in a safe environment without deleting or disabling any actual users.