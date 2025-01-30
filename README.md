![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/aduseraccounttools-hero.png?raw=true)
**Bulk create, delete, enable, or disable AD users from a CSV or TXT file.**

I created this script to improve my PowerShell scripting skill and to serve as a portfolio piece.

## Table of Contents
- [Table of Contents](#table-of-contents)
- [How to use this script (Brief)](#how-to-use-this-script-brief)
- [How to use this script (In-depth)](#how-to-use-this-script-in-depth)
- [New-BulkADUser Cmdlet](#new-bulkaduser-cmdlet)
  - [Calling the cmdlet](#calling-the-cmdlet)
  - [Creating the accounts](#creating-the-accounts)
  - [Failure States](#failure-states)
- [Remove-BulkADUser Cmdlet](#remove-bulkaduser-cmdlet)
- [Disable-BulkADUser Cmdlet](#disable-bulkaduser-cmdlet)
- [Enable-BulkADUser Cmdlet](#enable-bulkaduser-cmdlet)
- [Modifying the cmdlets for your personal use](#modifying-the-cmdlets-for-your-personal-use)
- [Conclusion](#conclusion)

## How to use this script (Brief)
0. Clone the repo or download the files.
1. Load the script (.ps1) in your environment and run the appropriate cmdlet in PowerShell.
2. A file dialog will appear. Select the CSV or TXT file containing employee data.
3. Cmdlet will create, delete, enable, or disable the user accounts listed in the CSV or TXT file.
4. Cmdlet returns operation result as objects, allowing you to pipeline further, otherwise you're done.

## How to use this script (In-depth)
There are 4 main cmdlets:
![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/cmdlet-overview.png?raw=true)

1. **New-BulkADUser**
2. **Remove-BulkADUser** 
3. **Enable-BulkADUser**
4. **Disable-BulkADuser**

Each cmdlet works similarly, and what they do should be obvious, so I'll mostly go over how the **New-BulkADUser** cmdlet works to create new AD user accounts.

## New-BulkADUser Cmdlet
![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser-overview.png?raw=true)

### Calling the cmdlet
After running the script, type **New-BulkADUser** with no arguments into the terminal. 

![Opened up a file dialog](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_file-dialog.JPG?raw=true)

This will bring up the file dialog where you can navigate to where your CSV file is.

Alternatively, you can call the cmdlet two other ways:

1. With an argument: **New-BulkADUser -LoadUser 'C:\Path\to\File.csv'**

2. By pipeline: **Import-Csv -Path 'C:\Path\to\File.csv' | New-BulkADUser**

### Creating the accounts

Once you've selected your CSV file, the cmdlet will automatically run:

![Account creation success](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-created.JPG?raw=true)

You can see the function updating you on the progress of the operation in the terminal ("Successfully created an account").

At the end of the operation, it returns the results as objects. This means you can pipeline it further, like so:

**New-BulkADUser -LoadUser 'C:\Path\to\File.csv' | Export-Csv -Path 'C:\Path\to\Results.csv' -NoTypeInformation**

Congratulations, you just created a batch of AD user accounts from a CSV file and exported the results into another CSV file.

Now let's try creating 100 users.

![100 accounts created](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_create-100-accounts.JPG?raw=true)

There were so many accounts created, the results are cut off.

![Accounts in ADUC](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_accounts-in-AD.JPG?raw=true)

The accounts were created in the correct OU (Only the user objects in the Operations OU shown).

![Account properties filled in](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-properties.JPG?raw=true)

The accounts also have the information provided by the CSV filled in (don't worry, they are all fake for this demonstration).

### Failure States
What happens if something goes wrong? Here are the most common errors.

**The account(s) failed to be created for some reason**

![Account creation failure](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_account-not-created.JPG?raw=true)
Common Reasons:
1. The account already exists.
2. The CSV file was formatted improperly or contains illegal characters.
3. You lack the permission to create user accounts.
4. The code is broken (sorry!).

**File dialog cancelled**
![File dialog cancelled](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_file-dialog-cancelled.JPG?raw=true)

If you press Cancel on the file dialog, the function will stop running and you need to call it again.

**Improper file selected**
![Improper file selected](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_invalid-csv.JPG?raw=true)

If you enter the wrong file path or a file that is not a CSV, an error message will trigger.

That is how the New-BulkADUser cmdlet works. The other cmdlets work similarly, so you can apply the same concept to them. I'll only briefly explain how they work below.

## Remove-BulkADUser Cmdlet
![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/remove-bulkaduser-overview.png?raw=true)

![Removed accounts](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/remove-bulkaduser_removed-accounts.JPG?raw=true)

**Remove-BulkADUser** deletes the accounts listed in the CSV or TXT file.

## Disable-BulkADUser Cmdlet
![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/disable-bulkaduser-overview.png?raw=true)

![Disabled accounts](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/disable-bulkaduser_disabled-accounts.JPG?raw=true)

**Disable-BulkADUser** disables the accounts listed in the CSV or TXT file.

## Enable-BulkADUser Cmdlet
![](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/enable-bulkaduser-overview.png?raw=true)

![Enabled accounts](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/enable-bulkadusers_enabled-accounts.JPG?raw=true)

**Enable-BulkADuser** enables the accounts listed in the CSV or TXT file.

## Modifying the cmdlets for your personal use

This script might not work out of the box; certain attributes might need to be changed to match what they are called in your CSV files, for instance.

Let's take a look at what that might look like.

**Modifying New-BulkADUser**
![Modifying parameters](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/new-bulkaduser_modifying-parameters.JPG?raw=true)

The **$UserAttributes** hash table, located in the **New-Users** function (which New-BulkADUser repeatedly calls to create each user) may need to be modified to suit your needs.

The Key:Value pair corresponds to the **New-ADUser Parameter** (Key) and **CSV Data** (Value).

Depending on which parameters you want to include and how your CSV file is formatted, you may need to change the code from how it currently is, or format your CSV to work with the code.

![CSV Example](https://github.com/mcyhsu/ADUserAccountTools/blob/master/Assets/csv-data-example.JPG?raw=true)

E.g. This is an example CSV. Instead of **Username**, maybe your CSV file lists user accounts as "Names" or "Users".

**Modifying Enable-BulkADUser, Disable-BulkADUser, Remove-BulkADUser**

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

**Photo and icon credits:**
- Photo by Andrea Piacquadio: https://www.pexels.com/photo/man-in-white-dress-shirt-sitting-on-black-rolling-chair-while-facing-black-computer-set-and-smiling-840996/
- <a href="https://www.flaticon.com/free-icons/accept" title="accept icons">Accept icons created by Bharat Icons - Flaticon</a>
- <a href="https://www.flaticon.com/free-icons/deactivate-user" title="deactivate user icons">Deactivate user icons created by barrizon - Flaticon</a>
- <a href="https://www.flaticon.com/free-icons/delete-account" title="delete account icons">Delete account icons created by Saepul Nahwan - Flaticon</a>
- <a href="https://www.flaticon.com/free-icons/add" title="add icons">Add icons created by Freepik - Flaticon</a>