function Create-NewUserAccount {
    
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'csv files (*.csv)|*.csv'

    $ImportSuccess = $true

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL).
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
                $OUPath = "OU=Users,OU="+ $employee.department + ",OU=USA,DC=Test,DC=local"

                # May need to change arguments depending on wording of the headings in the CSV file
                New-AdUser -GivenName $employee.FirstName -Surname $employee.LastName -Name $FullName -DisplayName $FullName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password -ChangePasswordAtLogon $true -Department $employee.Department -Title $employee.jobtitle -Enabled $true -Path $OUPath
                "Successfully created user " + $employee.username
            }
        } catch {
            'Failed to create user ' + $employee.username
        }
    }
}


function DeleteAccounts {
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'All files (*.*)|*.*|csv files (*.csv)|*.csv|txt files (*.txt)|*.txt'

    $ImportSuccess = $true
    $AccountsToDelete = $null
    $CsvOrTxt = ''

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL). 
    if($DialogBox.ShowDialog() -eq 'OK') {
        # This block executes if the user presses OK in the file dialog
        
        # Stores path to file in $FilePath
        $FilePath = $DialogBox.FileName

        # Checks if the file is a .csv or .txt file, stores the contents to $AccountsToDelete with the appropriate cmdlet
        if($FilePath -like '*.csv'){
            $CsvOrTxt = 'csv'
            $AccountsToDelete = Import-Csv -path $FilePath
        }
        elseif($FilePath -like '*.txt'){
            $CsvOrTxt = 'txt'
            $AccountsToDelete = Get-Content -path $FilePath
        }
        else {
            # This block runs when the user loads a file other than a .csv or .txt file
            'Please import a CSV or TXT file.'
            $ImportSuccess = $false
        }

    }
    else {
        # What happens if the user presses CANCEL in the file dialog
        $ImportSuccess = $false
    }

    # If csv or txt imported successfully, will loop through each user entry and delete corresponding account
    if($ImportSuccess) {
        # Initialize an array that will hold the results
        $results = @()
        
        foreach($user in $AccountsToDelete) {
            # Determines the proper way to reference the Username depending on if a .txt or .csv file was imported
            $UserReference = if($CsvOrTxt -eq 'txt') { $user } else { $user.username }

            try { 
                # Checks if the user exists before deleting the account
                if(Get-LocalUser -Identity $UserReference) {
                    Remove-Localuser -name $UserReference -ErrorAction Stop
                    'Deleted user account ' + $UserReference + ' from the organization.'
                }

                # User successfully deleted, store the result into $results
                $result = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Exists' = 'yes'
                    'Deleted' = 'yes'
                }
                $results = $results + $result
            }
            catch {
                # User doesn't exist, store the result into $results
                $result = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Exists' = 'no'
                    'Deleted' = 'no'
                }
                $results = $results + $result
            }
        }

    }
    $results
}