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

                # May need to change arguments depending on wording of the headings in the CSV file
                New-AdUser -GivenName $employee.FirstName -Surname $employee.LastName -Name $FullName -DisplayName $FullName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password -ChangePasswordAtLogon $true -Department $employee.Department -Title $employee.jobtitle -Enabled $true
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

    # Run this code block if the user loaded a .csv or .txt file
    # Deletes the user accounts according to the information provided by the .csv or .txt file
    if($ImportSuccess) {
        if($CsvOrTxt -eq 'csv') {
            foreach($user in $AccountsToDelete){
                Remove-LocalUser -name $user.username -ErrorAction Stop
                'Deleted user account ' + $user.username + ' from the organization.'
            }
        }
        elseif($CsvOrTxt -eq 'txt') {
            foreach($user in $AccountsToDelete){
                Remove-Localuser -name $user -ErrorAction Stop
                'Deleted user account ' + $user + ' from the organization.' 
            }
        }
    }


}