# ADUserAccountTools :wrench: :hammer:
Bulk create, delete, enable, or disable AD users from a CSV or TXT file.

I created this script to improve my PowerShell scripting skill and to serve as a portfolio piece.  **I make no guarantees that this script won't break something. Use it at your own risk.**

## How to use it (Brief)
0. Clone the repo or download the files.
1. Load the script (.ps1) in your environment and run the appropriate cmdlet in PowerShell.
2. A file dialog will appear. Select the CSV or TXT file containing employee data.
3. Cmdlet will create, delete, enable, or disable the user accounts listed in the CSV or TXT file.
4. Cmdlet returns operation result as objects, allowing you to pipeline further, otherwise you're done.

## How to use it (In-depth)
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

The accounts were created in the correct OU (Only the user objects in the Operations OU shown).

![Account properties filled in](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-properties.JPG?raw=true)

The accounts also have the information provided by the CSV filled in (don't worry, they are all fake for this demonstration).

## Failure States :collision:
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

## Modifying the cmdlets for your personal use

How exactly does each function iterate through a CSV or TXT file?

### Modifying New-BulkADUser
![Modifying parameters](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_modifying-parameters.JPG?raw=true)

The **$UserAttributes** hash table, located in the **New-Users** function (which New-BulkADUser repeatedly calls to create each user) may need to be modified to suit your needs.

The Key:Value pair corresponds to the **New-ADUser Parameter** (Key) and **CSV Data** (Value).

Depending on which parameters you want to include and how your CSV file is formatted, you may need to change the code from how it currently is, or format your CSV to work with the code.

![CSV Example](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/csv-data-example.JPG?raw=true)

E.g. This is an example CSV. Instead of **Username**, maybe your CSV file lists user accounts as "Names" or "Users".

### Modifying Enable-BulkADUser, Disable-BulkADUser, Remove-BulkADUser

These cmdlets repeatedly call the **Remove-Users**, **Enable-Users**, and **Disable-Users** functions to do their respective job.

For CSV files, the aforementioned functions loop through each CSV user object and look for the value stored in the **Username** attribute. Then it uses that value to delete/enable/disable the user account.

![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/modifying-username.JPG?raw=true)

Look specifically at the **$UserReference** variable, particularly this part: **else {$employee.username}**, and change "username" to whatever corresponding attribute is tied to the username in your CSV file.

Find all instances of **$UserReference** and change the attribute to whatever you like.

![TXT Example](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/usernames-in-notepad.JPG?raw=true)

For TXT files, you just need to have one username per line. The cmdlet will iterate through the strings and use that username to delete the user account.

## Conclusion
If you want to bulk create, remove, disable, or enable AD users from a CSV or TXT file, the functions provided by ADUserAccountTools can help you do that.

I created this project to get a better understanding of not only PowerShell, but also Active Directory and its hierarchical structure. In a real world scenario with real data, I am confident I can create an even better script.

ADUserAccountTools was created almost entirely on Windows PowerShell ISE, on a VM running Windows Server 2022. This allowed me to freely test my functions in a safe environment without deleting or disabling any actual users.