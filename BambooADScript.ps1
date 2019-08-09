#Function to ask user if they would like to update all users or one specifically
function promptAllOrSingle
{
    #Clears the screen
    Clear-Host
    start-sleep -m 50

    "`n"
    Write-Host "*********************************************************************************************************"
    Write-Host "Would you like to update all users or one specifically? Type the corresponding number to make a selection"
    Write-Host "1." -NoNewline -ForegroundColor Cyan
    Write-Host " All Users"
    Write-Host "2." -NoNewline -ForegroundColor Cyan
    Write-Host " Single User"
    Write-Host "3." -NoNewline -ForegroundColor Cyan
    Write-Host " Exit"
    Write-Host "*********************************************************************************************************"
    
    #Prompt the user to indicate their choice
    "`n"
    $prompt = Read-Host "Enter your choice"
    if($prompt -eq 1)
    {
        #Call to method to update information on the employees
        updateAllUsers
        #Prints success message after performing updates
        Write-Host "The Users' Information in Active Directory has been Updated" -ForegroundColor Green
        finalChoice
    }
    elseif($prompt -eq 2)
    {
        #Call to method to update information on a specific employee
        updateSingleUser
    }
    elseif($prompt -eq 3)
    {
        Clear-Host
        Exit
    }
    else
    {
        Write-Host "Wrong input, try again." -ForegroundColor Red
        Start-Sleep -Seconds 1.25
        promptAllOrSingle 
    }
}

#Function to go through all the users in the directory and get their information
function updateAllUsers
{
    "`n"
    Write-Host "Press " -NoNewline -ForegroundColor Yellow
    Write-Host "'F2'" -NoNewLine -ForegroundColor Cyan 
    Write-Host " to stop at any time and return to main menu" -ForegroundColor Yellow
    
    Write-Host "Press " -NoNewline -ForegroundColor Yellow
    Write-Host "'Ctrl+C'" -NoNewLine -ForegroundColor Cyan
    Write-Host " to stop the script" -ForegroundColor Yellow

    Start-Sleep -Seconds 2.5

    #Go through each employee in list
    for($i=0;$i -lt $numOfEmp;$i++) 
    {
        #Checks if the F2 key is pressed by user to return to main menu
        $f2KeyIsDown = [Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::F2)
        if($f2KeyIsDown)
        {
            promptAllOrSingle
        }

        #Set the variables
        $id = $response.directory.employees.employee[$i].id
        $firstName = $response.directory.employees.employee[$i].field.Get(1).'#text'
        $lastName = $response.directory.employees.employee[$i].field.Get(2).'#text'
        $jobTitle = $response.directory.employees.employee[$i].field.Get(5).'#text'
        $email = $response.directory.employees.employee[$i].field.Get(7).'#text'
        $department = $response.directory.employees.employee[$i].field.Get(8).'#text'
        $fullName = $firstName + " " + $lastName
        
        #Perform second API call to Bamboo (supervisor)
        $uri2 = 'https://api.bamboohr.com/api/gateway.php/' + $company + '/v1/employees/' + $id + '?fields=supervisor'
        $response2 = Invoke-RestMethod -Method Get -Uri $uri2 -Headers $headers -Credential $credential

        #Checks if the user has a manager listed
        if($response2.employee.field.'#text' -ne $null)
        {
            #Get the supervisor's name
            $supervisor = $response2.employee.field.'#text'
            $pos = $supervisor.indexOf(",")
            $supervisorLastName = $supervisor.substring(0, $pos)
            $supervisorFirstName = $supervisor.substring($pos+1)
            $supervisorNameWithSpace = $supervisorFirstName + " " + $supervisorLastName
            $supervisorName = $supervisorNameWithSpace.trim()
            $supervisorNameNoSpace = $supervisorFirstName + $supervisorLastName
            "`n"
        }
        #Call to function to update the users' information in active directory
        update-ad
    }
}

#Function to get a specific user and all their information
function updateSingleUser
{
    #Prompt user to seach by first part of email, by 4 letters, or by full name
    "`n"
    Write-Host -NoNewline "Enter the "
    Write-Host -NoNewLine -ForegroundColor Cyan "'full name'"
    Write-Host -NoNewLine ", type "
    Write-Host -NoNewLine -ForegroundColor Cyan "'back'" 
    Write-Host -NoNewLine " to go back or type "
    Write-Host -NoNewLine -ForegroundColor Cyan "'exit'"
    Write-Host -NoNewLine " to stop: "
    $search = Read-Host

    if($search -like "exit")
    {
        Clear-Host
        Exit
    }
    elseif($search -like "back")
    {
        #Call to method to bring user back to main page
        promptAllOrSingle
    }
    elseif($search -eq "")
    {
        Write-Host "Input cannot be blank, try again." -ForegroundColor Red
        updateSingleUser
    }
    else
    {
        #Go through each employee in list
        for($i=0;$i -lt $numOfEmp;$i++)
        {
            #If the search is equal to the employee's full name
            if($search -like (($response.directory.employees.employee[$i].field.Get(1).'#text') + " " + ($response.directory.employees.employee[$i].field.Get(2).'#text')))
            {
                #Set the variables
                $id = $response.directory.employees.employee[$i].id
                $firstName = $response.directory.employees.employee[$i].field.Get(1).'#text'
                $lastName = $response.directory.employees.employee[$i].field.Get(2).'#text'
                $jobTitle = $response.directory.employees.employee[$i].field.Get(5).'#text'
                $email = $response.directory.employees.employee[$i].field.Get(7).'#text'
                $department = $response.directory.employees.employee[$i].field.Get(8).'#text'
                $fullName = $firstName + " " + $lastName
            }
       }

        #Display the values of the variables
        "`n"
        Write-Host "******************************************"
        $bambooEmpIdText + $id
        $emailText + $email
        $empFirstNameText + $firstName
        $empLastNameText + $lastName
        $empJobTitleText + $jobTitle
        $empDepartmentText + $department

        #Perform second API call to Bamboo (supervisor)
        $uri2 = 'https://api.bamboohr.com/api/gateway.php/' + $company + '/v1/employees/' + $id + '?fields=supervisor'
        $response2 = Invoke-RestMethod -Method Get -Uri $uri2 -Headers $headers -Credential $credential

        #Checks if the user has a manager listed
        if($response2.employee.field.'#text' -ne $null)
        {
            #Get the supervisor's name
            $supervisor = $response2.employee.field.'#text'
            $pos = $supervisor.indexOf(",")
            $supervisorLastName = $supervisor.substring(0, $pos)
            $supervisorFirstName = $supervisor.substring($pos+1)
            $supervisorNameWithSpace = $supervisorFirstName + " " + $supervisorLastName
            $supervisorName = $supervisorNameWithSpace.trim()
            $supervisorNameNoSpace = $supervisorFirstName + $supervisorLastName
            $empManagerText + $supervisorName
        }
        else
        {
            #If the user does not have a manager listed, indicate so to the user
            Write-Host "$empManagerText No Manager Listed" -ForegroundColor Yellow
        }
        Write-Host "*****************************************"
        "`n"

        #Call to a function that determines if the user has selected the right user
        verify-user-input
    }
}

#Updates AD with the information from bamboo
function update-ad
{
     #Gets the user by name and sets the values in AD
     Get-ADUser -Filter "Name -like '$fullName'" | Set-ADUser -department $department -title $jobTitle -Company $companyName -EmailAddress $email
     Write-Host "Updating AD info for $fullName"

    if($response2.employee.field.'#text' -ne $Null)
    {
        #Get the manager's info
        $manager = Get-ADUser -filter 'name -eq $supervisorName'

        #Gets the user by name and sets the manager in AD
        Get-ADUser -Filter "Name -like '$fullName'" | Set-ADUser -Manager $manager.DistinguishedName
        Write-Host "Updating manager for $fullName"
    }
}

#Function to verify if right user was chosen and update AD if they say yes
function verify-user-input
{
    "`n"
    Write-Warning "The Information in Active Directory will be updated when you type 'yes' and press the enter key"
    Write-Host -NoNewline "Was this the right user? Type "
    Write-Host -NoNewLine -ForegroundColor Cyan "'yes'"
    Write-Host -NoNewLine ", "
    Write-Host -NoNewLine -ForegroundColor Cyan "'no'"
    Write-Host -NoNewLine ", or "
    Write-Host -NoNewLine -ForegroundColor Cyan "'exit' "
    Write-Host -NoNewLine "to stop: "
    $input = Read-Host
    
    if($input -like "yes")
    {
        #Call to function to update info in active directory
        update-ad
        Write-Host "The User's Information in Active Directory has been Updated" -ForegroundColor Green
        #Call to function to ask user what they want to do after updates were completed
        finalChoice
    }
    elseif($input -like "no")
    {
        #Reset variables stored in memory
        $id = $null
        $firstName = $null
        $lastName = $null
        $jobTitle = $null
        $email = $null
        $department = $null
        $supervisorName = $null

        #Clears the screen
        Clear-Host
        start-sleep -m 50
        
        #Call to function that asks which user needs to be updated
        updateSingleUser
    }
    elseif($input -like "exit")
    {
        Clear-Host
        Exit
    }
    else
    {
        Write-Host "Wrong input, try again." -ForegroundColor Red
        verify-user-input
    }
}

#Function to ask user what they would like to do after the updates have been performed
function finalChoice
{
    "`n"
    Write-Host -NoNewLine "Type "
    Write-Host -NoNewLine -ForegroundColor Cyan "'back' "
    Write-Host -NoNewLine "to return to main menu or "
    Write-Host -NoNewLine -ForegroundColor Cyan "'exit'"
    Write-Host -NoNewLine " to stop: "
    $selection = Read-Host
        
    if($selection -like 'exit')
    {
        Clear-Host
        Exit
    }
    elseif($selection -like 'back')
    {
        #Call to function to take user back to main menu
        promptAllOrSingle
    }
    else
    {
        Write-Host "Wrong input, try again." -ForegroundColor Red
        finalChoice
    }
}

Import-Module ActiveDirectory

#Uncomment line below to hide the error message if user is not found (Error 404) and continue execution of script
#$ErrorActionPreference = 'SilentlyContinue'

#Uncomment line below to show the error message if user is not found (Error 404) and continue execution of script
$ErrorActionPreference = 'Continue'

#Declare variables
$id = $null
$firstName = $null
$lastName = $null
$jobTitle = $null
$department = $null
$search = $null
$supervisor = $null
$pos = $null
$supervisorLastName = $null
$supervisorFirstName = $null
$supervisorNameWithSpace = $null
$supervisorName = $null

#Value to replaced for url API call
$company = "xxxxxxxxxxxxxx"

#Value to be replaced for company field in Active Directory
$companyName = "xxxxxxxxxxxxxxxx"

#Create the base text to display for single change confirmations
$bambooEmpIdText = "Bamboo Employee I.D.: "
$empFirstNameText = "First Name: "
$empLastNameText = "Last Name: "
$empJobTitleText = "Job Title: "
$empDepartmentText = "Department: "
$empManagerText = "Manager: "
$emailText = "Email: "

#Perform API call to Bamboo (id, firstName, lastName, jobTitle, department, email)
$apiKey = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
#leave password as is
$password = 'x'
$accept = 'application/xml'
$uri = 'https://api.bamboohr.com/api/gateway.php/' + $company + '/v1/employees/directory'
$headers = @{
    "Accept"=$accept
}
$secpwd = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($apiKey, $secpwd)
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -Credential $credential

#Count Number of Employees
$numOfEmp = $response.SelectNodes("//employee").count

#Start the script
promptAllOrSingle