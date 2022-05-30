if (Test-Path -Path "$PSScriptRoot\Downloads") {
  Get-ChildItem -Path "$PSScriptRoot\Downloads" -Recurse | Remove-Item -Force -Recurse
  Remove-Item -Path "$PSScriptRoot\Downloads" -Force
}

if (Test-Path -Path "$PSScriptRoot\Logs") {
  Get-ChildItem -Path "$PSScriptRoot\Logs" -Recurse | Remove-Item -Force -Recurse
  Remove-Item -Path "$PSScriptRoot\Logs" -Force
}

Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/aria2c.exe" -Destination "aria2c.exe"
Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/aria2c.conf" -Destination "aria2c.conf"
Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/7za.exe" -Destination "7za.exe"
Start-BitsTransfer -Source "https://github.com/Bedrame/AfterInstall/releases/download/1.0/Installer.psm1" -Destination "Installer.psm1"

Import-Module ".\Installer.psm1"

DS_CreateDirectory -Directory "$(Get-Location)\Downloads"
DS_CreateDirectory -Directory "$(Get-Location)\Logs"

$t = 
@"
#########################################################################################
                 __   _                     _____                 _             _   _ 
        /\      / _| | |                   |_   _|               | |           | | | |
       /  \    | |_  | |_    ___   _ __      | |    _ __    ___  | |_    __ _  | | | |
      / /\ \   |  _| | __|  / _ \ | '__|     | |   |  _ \  / __| | __|  / _  | | | | |
     / ____ \  | |   | |_  |  __/ | |       _| |_  | | | | \__ \ | |_  | (_| | | | | |
    /_/    \_\ |_|    \__|  \___| |_|      |_____| |_| |_| |___/  \__|  \____| |_| |_|

#########################################################################################  
"@

$menu = 
@"
`nPlease select an option:
1 - Modules Install
2 - Services Tweaking
3 - Enable .NET Framework 3.5
4 - Visual C++ Runtimes Install
5 - Streams Cleaner
6 - Essentials Programs Install
7 - NVIDIA Driver Install
8 - Ninite Online Install
9 - Update Windows 
10 - ML-1610 Printer Driver
11 - FFMpeg Install
12 - Encoding Video
13 - Laragon Install  
14 - Python Install  
15 - Youtube-DL GUI     
16 - StaxRip
17 - Kaspersky Free Install
0 - Exit`n
"@

Function Get-InstallMenu {       
  $MenuOption = $null
  While ($MenuOption -notin @(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 0)) {
    Clear-Host    
    Set-TypeStatic 0.05 $t
    Set-WriteColor $menu
    $MenuOption = Read-Host 'Select option'
    Write-Host ""
  
    Switch ($MenuOption.Trim()) {
      1 {
        Write-Host "Modules Install" -ForegroundColor Green 
        Get-Modules
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }      
      2 {  
        Write-Host "Services Tweaking" -ForegroundColor Green    
        Get-TweakWindows
        Write-Host ""
        Wait-Script
        $MenuOption = $null         
      }
      3 {
        Write-Host "Enable .NET Framework 3.5" -ForegroundColor Green
        Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3"
        Write-Host ""
        Wait-Script
        $MenuOption = $null 
      }
      4 {       
        Write-Host "Visual C++ Installer Runtimes" -ForegroundColor Green 
        Get-VisualRuntime
        Write-Host ""
        Wait-Script
        $MenuOption = $null 
      }      
      5 {         
        Write-Host "Streams Cleaner" -ForegroundColor Green        
        Get-StreamsSysInternals
        DS_ExecuteProcess -FileName "streams" -Arguments "-s -d"   
        Write-Host ""
        Wait-Script
        $MenuOption = $null           
      }      
      6 {                      
        DS_ExecuteProcess -FileName "streams" -Arguments "-s -d"   
        Write-Host "Download and install programs" -ForegroundColor Green       
        Get-RevoUninstaller        
        Get-LockHunter         
        Get-IDM 
        Get-WinRAR                 
        Get-Telegram         
        Get-JDK 
        Get-Unified      
        Get-Arduino                
        Get-Git
        Get-Teams        
        Get-GitHubCLI
        Get-LightShot          
        Get-DropBox       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      7 {       
        Write-Host "Install NVIDIA Drivers" -ForegroundColor Green
        Get-NVidia
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      8 {       
        Write-Host "Ninite Online Install" -ForegroundColor Green       
        Get-Ninite       
        Write-Host ""
        Wait-Script
        $MenuOption = $null                  
      }      
      9 {  
        Write-Host "Update Windows" -ForegroundColor Green 
        Get-Updates
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }      
      10 {        
        Write-Host "ML-1610 Printer Install" -ForegroundColor Green
        Get-PrinterDriver       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      11 {
        Write-Host "FFMPEG Install" -ForegroundColor Green
        Get-FFMpeg                
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      12 {
        Write-Host "Encoding Video" -ForegroundColor Green
        Get-ShanaEncoder       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      13 {
        Write-Host "Laragon Install" -ForegroundColor Green
        Get-Laragon       
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      14 {
        Write-Host "Python Install" -ForegroundColor Green
        Get-Python        
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      15 {
        Write-Host "Youtube-DL GUI" -ForegroundColor Green
        Get-ViviDL
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }
      16 {
        Write-Host "StaxRip" -ForegroundColor Green
        Get-StaxRip
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }     
      17 {
        Write-Host "Kaspersky Free Install" -ForegroundColor Green
        Get-KasperskyFree
        Write-Host ""
        Wait-Script
        $MenuOption = $null
      }     
      0 {
        Clear-Host 
        Get-ChildItem -Path "$PSScriptRoot\Downloads" -Recurse | Remove-Item -Force -Recurse
        Remove-Item -Path "$PSScriptRoot\Downloads" -Force       
        Get-ChildItem -Path "$PSScriptRoot\Logs" -Recurse | Remove-Item -Force -Recurse
        Remove-Item -Path "$PSScriptRoot\Logs" -Force            
        DS_DeleteFile -File "$PSScriptRoot\7za.exe"
        DS_DeleteFile -File "$PSScriptRoot\aria2c.exe"
        DS_DeleteFile -File "$PSScriptRoot\aria2c.conf"
        DS_DeleteFile -File "$PSScriptRoot\Installer.psm1"
        break
      }
      Default {
        Write-Host "Please enter a valid option.`n"
        Wait-Script
      }
    }
  }
}

Get-InstallMenu