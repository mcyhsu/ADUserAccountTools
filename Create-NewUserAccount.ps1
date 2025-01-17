<#
Resources:
New-ADUser - https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps

#>

$NewEmployeeInfo = Import-Csv -Path "D:\Coding Files\Create-NewUserAccount\users_truncated.csv"

function testfunction {
    foreach ($employee in $NewEmployeeInfo) {
        $employee.email
    }
}

function Create-NewUserAccount {
    foreach($employee in $NewEmployeeInfo) {
        try {
            $Password = ConvertTo-SecureString $employee.password -AsPlainText -Force
            #New-AdUser -Name $employee.FirstName -Surname $employee.LastName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password -Department $employee.Department -Title $employee.jobtitle -Manager $employee.manager -phonenumber $employee.phonenumber -office $employee.officelocation
            New-AdUser -Name $employee.FirstName -Surname $employee.LastName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password
            "Successfully created user " + $employee.username
        }
        catch {
            "Failed to create user."
        }

    }
    Get-LocalUser
}


function DeleteTestAccounts {
    foreach ($person in $NewEmployeeInfo) {
        Remove-LocalUser -Name $person.Username
        "User " + $person.Username + " has been deleted"
    }
    Get-LocalUser
}