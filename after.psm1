class Log4Powershell {
    [ValidateSet("I", "S", "W", "E", "-", IgnoreCase = $True)][string]$InformationType
    [AllowEmptyString()][string]$Text          

    static [void]WriteLog([string]$Information, [string]$Output) {         
        $LogDir = "$(Get-Location)\Logs"        
        $LogFileName = "AfterInstall_$(Get-Date -format dd-MM-yyyy)_$((Get-Date -format HH:mm:ss).Replace(":","-")).log"                   
        $LogFile = Join-Path $LogDir $LogFileName  

        if (!(Test-Path -Path $LogDir)) {            
            New-Item $LogDir -ItemType "directory" -Force | Out-Null
        }        
       
        if (!(Test-Path $LogFile) ) {                
            New-Item $LogFile -ItemType "file" -Force | Out-Null
        }       
    
        $DateTime = (Get-Date -format dd-MM-yyyy) + " " + (Get-Date -format HH:mm:ss) 
    
        if ($Output -eq "") {
            Add-Content $LogFile -value ("") 
        }
        else {
            Add-Content $LogFile -value ($DateTime + " " + $Information.ToUpper() + " - " + $Output)
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
}

class FilesWorker {         
    static [void]CreateDirectory([string]$Directory) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")              
        [Log4Powershell]::WriteLog("I", "Create directory $Directory")

        if (Test-Path $Directory) {            
            [Log4Powershell]::WriteLog("I", "The directory $Directory already exists. Nothing to do")           
        }
        else {
            try {
                New-Item -Path $Directory -ItemType Directory -Force | Out-Null 
                [Log4Powershell]::WriteLog("S", "Successfully created the directory $Directory")                 
            }
            catch {
                [Log4Powershell]::WriteLog("E", "An error occurred trying to create the directory $Directory (exit code: $($Error[0]))!")                
                Exit 1
            }
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")       
    }        

    static [void]CleanDirectory([string]$Directory) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")  
        [Log4Powershell]::WriteLog("I", "Cleanup directory $Directory")
        
        if (Test-Path $Directory) {                       
            try {
                Remove-Item "$Directory\*.*" -Force -Recurse | Out-Null
                Remove-Item "$Directory\*" -Force -Recurse | Out-Null
                [Log4Powershell]::WriteLog("S", "Successfully deleted all files and subfolders in the directory $Directory")                       
            }
            catch {
                [Log4Powershell]::WriteLog("E", "An error occurred trying to delete files and subfolders in the directory $Directory (exit code: $($Error[0]))!")               
                Exit 1
            }
        }
        else {
            [Log4Powershell]::WriteLog("E", "The directory $Directory does not exist. Nothing to do")
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")      
    }

    static [void]DeleteDirectory([string]$Directory) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")      
        [Log4Powershell]::WriteLog("I", "Delete directory $Directory")
        
        if (Test-Path $Directory) {                       
            try {
                Remove-Item $Directory -Force -Recurse | Out-Null            
                [Log4Powershell]::WriteLog("S", "Successfully deleted the directory $Directory")                       
            }
            catch {
                [Log4Powershell]::WriteLog("E", "An error occurred trying to delete the directory $Directory (exit code: $($Error[0]))!")                
                Exit 1
            }
        }
        else {
            [Log4Powershell]::WriteLog("E", "The directory $Directory does not exist. Nothing to do")            
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")          
    }
    
    static [void]CopyFile([string]$SourceFiles, [string]$Destination) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Copy the source file(s) '$SourceFiles' to '$Destination'")
       
        if ($Destination.Contains(".")) {            
            $TempFolder = Split-Path -Path $Destination
        }
        else {
            $TempFolder = $Destination
        }

        [Log4Powershell]::WriteLog("I", "Check if the destination path '$TempFolder' exists. If not, create it")
        
        if (Test-Path $TempFolder) {
            [Log4Powershell]::WriteLog("I", "The destination path '$TempFolder' already exists. Nothing to do")            
        }
        else {
            [Log4Powershell]::WriteLog("I", "The destination path '$TempFolder' does not exist")
            [FilesWorker]::CreateDirectory($TempFolder)                       
        }
            
        [Log4Powershell]::WriteLog("I", "Start copying the source file(s) '$SourceFiles' to '$Destination'")
      
        try {
            #Copy-Item $SourceFiles -Destination $Destination -Force -Recurse        
            .\nircmdc.exe $SourceFiles $Destination yestoall noerrorui silent
            [Log4Powershell]::WriteLog("S", "Successfully copied the source files(s) '$SourceFiles' to '$Destination'")                  
        }
        catch {
            [Log4Powershell]::WriteLog("E", "An error occurred trying to copy the source files(s) '$SourceFiles' to '$Destination'")
            Exit 1
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")        
    }    

    static [void]MoveFile([string]$SourceFiles, [string]$Destination) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Copy the source file(s) '$SourceFiles' to '$Destination'")
       
        if ($Destination.Contains(".")) {            
            $TempFolder = Split-Path -Path $Destination
        }
        else {
            $TempFolder = $Destination
        }

        [Log4Powershell]::WriteLog("I", "Check if the destination path '$TempFolder' exists. If not, create it")
        
        if (Test-Path $TempFolder) {
            [Log4Powershell]::WriteLog("I", "The destination path '$TempFolder' already exists. Nothing to do")            
        }
        else {
            [Log4Powershell]::WriteLog("I", "The destination path '$TempFolder' does not exist")
            [FilesWorker]::CreateDirectory($TempFolder)                       
        }
            
        [Log4Powershell]::WriteLog("I", "Start moving the source file(s) '$SourceFiles' to '$Destination'")
      
        try {
            Move-Item -Path $SourceFiles -Destination $Destination -Force -Recurse                   
            [Log4Powershell]::WriteLog("S", "Successfully moved the source files(s) '$SourceFiles' to '$Destination'")                  
        }
        catch {
            [Log4Powershell]::WriteLog("E", "An error occurred trying to move the source files(s) '$SourceFiles' to '$Destination'")
            Exit 1
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")        
    }    

    static [void]DeleteFile([string]$File) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Delete the file '$File'")
   
        if (Test-Path $File) {        
            try {
                #Remove-Item "$File" -Force -Confirm:$false | Out-Null   
                .\nircmdc.exe filldelete "$File"
                [Log4Powershell]::WriteLog("S", "Successfully deleted the file '$File'")                       
            }
            catch {
                [Log4Powershell]::WriteLog("E", "An error occurred trying to delete the file '$File' (exit code: $($Error[0]))!")               
                Exit 1
            }
        }
        else {
            [Log4Powershell]::WriteLog("I", "The file '$File' does not exist. Nothing to do")           
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")                    
    }    

    static [void]RenameItem([string]$ItemPath, [string]$NewName) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Rename '$ItemPath' to '$NewName'")
       
        if (Test-Path $ItemPath) {        
            try {
                Rename-Item -Path $ItemPath -NewName $NewName -Force -Confirm:$false | Out-Null
                [Log4Powershell]::WriteLog("S", "The item '$ItemPath' was renamed to '$NewName' successfully")                      
            }
            catch {
                [Log4Powershell]::WriteLog("E", "An error occurred trying to rename the item '$ItemPath' to '$NewName' (exit code: $($Error[0]))!")               
                Exit 1
            }
        }
        else {
            [Log4Powershell]::WriteLog("I", "The item '$ItemPath' does not exist. Nothing to do")            
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName") 
    }    
}

class NetworkTaskWorker {     
    static [ValidateNotNullOrEmpty()][string]$Url
   
    static [void]UniversalDownloader ([string]$Url) {                     
        $Directory = "$(Get-Location)Downloads"
        $fileName = [System.IO.Path]::GetFileName($Url)             
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")               
        [Log4Powershell]::WriteLog("I", "Starting download the file '$fileName'") 
        
        if (Test-Path -Path directory -PathType Container) {            
            [Log4Powershell]::WriteLog("E", "Provided download path cannot be a directory.")
        }
        else {
            [FilesWorker]::CreateDirectory($Directory)
        }
                      
        Start-BitsTransfer -Source $Url -Destination $fileName -DisplayName "Get the file '$fileName'"     
    
        if (Test-Path -Path $fileName) {
            Move-Item -Path $filename -Destination $Directory -Force
            [Log4Powershell]::WriteLog("I", "Downloaded file to '$Directory'.")
        }
        else {
            [Log4Powershell]::WriteLog("E", "Failed to download file to '$Directory'")
        } 
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")
    }    
}

class TasksWorker {         
    static [void]ExecuteProcess([string]$ProcessName, [string]$Param) { 
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        if (!([string]::IsNullOrEmpty($Param))) {
            [Log4Powershell]::WriteLog("I", "Execute process '$ProcessName' with parameters '$Param'")          
        }
        else {
            [Log4Powershell]::WriteLog("I", "Execute process '$ProcessName'")            
        }            
       
        if ([string]::IsNullOrEmpty($Param)) {
            [Log4Powershell]::WriteLog("I", "Parameters not set")
            $Process = Start-Process -FilePath $ProcessName -Wait -NoNewWindow -PassThru
            $Process.HasExited
            $ProcessExitCode = $Process.ExitCode
            if (($ProcessExitCode -eq 0) -and ([string]::IsNullOrEmpty($Param))) {            
                [Log4Powershell]::WriteLog("S", "The process '$ProcessName' has executed successfully")                  
            }
            else {            
                [Log4Powershell]::WriteLog("E", "An error occurred trying to execute the process '$ProcessName' (exit code: $ProcessExitCode)!")                           
            }     
        }
        else {
            [Log4Powershell]::WriteLog("I", "Process parameters: $Param")
            $Process = Start-Process -FilePath $ProcessName -ArgumentList $Param -Wait -NoNewWindow -PassThru
            $Process.HasExited
            $ProcessExitCode = $Process.ExitCode
            if (($ProcessExitCode -eq 0) -and (-not([string]::IsNullOrEmpty($Param)))) {            
                [Log4Powershell]::WriteLog("S", "The process '$ProcessName' with parameters '$Param' has executed successfully")                      
            }
            else {            
                [Log4Powershell]::WriteLog("E", "An error occurred trying to execute the process '$ProcessName' with parameters '$Param' (exit code: $ProcessExitCode)!")                    
            }     
            
            [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")                
        }             
    }

    static [void]UniversalInstaller([string]$File, [string]$Params = "") {       
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")       

        $fileName = [System.IO.Path]::GetFileName($File)        
        $fileExt = [System.IO.Path]::GetExtension($fileName).Split(".")[1]
     
        [Log4Powershell]::WriteLog("I", "File name: $FileName")
        [Log4Powershell]::WriteLog("I", "File full path: $File")

        if (-not(Test-Path -Path $File)) {
            [Log4Powershell]::WriteLog("E", "The file '$File' does not exist!")
        }

        if (-not([string]::IsNullOrEmpty($Params))) {                 
           
            [Log4Powershell]::WriteLog("I", "Parameters: '$Params'")
        }

        [Log4Powershell]::WriteLog("-", "")
        [Log4Powershell]::WriteLog("I", "Start the installation")  
      
        switch ($fileExt) {
            "msi" {
                $defaultParams = "/i $File /qn /norestart"
                if ([string]::IsNullOrEmpty($Params)) {                      
                    $params = $defaultParams
                    [Log4Powershell]::WriteLog("I", "Starting installation using msiexec '$params'")
                    $process = Start-Process -FilePath 'msiexec' -ArgumentList $params -Wait -PassThru           
                }
                else {
                    $params = $defaultParams + " " + $params
                    [Log4Powershell]::WriteLog("I", "Starting installation using msiexec '$params'")
                    $process = Start-Process -FilePath 'msiexec' -ArgumentList $params -Wait -PassThru            
                }                   
        
                switch ($Process.ExitCode) {        
                    0 { 
                        [Log4Powershell]::WriteLog("S", "The software was installed successfully (exit code: 0)")                
                    }
                    1602 {
                        [Log4Powershell]::WriteLog("E", "User cancel the installation (exit code: 1602).") 
                    }
        
                    1603 { 
                        [Log4Powershell]::WriteLog("E", "A fatal error occurred (exit code: 1603)!")
                    }
                    1605 { 
                        [Log4Powershell]::WriteLog("I", "The software is not currently installed on this machine (exit code: 1605)!") 
                    }
                    1619 { 
                        [Log4Powershell]::WriteLog("E", "The installation files cannot be found. Verify that the package exists and that you can access it (exit code: 1619)!") 
                        Exit 1
                    }
                    3010 { 
                        [Log4Powershell]::WriteLog("W", "A reboot is required (exit code: 3010)!") 
                    }
                    default { 
                        [string]$ExitCode = $Process.ExitCode
                        [Log4Powershell]::WriteLog("E", "The installation ended in an error (exit code: $ExitCode)!")
                        Exit 1
                    }       
                }        
            }
            "exe" {
                $Process = Start-Process -FilePath $File -ArgumentList $params -Wait -NoNewWindow -PassThru
                $Process.HasExited
                $ProcessExitCode = $Process.ExitCode
                if ($ProcessExitCode -eq 0) {            
                    [Log4Powershell]::WriteLog("S", "The file '$fileName' has installed successfully with parameters '$params'.")                  
                }
                else {            
                    [Log4Powershell]::WriteLog("E", "An error occurred trying to install '$filename' (exit code: $ProcessExitCode)!")                           
                }   
            }
        }                        
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")   
    }     

    static [void]UniversalInstaller([string]$File) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")            
        $fileName = [System.IO.Path]::GetFileName($File)            
        [Log4Powershell]::WriteLog("I", "File name: $FileName")
        [Log4Powershell]::WriteLog("I", "File full path: $File")
  
        if (!(Test-Path -Path $File)) {
            [Log4Powershell]::WriteLog("E", "The file '$File' does not exist!")
        }               

        [Log4Powershell]::WriteLog("-", "")
        [Log4Powershell]::WriteLog("I", "Start the installation")  
          
        $Process = Start-Process -FilePath $File -Wait -NoNewWindow -PassThru
        $Process.HasExited
        $ProcessExitCode = $Process.ExitCode
        if ($ProcessExitCode -eq 0) {            
            [Log4Powershell]::WriteLog("S", "The program '$fileName' has installed successfully.")                  
        }
        else {            
            [Log4Powershell]::WriteLog("E", "An error occurred trying to install '$fileName' (exit code: $ProcessExitCode)!")                           
        }               
    }
}
    
class ServicesWorker {
    static [void]ChangeStartup([string]$ServiceName, [string]$StartupType) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Change the startup type of the service '$ServiceName' to '$StartupType'")
     
        If (Get-Service $ServiceName -erroraction silentlycontinue) {            
            try {
                Set-Service -Name $ServiceName -StartupType $StartupType | out-Null
                [Log4Powershell]::WriteLog("I", "The startup type of the service '$ServiceName' was successfully changed to '$StartupType'")
            }
            catch {
                [Log4Powershell]::WriteLog("I", "An error occurred trying to change the startup type of the service '$ServiceName' to '$StartupType' (error: $($Error[0]))!")
            }
        }
        else {
            [Log4Powershell]::WriteLog("I", "The service '$ServiceName' does not exist. Nothing to do")
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")            
    }

    static [void]HaltService([string]$ServiceName) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Stop service '$ServiceName' ...")       

        if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
            if (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                [Log4Powershell]::WriteLog("I", "Check for depend services for service '$ServiceName' and stop them")
               
                $DependServices = ((Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).DependentServices).name
                if ($DependServices.Count -gt 0) {
                    foreach ($Service in $DependServices) {
                        [Log4Powershell]::WriteLog("I", "Depend service found: $Service")
                        [ServicesWorker]::HaltService($Service)
                        #Stop-Service -Name $Service -Force -Confirm:$false | Out-Null
                        
                    }
                }
                else {
                    [Log4Powershell]::WriteLog("I", "No depend service found")
                } try {
                    Stop-Service -Name $ServiceName -Force -Confirm:$false | Out-Null
                }
                catch {
                    [Log4Powershell]::WriteLog("E", "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!")
                    Exit 1
                }
               
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Stopped" ) {
                    [Log4Powershell]::WriteLog("S", "The service $ServiceName was stopped successfully")
                }
                else {
                    [Log4Powershell]::WriteLog("E", "An error occurred trying to stop the service $ServiceName (error: $($Error[0]))!")
                    Exit 1
                }
            }
            else {
                [Log4Powershell]::WriteLog("I", "The service '$ServiceName' is not running")
            }
        }
        else {
            [Log4Powershell]::WriteLog("I", "The service '$ServiceName' does not exist. Nothing to do")
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")            
    }

    static [void]InitService([string]$ServiceName) {
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Start service '$ServiceName' ...")
        
        if (Get-Service $ServiceName -ErrorAction SilentlyContinue) {
            if (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                [Log4Powershell]::WriteLog("I", "The service $ServiceName is already running")        
            }
            else {
                [Log4Powershell]::WriteLog("I", "Check for depend services for service $ServiceName and start them")
                $DependServices = ((Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).DependentServices).name

                if ($DependServices.Count -gt 0) {
                    foreach ($Service in $DependServices) {
                        [Log4Powershell]::WriteLog("I", "Depend service found: $Service")
                        StartService($Service)
                    }
                }
                else { 
                    [Log4Powershell]::WriteLog("I", "No depend service found")                    
                }
                
                try {
                    Start-Service -Name $ServiceName -Force -Confirm:$false | Out-Null
                }
                catch {
                    [Log4Powershell]::WriteLog("E", "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!")                   
                    Exit 1
                }
               
                If (((Get-Service $ServiceName -ErrorAction SilentlyContinue).Status) -eq "Running" ) {
                    [Log4Powershell]::WriteLog("S", "The service $ServiceName was started successfully")                    
                }
                else {
                    [Log4Powershell]::WriteLog("E", "An error occurred trying to start the service $ServiceName (error: $($Error[0]))!")                    
                    Exit 1
                }
            }               
        }                       
        else {
            [Log4Powershell]::WriteLog("I", "The service '$ServiceName' does not exist. Nothing to do")           
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")            
    }    
}

class EffectsWorker {
    static [void]TypeStatic([Int32]$Delay, [string]$String) {   
        for ($i = 0; $i -lt $String.length; $i++) {
            if ($i % 2) {
                $c = "yellow"
            }
            elseif ($i % 5) {
                $c = "red"
            }
            elseif ($i % 7) {
                $c = "cyan"
            }
            else {
                $c = "white"
            }      
            Write-Host $String[$i] -NoNewline -ForegroundColor $c        
            Start-Sleep -Milliseconds $Delay
        }
        Write-Host
    }
}

class GeneralWorker {        
    static [void]ShortCut([string]$Filename, [string]$Params, [string]$Destination) {  
        $WshShell = New-Object -comObject WScript.Shell    
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Create Shortcut for '$Filename'")
     
        if ([string]::IsNullOrEmpty($Params)) {            
            try {              
                $Shortcut = $WshShell.CreateShortcut($Destination)
                $Shortcut.TargetPath = $Filename                    
                $Shortcut.Save()
                [Log4Powershell]::WriteLog("S", "Successfully created shortcut for '$Filename'")                
            }
            catch {
                [Log4Powershell]::WriteLog("E", $_.Exception.Message)                
            }    
        }
        else {
            try {                
                $Shortcut = $WshShell.CreateShortcut($Destination)
                $Shortcut.TargetPath = $Filename
                $Shortcut.Arguments = $Params
                $Shortcut.Save()
                [Log4Powershell]::WriteLog("S", "Successfully created shortcut for '$Filename'")               
            }
            catch {
                [Log4Powershell]::WriteLog("E", $_.Exception.Message)               
            }              
        }
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")           
    }    
    
}

class SoftWorker {       
    static [void]GetRevoPro() {        
        $url = "https://download.revouninstaller.com/download/RevoUninProSetup.exe"
        #$Directory = "$(Get-Location)Downloads"
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($url)
        [string]$FunctionName = $((Get-PSCallStack)[0].FunctionName)
        [Log4Powershell]::WriteLog("I", "START FUNCTION - $FunctionName")        
        [Log4Powershell]::WriteLog("I", "Deploying the file '$filename'")                  
        
        try {
            if (-not(Test-Path -Path $filename)) {
                             
            }
            else {         
                [Log4Powershell]::WriteLog("I", "The file '$filename' already exists. Deploying to machine.") 
                [TasksWorker]::UniversalInstaller($filename, "/VERYSILENT /NORESTART")
            }
            else {
                [Log4Powershell]::WriteLog("E", "The file '$filename' was not installed") 
                Exit 1
            }
        }       
        catch {
            [Log4Powershell]::WriteLog("E", "An error occurred trying to install the file $filename (exit code: $($Error[0]))!")                
            Exit 1       
        }        
        [Log4Powershell]::WriteLog("I", "END FUNCTION - $FunctionName")    
    }  

    [void]InstallCCleaner() {

    }

    [void]InstallIDM() {

    }

    [void]InstallPDFReader() {

    }

    [void]InstallFFmpeg() {

    }

}
