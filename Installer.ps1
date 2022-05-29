param(
  [Parameter(Mandatory = $false)]
  [switch]$shouldAssumeToBeElevated,

  [Parameter(Mandatory = $false)]
  [String]$workingDirOverride
)

if (-not($PSBoundParameters.ContainsKey('workingDirOverride'))) {
  $workingDirOverride = (Get-Location).Path
}

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false) {
  if ($shouldAssumeToBeElevated) {
    Write-Output "Elevating did not work :("
  }
  else {
    Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -shouldAssumeToBeElevated -workingDirOverride "{1}"' -f ($myinvocation.MyCommand.Definition, "$workingDirOverride"))
  }
  exit
}

Set-Location "$workingDirOverride"

Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/aria2c.exe" -Destination "aria2c.exe"
Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/aria2c.conf" -Destination "aria2c.conf"
Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/7za.exe" -Destination "7za.exe"
Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/Installer.psm1" -Destination "Installer.psm1"

Import-Module ".\Installer.psm1"

DS_CreateDirectory -Directory "$(Get-Location)\Downloads"
DS_CreateDirectory -Directory "$(Get-Location)\Logs"
Function Get-InstallMenu {       
  $MenuOption = $null
  While ($MenuOption -notin @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 0)) {
    Clear-Host
    Write-Host "================================================================================"
    Write-Host "                    Post Installation" -ForegroundColor "Yellow"
    Write-Host "================================================================================"
    Write-Host "`nPlease select an option:" -ForegroundColor "Yellow"
    Write-Host "  1 - Modules Install" -ForegroundColor "Green"
    Write-Host "  2 - TPM Check on Dynamic Update"  -ForegroundColor "Green"
    Write-Host "  3 - Services Tweaking" -ForegroundColor "Green"
    Write-Host "  4 - Enable .NET Framework 3.5" -ForegroundColor "Green"
    Write-Host "  5 - Visual C++ Runtimes Install" -ForegroundColor "Green"
    Write-Host "  6 - Streams Cleaner" -ForegroundColor "Green"
    Write-Host "  7 - Essentials Programs Install" -ForegroundColor "Green"
    Write-Host "  8 - NVIDIA Driver Install" -ForegroundColor "Green"
    Write-Host "  9 - Ninite Online Install" -ForegroundColor "Green"
    Write-Host "  10 - Update Powershell Help" -ForegroundColor "Green"
    Write-Host "  11 - Update Windows and Reboot" -ForegroundColor "Green"
    Write-Host "  12 - Configure git and SSH" -ForegroundColor "Green"
    Write-Host "  13 - ML-1610 Printer Driver" -ForegroundColor "Green"
    Write-Host "  14 - FFMpeg Install" -ForegroundColor "Green"
    Write-Host "  15 - Encoding Video" -ForegroundColor "Green"
    Write-Host "  16 - Laragon Install" -ForegroundColor "Green"  
    Write-Host "  17 - Python Install" -ForegroundColor "Green"   
    Write-Host "  18 - Youtube-DL GUI" -ForegroundColor "Green"    
    Write-Host "  19 - StaxRip" -ForegroundColor "Green"
    Write-Host "  20 - Delete all" -ForegroundColor "Green"
    Write-Host "`n  0 - Exit`n" -ForegroundColor "Yellow"
    $MenuOption = Read-Host 'Select option'
    Write-Host ""
  
    Switch ($MenuOption.Trim()) {
      1 {
        Write-Host "Modules Install" 
        Get-Modules
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      2 {        
        Disable-TPM
        Write-Host ""
        Wait-Script
        $MenuOption = $null                     
      }
      3 {  
        Write-Host "Services Tweaking" -ForegroundColor DarkCyan    
        Get-TweakWindows
        Write-Host ""
        Wait-Script
        $MenuOption = $null         
      }
      4 {
        Write-Host "Enable .NET Framework 3.5"
        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"
        Write-Host ""
        Wait-Script
        $MenuOption = $null 
      }
      5 {       
        Write-Host "Visual C++ Installer Runtimes" 
        Get-VisualRuntime
        Write-Host ""
        Wait-Script
        $MenuOption = $null 
      }      
      6 {         
        $streams = "Streams.zip"   
        $streamFolder = "$PSScriptRoot\stream"      
        Write-Host "Clear NTFS Streams" -ForegroundColor Green       
        if (Test-Path $streamFolder) {
          Write-Host "Folder exists" -ForegroundColor DarkRed
        }
        else {
          New-Item $streamfolder -ItemType Directory
          Write-Host "Folder $streamfolder created successfully" -ForegroundColor Green
        }      
        if (-not(Test-Path -Path $streams -PathType Leaf)) {    
          try {         
            $null = Start-BitsTransfer -Source "https://download.sysinternals.com/files/Streams.zip" -Destination $streamFolder -TransferType Download
            Write-Host "The file $streams has been downloaded." -ForegroundColor Green
            Expand-Archive -Path "$streamFolder\$streams" -DestinationPath $streamFolder -Force -Confirm:$false 
            Remove-Item "$streamFolder\streams.exe" -Force -Recurse -Confirm:$false
            Remove-Item "$streamFolder\streams64a.exe" -Force -Recurse -Confirm:$false
            Remove-Item "$streamFolder\Eula.txt" -Force -Recurse -Confirm:$false
            Rename-Item -Path "$streamFolder\streams64.exe" -NewName "$streamFolder\streams.exe" 
            Copy-Item -Path "$streamFolder\streams.exe" $env:windir
            Write-Host "Done" -ForegroundColor DarkCyan
          }
          catch {
            throw $_.Exception.Message
          }
        }
        else {
          Write-Host "Cannot download because a file with that name already exists." -ForegroundColor DarkRed
        }      
        DS_ExecuteProcess -FileName "streams" -Arguments "-s -d"   
        Write-Host ""
        Wait-Script
        $MenuOption = $null           
      }      
      7 {                      
        DS_ExecuteProcess -FileName "streams" -Arguments "-s -d"   
        Write-Host "Download and install programs" -ForegroundColor Green           
        Get-RevoUninstaller  
        Get-LockHunter 
        Get-IDM 
        Get-WinRAR
        Get-DropBox            
        Get-Telegram 
        Get-LightShot 
        Get-JDK 
        Get-Unified      
        Get-Arduino
        Get-DiagBB
        Get-GPBCEF
        Get-Git
        Get-Teams        
        Get-GitHubCLI       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      8 {       
        Write-Host "Install NVIDIA Drivers" -ForegroundColor DarkYellow
        Get-NVidia
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      9 {       
        Write-Host "Execute Ninite Online Installer" -ForegroundColor DarkYellow        
        Get-Ninite       
        Write-Host ""
        Wait-Script
        $MenuOption = $null                  
      }
      10 {  
        Write-Host "Update powershell help" -ForegroundColor Green        
        Get-UpdatePowershell
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      11 {  
        Write-Host "Update Windows" -ForegroundColor Green
        Get-Updates
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      12 {  
        Write-Host "Git Configure" -ForegroundColor Green
        Set-ConfigGit
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }      
      13 {        
        Write-Host "ML-1610 Printer Install" -ForegroundColor Green
        Get-PrinterDriver       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      14 {
        Write-Host "FFMPEG Install" -ForegroundColor DarkCyan
        Get-FFMpeg                
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      15 {
        Write-Host "Encoding Video" -ForegroundColor Green
        Get-ShanaEncoder       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      16 {
        Write-host "Laragon Install" -ForegroundColor Green
        Get-Laragon       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      17 {
        Write-host "Python Install" -ForegroundColor Green
        Get-Python
        Get-UpdatePIP
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      18 {
        Write-host "Youtube-DL GUI" -ForegroundColor Green
        Get-ViviDL
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      19 {
        Write-host "StaxRip" -ForegroundColor Green
        Get-StaxRip
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      20 {
        Write-host "Delete all" -ForegroundColor Green
        DS_DeleteDirectory -Directory "$(Get-Location)\Downloads"
        DS_DeleteDirectory -Directory "$(Get-Location)\Logs"      
        DS_DeleteFile -File "$PSScriptRoot\7za.exe"
        DS_DeleteFile -File "$PSScriptRoot\aria2c.exe"
        DS_DeleteFile -File "$PSScriptRoot\aria2c.conf"
        DS_DeleteFile -File "$PSScriptRoot\Installer.psm1"
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      0 {
        Clear-Host        
        break
      }
      Default {
        Write-Host "Please enter a valid option.`n" -ForegroundColor "Red"
        Wait-Script
      }
    }
  }
}

Get-InstallMenu