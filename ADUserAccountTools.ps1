function New-BulkADUser {
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'csv files (*.csv)|*.csv'

    $ImportSuccess = $true

    Write-Host 'Please select the CSV file with the employee information and click on Open to begin creating their accounts.' -ForegroundColor Yellow

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL).
    if($DialogBox.ShowDialog() -eq 'OK') {
        $NewEmployeeInfo = Import-Csv -path $DialogBox.FileName
    }
    else {
        $ImportSuccess = $false
        Write-Host 'Operation cancelled. ' -ForegroundColor Red -NoNewline
        Write-Host 'Please run the New-BulkADUser function again if you still want to create accounts.' -ForegroundColor Yellow
    }

    if ($ImportSuccess) {

        # Initialize an empty array that will store the results of the operation
        $CreationResults = @()

        foreach($employee in $NewEmployeeInfo) {
            try {
                $Password = ConvertTo-SecureString $employee.password -AsPlainText -Force
                $FullName = $employee.Firstname + " " + $employee.LastName

                # This variable will be used to sort users into their proper department OU
                # Modify the path as needed, this is what works for my test environment
                $OUPath = "OU=Users,OU="+ $employee.department + ",OU=USA,DC=Test,DC=local"

                <#
                The New-ADUser cmdlet below may need to be changed depending on what the headings are in your CSV file.
                You can also add more parameters to the cmdlet as needed, such as phone number, location, description, etc.
                #>
                New-AdUser -GivenName $employee.FirstName -Surname $employee.LastName -Name $FullName -DisplayName $FullName -SamAccountName $employee.Username -EmailAddress $employee.email -AccountPassword $Password -ChangePasswordAtLogon $true -Department $employee.Department -Title $employee.jobtitle -Enabled $true -Path $OUPath -ErrorAction Stop

                Write-Host "Successfully created an account for user $($employee.username)." -ForegroundColor Green

                # Store success result as an object
                $CreateResult = [PSCustomObject]@{
                    'Username' = $employee.username
                    'Status' = 'Created'
                }
                $CreationResults = $CreationResults + $CreateResult
            }
            catch {
                Write-Host "Failed to create an account for user $($employee.username). " -ForegroundColor Red -NoNewline
                Write-Host 'They may already exist or you may lack the permission to create an account.' -ForegroundColor Yellow

                # Store failure result as an object
                $CreateResult = [PSCustomObject]@{
                    'Username' = $employee.username
                    'Status' = 'Not created'
                }
                $CreationResults = $CreationResults + $CreateResult
            }
        }
    }
    # Return object array for users to see results or pipeline results further (E.g. with Export-Csv)
    $CreationResults
}

function Remove-BulkADUser {
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'All files (*.*)|*.*|csv files (*.csv)|*.csv|txt files (*.txt)|*.txt'

    $ImportSuccess = $true
    $AccountsToDelete = ''
    $CsvOrTxt = ''

    Write-Host 'Please select the CSV or TXT file with the usernames of the accounts you want to delete and click on Open' -ForegroundColor Yellow

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL). 
    if($DialogBox.ShowDialog() -eq 'OK') {

        # Stores path to file in $FilePath
        $FilePath = $DialogBox.FileName

        # Checks if the file is a .csv or .txt file, stores the contents to a variable
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

        Write-Host 'Operation cancelled. ' -ForegroundColor Red -NoNewline
        Write-Host 'Please run the Remove-BulkADUser function again if you still want to delete accounts.' -ForegroundColor Yellow
    }

    # If csv or txt imported successfully, will loop through each user entry and delete corresponding account
    if($ImportSuccess) {
        # Initialize an array that will hold the results
        $DeletionResults = @()
        
        foreach($employee in $AccountsToDelete) {
            # Determines the proper way to reference the Username depending on whether a .txt or .csv file was imported
            $UserReference = if($CsvOrTxt -eq 'txt') { $employee } else { $employee.username }

            try { 
                # Checks if the user exists before deleting the account
                if(Get-LocalUser -Name $UserReference -ErrorAction Stop) {
                    Remove-Localuser -name $UserReference -ErrorAction Stop
                    Write-Host "Successfully deleted user account $($UserReference)." -ForegroundColor Green
                }
                # User successfully deleted, store the result into a variable
                $DeleteResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = 'Deleted'
                }
                $DeletionResults = $DeletionResults + $DeleteResult
            }
            catch {
                Write-Host "Failed to delete user $($UserReference). " -ForegroundColor Red -NoNewline
                Write-Host 'They may not exist or you lack the permission to delete this account.' -ForegroundColor Yellow

                # User doesn't exist, store the result into a variable
                $DeleteResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = "Doesn't exist"
                }
                $DeletionResults = $DeletionResults + $DeleteResult
            }
        }
    }
    # Return object array for users to see results or pipeline results further (E.g. with Export-Csv)
    $DeletionResults
}

function Disable-BulkADUser {
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'All files (*.*)|*.*|csv files (*.csv)|*.csv|txt files (*.txt)|*.txt'

    $ImportSuccess = $true
    $AccountsToDisable = ''
    $CsvOrTxt = ''

    Write-Host 'Please select the CSV or TXT file with the usernames of the accounts you want to disable and click on Open' -ForegroundColor Yellow

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL). 
    if($DialogBox.ShowDialog() -eq 'OK') {

        # Stores path to file in $FilePath
        $FilePath = $DialogBox.FileName

        # Checks if the file is a .csv or .txt file, stores the contents to a variable
        if($FilePath -like '*.csv'){
            $CsvOrTxt = 'csv'
            $AccountsToDisable = Import-Csv -path $FilePath
        }
        elseif($FilePath -like '*.txt'){
            $CsvOrTxt = 'txt'
            $AccountsToDisable = Get-Content -path $FilePath
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

        Write-Host 'Operation cancelled. ' -ForegroundColor Red -NoNewline
        Write-Host 'Please run the Disable-BulkADUser function again if you still want to disable accounts.' -ForegroundColor Yellow
    }

    # If csv or txt imported successfully, will loop through each user entry and delete corresponding account
    if($ImportSuccess) {
        # Initialize an array that will hold the results
        $DisableResults = @()
        
        foreach($employee in $AccountsToDisable) {
            # Determines the proper way to reference the Username depending on whether a .txt or .csv file was imported
            $UserReference = if($CsvOrTxt -eq 'txt') { $employee } else { $employee.username }

            # Determine next steps based on if 1) the user exists, and 2) if they are enabled/disabled
            $UserExists = if(Get-LocalUser -Name $UserReference -ErrorAction SilentlyContinue) { $true } else { $false }
            $IsEnabled = if($(Get-LocalUser -Name $UserReference -ErrorAction SilentlyContinue).Enabled -eq $true) { $true } else { $false }

            try {
                # Checks if the user account exists and is enabled before disabling the account
                if($UserExists -and $IsEnabled) {
                    Disable-Localuser -name $UserReference -ErrorAction Stop
                    Write-Host "Successfully disabled user account $($UserReference)." -ForegroundColor Green
                }
                else {
                    # Force exit to the catch block, user probably doesn't exist
                    throw
                }
                # User successfully disabled, store the result into a variable
                $DisableResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = 'Disabled'
                }
                $DisableResults = $DisableResults + $DisableResult
            }
            catch {
                $Status = ''

                # If there was an error in the previous step, i.e. the user doesn't exist or the user lacks permission, then display this warning message
                if($UserExists -eq $false) {
                    Write-Host "Failed to disable user $($UserReference). " -ForegroundColor Red -NoNewline
                    Write-Host 'The user account may not exist or you lack the permission to disable this account.' -ForegroundColor Yellow
                    $Status = "Disabled"
                }

                # Specifying that the account exists but is disabled prevents both log messages ("Account doesn't exist", "Account is already disabled") from displaying at the same time.
                if($IsEnabled -eq $false -and $UserExists) {
                    Write-Host "User account $UserReference is already disabled." -ForegroundColor Green
                    $Status = 'Disabled'
                }

                # User doesn't exist or failed to be disabled, store the result as an object
                $DisableResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = $Status
                }
                $DisableResults = $DisableResults + $DisableResult
            }
        }
    }
    # Return object array for users to see results or pipeline results further (E.g. with Export-Csv)
    $DisableResults
}

function Enable-BulkADUser {
    $DialogBox = New-Object -TypeName System.Windows.Forms.OpenFileDialog

    # Sets the file dialog starting point at C:\
    $DialogBox.InitialDirectory = 'C:\'

    # Filters which files will be displayed in the file dialog
    $DialogBox.filter = 'All files (*.*)|*.*|csv files (*.csv)|*.csv|txt files (*.txt)|*.txt'

    $ImportSuccess = $true
    $AccountsToEnable = ''
    $CsvOrTxt = ''

    Write-Host 'Please select the CSV or TXT file with the usernames of the accounts you want to enable and click on Open' -ForegroundColor Yellow

    # ShowDialog() displays the file dialog and captures the result (OK, CANCEL). 
    if($DialogBox.ShowDialog() -eq 'OK') {

        # Stores path to file in $FilePath
        $FilePath = $DialogBox.FileName

        # Checks if the file is a .csv or .txt file, stores the contents to a variable
        if($FilePath -like '*.csv'){
            $CsvOrTxt = 'csv'
            $AccountsToEnable = Import-Csv -path $FilePath
        }
        elseif($FilePath -like '*.txt'){
            $CsvOrTxt = 'txt'
            $AccountsToEnable = Get-Content -path $FilePath
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

        Write-Host 'Operation cancelled. ' -ForegroundColor Red -NoNewline
        Write-Host 'Please run the Enable-BulkADUser function again if you still want to enable accounts.' -ForegroundColor Yellow
    }

    # If csv or txt imported successfully, will loop through each user entry and delete corresponding account
    if($ImportSuccess) {
        # Initialize an array that will hold the results
        $EnableResults = @()
        
        foreach($employee in $AccountsToEnable) {
            # Determines the proper way to reference the Username depending on whether a .txt or .csv file was imported
            $UserReference = if($CsvOrTxt -eq 'txt') { $employee } else { $employee.username }

            # Determine next steps based on if 1) the user exists, and 2) if they are enabled/disabled
            $UserExists = if(Get-LocalUser -Name $UserReference -ErrorAction SilentlyContinue) { $true } else { $false }
            $IsEnabled = if($(Get-LocalUser -Name $UserReference -ErrorAction SilentlyContinue).Enabled -eq $true) { $true } else { $false }

            try {
                # Checks if the user account exists and is disabled before enabling the account
                if($UserExists -and $IsEnabled -eq $false) {
                    Enable-Localuser -name $UserReference -ErrorAction Stop
                    Write-Host "Successfully enabled user account $($UserReference)." -ForegroundColor Green
                }
                else {
                    # Force exit to the catch block, user probably doesn't exist
                    throw
                }
                # User successfully enabled, store the result as an object
                $EnableResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = 'Enabled'
                }
                $EnableResults = $EnableResults + $EnableResult
            }
            catch {
                $Status = ''

                if($UserExists -eq $false) {
                    Write-Host "Failed to enable user $($UserReference). " -ForegroundColor Red -NoNewline
                    Write-Host 'The user account may not exist or you lack the permission to enable this account.' -ForegroundColor Yellow
                    $Status = "Not enabled"
                }

                # If the user doesn't exist, then the user cannot already be enabled
                if($IsEnabled) {
                    Write-Host "User account $UserReference is already enabled." -ForegroundColor Green
                    $Status = 'Enabled'
                }
                
                # User doesn't exist or failed to be enabled, store the result into a variable
                $EnableResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = $Status
                }
                $EnableResults = $EnableResults + $EnableResult
            }
        }
    }
    # Return object array for users to see results or pipeline results further (E.g. with Export-Csv)
    $EnableResults
}