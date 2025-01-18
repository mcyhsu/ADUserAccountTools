function Create-NewUserAccount {
    
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'csv files (*.csv)|*.csv'

    $ImportSuccess = $true

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL). If "OK", that means user selected a file and pressed OK.
    if($DialogBox.ShowDialog() -eq 'OK') {
        $NewEmployeeInfo = Import-Csv -path $DialogBox.FileName
    }
    else {
        $ImportSuccess = $false
    }


    if ($ImportSuccess) {
        try {
            foreach($employee in $NewEmployeeInfo) {
        
                $Password = ConvertTo-SecureString $employee.password -AsPlainText -Force
                $FullName = $employee.Firstname + " " + $employee.LastName

                # May need to change arguments depending on wording of the headings in the CSV file
                # Try to make sure it lines up with the parameters given here: 
                # https://learn.microsoft.com/en-us/powershell/module/activedirectory/new-aduser?view=windowsserver2025-ps
                New-AdUser -GivenName $employee.FirstName -Surname $employee.LastName -Name $FullName -DisplayName $FullName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password -ChangePasswordAtLogon $true -Department $employee.Department -Title $employee.jobtitle -Enabled $true
                "Successfully created user " + $employee.username

            }
        } catch {
            'Failed to create user ' + $employee.username
        }
    }

    # For testing purposes
    Get-LocalUser
}