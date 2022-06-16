$global:ErrorActionPreference = "Stop"
if ($verbose) { 
    $global:VerbosePreference = "Continue"
}

if (([string]::IsNullOrEmpty($LogsFile)) -or ($LogsFile.Length -eq 0)) {
    $LogsDir = "$(Get-Location)\Logs"        
    $LogsFileName = "AI_$(Get-Date -format dd-MM-yyyy)_$((Get-Date -format HH:mm:ss).Replace(":","-")).log"                   
    $LogsFile = Join-Path $LogsDir $LogsFileName  
}

function AI_WriteLog {    
    [CmdletBinding()]
    param (       
        [Parameter(Mandatory = $true)][ValidateSet("I", "S", "W", "E", "-", IgnoreCase = $True)][string]$Information,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Output
    )
    
    begin {        
    }
    
    process {       

        if (!(Test-Path -Path $LogsDir)) {            
            New-Item $LogsDir -ItemType "directory" -Force | Out-Null
        }        
       
        if (!(Test-Path $LogsFile) ) {                
            New-Item $LogsFile -ItemType "file" -Force | Out-Null
        }       
    
        $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss) 
    
        if ($Output -eq "") {
            Add-Content $LogsFile -value ("") 
        }
        else {
            Add-Content $LogsFile -value ($DateTime + " " + $Information.ToUpper() + " - " + $Output)
        }                 
        
        if ($Information -eq "I") {
            Write-Host "$($Information.ToUpper()) - $Output" -ForegroundColor DarkCyan 
        }
        elseif ($Information -eq "S") {
            Write-Host "$($Information.ToUpper()) - $Output" -ForegroundColor DarkGreen
        }
        elseif ($Information -eq "W") {
            Write-Host "$($Information.ToUpper()) - $Output" -ForegroundColor DarkYellow
        }
        elseif ($Information -eq "E") {
            Write-Host "$($Information.ToUpper()) - $Output" -ForegroundColor DarkRed
        }
    }
    
    end {        
    }
}

function AI_CreateDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Directory
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
    
    process {
        AI_WriteLog "I" "Create directory $Directory" 
        if (Test-Path $Directory) {
            AI_WriteLog "I" "The directory $Directory already exists. Nothing to do"
        }
        else {
            try {
                New-Item -ItemType Directory -Path $Directory -Force | Out-Null
                AI_WriteLog "S" "Successfully created the directory $Directory"
            }
            catch {
                AI_WriteLog "E" "An error occurred trying to create the directory $Directory (exit code: $($Error[0]))!" 
                Exit 1
            }
        }
    }

    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_DeleteDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Directory
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }    
  
    process {
        AI_WriteLog "I" "Delete directory $Directory" 
        if (Test-Path $Directory) {
            try {
                Remove-Item $Directory -Force -Recurse | Out-Null
                AI_WriteLog "S" "Successfully deleted the directory $Directory" 
            }
            catch {
                AI_WriteLog "E" "An error occurred trying to delete the directory $Directory (exit code: $($Error[0]))!" 
                Exit 1
            }
        }
        else {
            AI_WriteLog "I" "The directory $Directory does not exist. Nothing to do" 
        }
    }

    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_DeleteFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $File
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }    
  
    process {
        AI_WriteLog "I" "Delete the file '$File'" 
        if (Test-Path $File) {
            try {
                .\nircmdc.exe filldelete "$File"
                AI_WriteLog "S" "Successfully deleted the file '$File'" 
            }
            catch {
                AI_WriteLog "E" "An error occurred trying to delete the file '$File' (exit code: $($Error[0]))!" 
                Exit 1
            }
        }
        else {
            AI_WriteLog "I" "The file '$File' does not exist. Nothing to do" 
        }
    }

    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_RenameEntity {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$ItemPath,
        [Parameter(Mandatory = $true)][string]$NewName
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }    
  
    process {
        AI_WriteLog "I" "Rename '$ItemPath' to '$NewName'" 

        if (Test-Path $ItemPath) {
            try {
                Rename-Item -Path $ItemPath -NewName $NewName | Out-Null
                AI_WriteLog "S" "The item '$ItemPath' was renamed to '$NewName' successfully" 
            }
            catch {
                AI_WriteLog "E" "An error occurred trying to rename the item '$ItemPath' to '$NewName' (exit code: $($Error[0]))!" 
                Exit 1
            }
        }
        else {
            AI_WriteLog "I" "The item '$ItemPath' does not exist. Nothing to do" 
        }
    }

    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_CleanupDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Directory
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
 
    process {
        AI_WriteLog "I" "Cleanup directory $Directory" 
        if (Test-Path $Directory) {
            try {               
                .\nircmdc.exe filldelete "$Directory\*.*"
                .\nircmdc.exe filldelete "$Directory\*"
                AI_WriteLog "S" "Successfully deleted all files and subfolders in the directory $Directory" 
            }
            catch {
                AI_WriteLog "E" "An error occurred trying to delete files and subfolders in the directory $Directory (exit code: $($Error[0]))!" 
                Exit 1
            }
        }
        else {
            AI_WriteLog "I" "The directory $Directory does not exist. Nothing to do" 
        }
    }

    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_CopyFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
    
    process {
        AI_WriteLog "I" "Copy the source file(s) '$Source' to '$Destination'" 
       
        if ($Destination.Contains(".")) {
            $TempDir = Split-Path -Path $Destination
        }
        else {
            $TempDir = $Destination
        }
     
        AI_WriteLog "I" "Check if the destination path '$TempDir' exists. If not, create it" 
        if (Test-Path $TempDir) {
            AI_WriteLog "I" "The destination path '$TempDir' already exists. Nothing to do" 
        }
        else {
            AI_WriteLog "I" "The destination path '$TempDir' does not exist" 
            AI_CreateDirectory -Directory $TempDir
        }

        AI_WriteLog "I" "Start copying the source file(s) '$Source' to '$Destination'" 
        try {            
            .\nircmdc.exe shellcopy $Source $Destination silent yestoall noerrorui
            AI_WriteLog "S" "Successfully copied the source files(s) '$Source' to '$Destination'" 
        }
        catch {
            AI_WriteLog "E" "An error occurred trying to copy the source files(s) '$Source' to '$Destination'" 
            Exit 1
        }
    }
    
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_MoveFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
    
    process {
        AI_WriteLog "I" "Move the source file(s) '$Source' to '$Destination'" 
       
        if ($Destination.Contains(".")) {
            $TempDir = Split-Path -Path $Destination
        }
        else {
            $TempDir = $Destination
        }
     
        AI_WriteLog "I" "Check if the destination path '$TempDir' exists. If not, create it!" 
        if (Test-Path $TempDir) {
            AI_WriteLog "I" "The destination path '$TempDir' already exists. Nothing to do!" 
        }
        else {
            AI_WriteLog "I" "The destination path '$TempDir' does not exist. Let's create it!" 
            AI_CreateDirectory -Directory $TempDir
        }

        AI_WriteLog "I" "Start moving the source file(s) '$Source' to '$Destination'" 
        try {            
            Move-Item -Path $Source -Destination $Destination -Force -PassThru
            AI_WriteLog "S" "Successfully moved the source files(s) '$Source' to '$Destination'" 
        }
        catch {
            AI_WriteLog "E" "An error occurred trying to move the source files(s) '$Source' to '$Destination'" 
            Exit 1
        }
    }
    
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_ExecuteProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$FileName,
        [Parameter()][AllowEmptyString()][string]$Parameters     
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
 
    process {
        if (!([string]::IsNullOrEmpty($Parameters))) {     
            AI_WriteLog "I" "Execute process '$Filename' with arguments '$Parameters'" 
            $Process = Start-Process $FileName -ArgumentList $Parameters -wait -NoNewWindow -PassThru
            $Process.HasExited
            $ProcessExitCode = $Process.ExitCode
            if ($ProcessExitCode -eq 0) {
                AI_WriteLog "S" "The process '$Filename' with arguments '$Parameters' ended successfully" 
            }
            else {
                AI_WriteLog "E" "An error occurred trying to execute the process '$Filename' with arguments '$Parameters' (exit code: $ProcessExitCode)!" 
                Exit 1
            }
        }
        else {
            AI_WriteLog "I" "Execute process '$Filename'" 
            $Process = Start-Process $FileName -Wait -NoNewWindow -PassThru
            $Process.HasExited
            $ProcessExitCode = $Process.ExitCode
            if ($ProcessExitCode -eq 0) {
                AI_WriteLog "S" "The process '$Filename' ended successfully" 
            }
            else {
                AI_WriteLog "E" "An error occurred trying to execute the process '$Filename' (exit code: $ProcessExitCode)!" 
                Exit 1
            }
        }
    }
 
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_ServicesWorker {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$ServiceName,
        [ValidateSet("start", "stop", "auto", "manual", "disabled", "boot", "system", IgnoreCase = $false)]
        [Parameter(Mandatory = $true, Position = 1)][string]$StartupType
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
 
    process {
        switch ($StartupType) {
            "start" {
                AI_WriteLog "I" "Start service '$ServiceName' ..."     
      
                if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
                    if (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                        AI_WriteLog "I" "The service $ServiceName is already running" 
                    }
                    else {
                        AI_WriteLog "I" "Check for depend services for service $ServiceName and start them" 
                        $DependServices = ((Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).DependentServices).name
    
                        If ($DependServices.Count -gt 0) {
                            foreach ($Service in $DependServices) {
                                AI_WriteLog "I" "Depend service found: $Service" 
                                .\nircmdc.exe service auto $Service
                                .\nircmdc.exe service start $Service
                            }
                        }
                        else {
                            AI_WriteLog "I" "No depend service found" 
                        }   
              
                        try {
                            .\nircmdc.exe service auto $ServiceName
                            .\nircmdc.exe service start $ServiceName
                        }
                        catch {
                            AI_WriteLog "E" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" 
                            Exit 1
                        }    
             
                        If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                            AI_WriteLog "I" "The service $ServiceName was started successfully" 
                        }
                        else {
                            AI_WriteLog "E" "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!" 
                            Exit 1
                        }
                    }
                }
                else {
                    AI_WriteLog "I" "The service $ServiceName does not exist. Nothing to do" 
                }
                break
            }
            "stop" {
                AI_WriteLog "I" "Stop service '$ServiceName' ..."                  

                if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {                   
                    if (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running") {                    
                        AI_WriteLog "I" "Check for depend services for service '$ServiceName' and stop them" 
                        $DependServices = ((Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).DependentServices).name

                        if ($DependServices.Count -gt 0) {
                            foreach ( $Service in $DependServices ) {
                                AI_WriteLog "I" "Depend service found: $Service"                                
                                .\nircmdc.exe service stop $Service
                            }
                        }
                        else {
                            AI_WriteLog "I" "No depend service found" 
                        }
                     
                        try {                            
                            .\nircmdc.exe service stop $ServiceName
                        }
                        catch {
                            AI_WriteLog "E" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" 
                            Exit 1
                        }

                        If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Stopped") {
                            AI_WriteLog "I" "The service $ServiceName was stopped successfully" 
                        }
                        else {
                            AI_WriteLog "E" "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!" 
                            Exit 1
                        }
                    }
                    else {
                        AI_WriteLog "I" "The service '$ServiceName' is not running" 
                    }
                }
                else {
                    AI_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" 
                }
                break
            }           
            "auto" {
                AI_WriteLog "I" "Change the startup type of the service '$ServiceName' to '$StartupType'" 
               
                If (Get-Service $ServiceName -ErrorAction SilentlyContinue) {                    
                    try {
                        .\nircmdc.exe service auto $ServiceName
                        AI_WriteLog "I" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" 
                    }
                    catch {
                        AI_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" 
                        Exit 1
                    }
                }
                else {
                    AI_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" 
                }
                break
            }
            "manual" {
                AI_WriteLog "I" "Change the startup type of the service '$ServiceName' to '$StartupType'" 
               
                If (Get-Service $ServiceName -ErrorAction SilentlyContinue) {                    
                    try {
                        .\nircmdc.exe service manual $ServiceName
                        AI_WriteLog "I" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" 
                    }
                    catch {
                        AI_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" 
                        Exit 1
                    }
                }
                else {
                    AI_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" 
                }
                break
            }
            "disabled" {
                AI_WriteLog "I" "Change the startup type of the service '$ServiceName' to '$StartupType'" 
               
                If (Get-Service $ServiceName -ErrorAction SilentlyContinue) {                    
                    try {
                        .\nircmdc.exe service disabled $ServiceName
                        AI_WriteLog "I" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" 
                    }
                    catch {
                        AI_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" 
                        Exit 1
                    }
                }
                else {
                    AI_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" 
                }
                break
            }
            "boot" {
                AI_WriteLog "I" "Change the startup type of the service '$ServiceName' to '$StartupType'" 
               
                If (Get-Service $ServiceName -ErrorAction SilentlyContinue) {                    
                    try {
                        .\nircmdc.exe service boot $ServiceName
                        AI_WriteLog "I" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" 
                    }
                    catch {
                        AI_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" 
                        Exit 1
                    }
                }
                else {
                    AI_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" 
                }
                break
            }
            "system" {
                AI_WriteLog "I" "Change the startup type of the service '$ServiceName' to '$StartupType'" 
               
                If (Get-Service $ServiceName -ErrorAction SilentlyContinue) {                    
                    try {
                        .\nircmdc.exe service system $ServiceName
                        AI_WriteLog "I" "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'" 
                    }
                    catch {
                        AI_WriteLog "E" "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!" 
                        Exit 1
                    }
                }
                else {
                    AI_WriteLog "I" "The service '$ServiceName' does not exist. Nothing to do" 
                }
                break
            }
        }
    }
    
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }          
}

function AI_Downloader {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$Url,
        [Parameter()][string]$Directory = "$(Get-Location)\Apps"
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
    
    process {
        $filename = [System.IO.Path]::GetFileName($Url)
        if (!(Test-Path -Path $Directory)) {
            AI_CreateDirectory -Directory $Directory
        }
        
        if (!(Test-Path -Path "$Directory\$filename")) {
            Start-BitsTransfer -Source $Url -Destination $Directory
        }
        else {
            AI_WriteLog "E" "The file '$filename' already exists. Nothing to do."
        }
    }
    
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}

function AI_UniversalInstaller {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$File,        
        [Parameter(Mandatory = $null)][AllowEmptyString()][string]$Parameters        
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }  

    process {
        if ([string]::IsNullOrEmpty($Parameters)) {   
            $Parameters = ""
        }
        $fileName = ($File.Split("\"))[-1]
        $fileExt = $fileName.SubString(($fileName.Length) - 3, 3)
 
        if ($fileExt -eq "msi") {
            $defaultParams = "/i $File /qn /norestart"
            if ([string]::IsNullOrEmpty($Parameters)) {                      
                $parameters = $defaultParams
                AI_WriteLog "I" "Starting installation using msiexec '$parameters'"
                $process = Start-Process -FilePath 'msiexec' -ArgumentList $parameters -Wait -PassThru                       
            }
            else {
                $parameters = $defaultParams + " " + $parameters
                AI_WriteLog "I" "Starting installation using msiexec '$parameters'"
                $process = Start-Process -FilePath 'msiexec' -ArgumentList $parameters -Wait -PassThru            
            }                   
        
            switch ($Process.ExitCode) {        
                0 { 
                    AI_WriteLog "S" "The software was installed successfully (exit code: 0)"             
                }
                1602 {
                    AI_WriteLog "E" "User cancel the installation (exit code: 1602)."
                }
        
                1603 { 
                    AI_WriteLog "E" "A fatal error occurred (exit code: 1603)!"
                }
                1605 { 
                    AI_WriteLog "I" "The software is not currently installed on this machine (exit code: 1605)!" 
                }
                1619 { 
                    AI_WriteLog "E" "The installation files cannot be found. Verify that the package exists and that you can access it (exit code: 1619)!"
                    Exit 1
                }
                3010 { 
                    AI_WriteLog "W" "A reboot is required (exit code: 3010)!" 
                }
                default { 
                    [string]$ExitCode = $Process.ExitCode
                    AI_WriteLog "E" "The installation ended in an error (exit code: $ExitCode)!"
                    Exit 1
                }       
            }
        }
        elseif ($FileExt -eq "exe") {
            $Process = Start-Process -FilePath $File -ArgumentList $parameters -Wait -NoNewWindow -PassThru
            $Process.HasExited
            $ProcessExitCode = $Process.ExitCode
            if ($ProcessExitCode -eq 0) {            
                AI_WriteLog "S" "The file '$fileName' has installed successfully with parameters '$parameters'."                  
            }
            else {            
                AI_WriteLog "E" "An error occurred trying to install '$filename' (exit code: $ProcessExitCode)!"                          
            }   
        }
        else {
            $Process = Start-Process -FilePath $File -Wait -NoNewWindow -PassThru
            $Process.HasExited
            $ProcessExitCode = $Process.ExitCode
            if ($ProcessExitCode -eq 0) {            
                AI_WriteLog "S" "The file '$fileName' has installed successfully"                
            }
            else {            
                AI_WriteLog "E" "An error occurred trying to install '$filename' (exit code: $ProcessExitCode)!"                          
            }               
        }     
    }
 
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }    
}

function AI_GetRevoPro {
    [CmdletBinding()]
    param (
        [Parameter()][string]$Directory = "$(Get-Location)\Apps"
    )
    
    begin {
        [string]$FunctionName = $PSCmdlet.MyInvocation.MyCommand.Name
        AI_WriteLog "I" "START FUNCTION - $FunctionName" 
    }
    
    process {
        $Directory = Resolve-Path -Path $Directory
        $url = "https://download.revouninstaller.com/download/RevoUninProSetup.exe"
        $lic = "https://github.com/CyberMacks/After/releases/download/1.1/revouninstallerpro5.lic"
        $filename = [System.IO.Path]::GetFileName($url)
        if (!(Test-Path -Path "$Directory\$filename")) {
            AI_Downloader -Url $url            
        }
        else {
            AI_UniversalInstaller -File "$Directory\$filename"
        }
    }
    
    end {
        AI_WriteLog "I" "END FUNCTION - $FunctionName" 
    }
}
