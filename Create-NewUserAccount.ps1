function Create-NewUserAccount {
    
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
        Write-Host 'Account creation cancelled. ' -ForegroundColor Red -NoNewline
        Write-Host 'Please run the Create-NewUserAccount function again if you still want to create accounts.' -ForegroundColor Yellow
    }

    if ($ImportSuccess) {

        # Initialize an empty array that will store the results of the operation
        $CreationResults = @()

        foreach($employee in $NewEmployeeInfo) {
            try {
                $Password = ConvertTo-SecureString $employee.password -AsPlainText -Force
                $FullName = $employee.Firstname + " " + $employee.LastName

                # This variable will be used to sort users into their proper department OU
                $OUPath = "OU=Users,OU="+ $employee.department + ",OU=USA,DC=Test,DC=local"

                # May need to change arguments depending on wording of the headings in the CSV file
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
                Write-Host 'They may already exist or there was an error in the provided information.' -ForegroundColor Yellow

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
    $CreationResults | Sort-Object -Property 'Status' -Descending | Format-Table -Autosize
}


function DeleteAccounts {
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

        Write-Host 'Account deletion cancelled. ' -ForegroundColor Red -NoNewline
        Write-Host 'Please run the DeleteAccounts function again if you still want to delete accounts.' -ForegroundColor Yellow
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
                    Write-Host "Successfully deleted user account $UserReference from the organization." -ForegroundColor Green
                }

                # User successfully deleted, store the result into $results
                $DeleteResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = 'Deleted'
                }
                $DeletionResults = $DeletionResults + $DeleteResult
            }
            catch {
                Write-Host "Failed to delete user $($UserReference). " -ForegroundColor Red -NoNewline
                Write-Host 'They may not exist or there was an error in the provided information.' -ForegroundColor Yellow

                # User doesn't exist, store the result into $results
                $DeleteResult = [PSCustomObject]@{
                    'Username' = $UserReference
                    'Status' = "Doesn't exist"
                }
                $DeletionResults = $DeletionResults + $DeleteResult
            }
        }

    }
    # Return object array for users to see results or pipeline results further (E.g. with Export-Csv)
    $DeletionResults | Sort-Object -Property 'Deleted' -Descending | Format-Table -Autosize
}