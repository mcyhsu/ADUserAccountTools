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
            $FullName = $employee.Firstname + " " + $employee.LastName

            # These parameters will throw errors, read docs on why:
            # -Manager $employee.manager
            # -phonenumber $employee.phonenumber
            # -office $employee.officelocation
            New-AdUser -GivenName $employee.FirstName -Surname $employee.LastName -Name $FullName -DisplayName $FullName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password -ChangePasswordAtLogon $true -Department $employee.Department -Title $employee.jobtitle
            "Successfully created user " + $employee.username
        }
        catch {
            "Failed to create an account for user $FullName"
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