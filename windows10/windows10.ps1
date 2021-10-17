#Run with PowerShell.exe -ExecutionPolicy Bypass -File .\windows10.ps1
# ARG OPTIONS
#   -verbose      (true/false) [Default: false]
#   -showProgress (true/false) [Default: false]
#   -wsl          (true/false) [Default: false]

param ($verbose, $showProgress, $wsl)

# Hide progress bars to speed up the downloading
if (($showProgress -ne "True") -or ($showProgress -ne "true")) {
    $ProgressPreference = 'SilentlyContinue'
}

# Extra Logs
if (($verbose -eq "True") -or ($verbose -eq "true")) {
    $VerbosePreference = 'Continue'
}

# Simple logs
$InformationPreference = 'Continue'



# Refresh path for powershell so you don't need to reopen it
function RefreshEnvPath
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") `
                + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Start with a refresh 
RefreshEnvPath

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#    _____ _____ _______
#   / ____|_   _|__   __|
#  | |  __  | |    | |
#  | | |_ | | |    | |
#  | |__| |_| |_   | |
#   \_____|_____|  |_|
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function downloadGit
{
    Write-Information "Downloading latest version of git"

    # Look for the OS Architecture
    if ((Get-CimInstance CIM_OperatingSystem).OSArchitecture -eq "64-bit")
    {
        $osArch = "*64-bit.exe"
    }
    else
    {
        $osArch = "*32-bit.exe"
    }

    $git_url = "https://api.github.com/repos/git-for-windows/git/releases/latest"

    # Get the latest version and correct os arch file name
    $asset = Invoke-RestMethod -Method Get -Uri $git_url | ForEach-Object assets | Where-Object name -like $osArch

    # Download to the temp folder
    $installerPath = "$env:temp\$($asset.name)"

    # download installer
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $installerPath

    Write-Information "Finished downloading latest version of git $($asset.name)"

    return $installerPath
}

function installGit {
    param (
        $installerPath
    )

    Write-Information "Installing Git"

    # Run git installer and wait for it to finish
    # Silent Install https://github.com/git-for-windows/git/wiki/Silent-or-Unattended-Installation
    Start-Process -FilePath $installerPath -Wait
    RefreshEnvPath

    Write-Information "Finished Installing Git"
}

try
{
    git | Out-Null
    Write-Information "Git is already installed - current $(git version)"
}
catch [System.Management.Automation.CommandNotFoundException]
{
   try
    {
        $gitInstallerPath = downloadGit
        installGit -installerPath $gitInstallerPath
        git | Out-Null
        Write-Information "Git is installed"
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Information "Git did not install successfully"
        exit
    }
}



# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#  __      _______    _____ ____  _____  ______
#  \ \    / / ____|  / ____/ __ \|  __ \|  ____|
#   \ \  / / (___   | |   | |  | | |  | | |__
#    \ \/ / \___ \  | |   | |  | | |  | |  __|
#     \  /  ____) | | |___| |__| | |__| | |____
#      \/  |_____/   \_____\____/|_____/|______|
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function downloadVsCode {
    Write-Information "Downloading latest version of VS Code"

    # Look for the OS Architecture
    if ((Get-CimInstance CIM_OperatingSystem).OSArchitecture -eq "64-bit")
    {
        $osArch = "win32-x64-user"
    }
    else
    {
        $osArch = "win32-user"
    }

    $vscodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=$osArch";

    $installerPath = "$env:temp\vscode-installer.exe"

    Invoke-WebRequest -Uri $vscodeUrl -OutFile $installerPath

    Write-Information "Finished downloading latest version of VS Code"

    return $installerPath
}

function installVsCode {
    param (
        $installerPath
    )

    Write-Information "Installing Vs Code"

    # Run Vs Code installer and wait for it to finish
    # Silent Install https://github.com/git-for-windows/git/wiki/Silent-or-Unattended-Installation
    Start-Process -FilePath $installerPath -Wait
    RefreshEnvPath

    Write-Information "Finished Installing Vscode"
}

try
{
    code --version | Out-Null
    Write-Information "VS Code is already installed - current $(code --version | Select-Object -First 1)"
}
catch [System.Management.Automation.CommandNotFoundException]
{
   try
    {
        $vsCodeInstallerPath = downloadVsCode
        installVsCode -installerPath $vsCodeInstallerPath
        code --version | Out-Null
        Write-Information "VS Code is installed"
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Information "VS Code did not install successfully"
        exit
    }
}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#  __          _______ _      
#  \ \        / / ____| |     
#   \ \  /\  / / (___ | |     
#    \ \/  \/ / \___ \| |     
#     \  /\  /  ____) | |____ 
#      \/  \/  |_____/|______|
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# wsl --list --online (will list out the options you have)
# IDEA: Could add a param so the user can specify the distro they want
# ISSUE HOW TO RESUME AFTER A REBOOT
# Common issue: "The virtual machine could not be started because a required feature is not installed." Check if virtualization is enabled in bios
if (($wsl -eq "True") -or ($wsl -eq "true")) {
    Import-Module -Name ./windows10-wsl.ps1 
    runWslInstall
    wsl bash -c "./windows10-wsl-ubuntu.sh && exit"
}
    

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   _   _  ____  _____  ______       _  _____
#  | \ | |/ __ \|  __ \|  ____|     | |/ ____|
#  |  \| | |  | | |  | | |__        | | (___
#  | . ` | |  | | |  | |  __|   _   | |\___ \
#  | |\  | |__| | |__| | |____ | |__| |____) |
#  |_| \_|\____/|_____/|______(_)____/|_____/
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function downloadNVM {
    Write-Information "Downloading latest version of NVM"

    $nvmUrl = "https://github.com/coreybutler/nvm-windows/releases/latest/download/nvm-setup.zip";
    
    $installerPath = "$env:temp\nvm.zip"

    Invoke-WebRequest -Uri $nvmUrl -OutFile $installerPath

    Expand-Archive $installerPath -DestinationPath "$env:temp\nvm" -Force
    
    $installerPath = "$env:temp\nvm\nvm-setup.exe"

    Write-Information "Finished downloading latest version of NVM"

    return $installerPath
}

function InstallNVM {
    param (
        $installerPath
    )

    Write-Information "Installing NVM"

    # Run git installer and wait for it to finish
    Start-Process -FilePath $installerPath -Wait

    # Make NVM avalible in current terminal (Probably should get a better way to do this)
    $env:NVM_HOME = "$env:appdata\nvm"
    $env:NVM_SYMLINK = "C:\Program Files\nodejs"
    
    RefreshEnvPath

    nvm install lts
    nvm use lts

    Write-Information "Finished Installing NVM"
}

if (($wsl -ne "True") -or ($wsl -ne "true")) {
    try
    {
        nvm --version | Out-Null
        Write-Information "Node is already installed - current $(node --version)"
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        try
        {
            # $NVMinstallerPath = downloadNVM
            # InstallNVM -installerPath $NVMinstallerPath
            nvm --version | Out-Null
            Write-Information "Node is installed"
        }
        catch [System.Management.Automation.CommandNotFoundException]
        {
            Write-Information "Node did not install successfully"
            exit
        }
    }
}

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#    _____  ____  
#   / ____|/ __ \ 
#  | |  __| |  | |
#  | | |_ | |  | |
#  | |__| | |__| |
#   \_____|\____/ 
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-     

function downloadGo {
    Write-Information "Downloading latest version of GO"
    
    $installerPath = "$env:temp\nvm.zip"

    $currentVesion = Invoke-WebRequest -Uri "https://golang.org/VERSION?m=text"| Select-Object -Expand Content

    $downloadUri = "https://golang.org/dl/$currentVesion.windows-amd64.msi"
    
    $installerPath = "$env:temp\$currentVesion.windows-amd64.msi"

    Invoke-WebRequest -Uri $downloadUri -OutFile $installerPath

    Write-Information "Finished downloading latest version of GO"

    return $installerPath
}

function installGo {
    param (
        $installerPath
    )

    Write-Information "Installing Go"

    # Run go installer and wait for it to finish
    Start-Process -FilePath $installerPath -Wait
    RefreshEnvPath

    Write-Information "Finished Installing Go"
}

try
{
    go version | Out-Null
    Write-Information "Go is already installed - current $(go version)"
}
catch [System.Management.Automation.CommandNotFoundException]
{
   try
    {
        $goInstallerPath = downloadGo
        installGo -installerPath $goInstallerPath
        Write-Information "$env:Path"
        go version | Out-Null
        Write-Information "Go is installed"
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
        Write-Information "Go did not install successfully"
        exit
    }
}



# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#   ______ _ _        ______            _
#  |  ____(_) |      |  ____|          | |
#  | |__   _| | ___  | |__  __  ___ __ | | ___  _ __ ___ _ __
#  |  __| | | |/ _ \ |  __| \ \/ / '_ \| |/ _ \| '__/ _ \ '__|
#  | |    | | |  __/ | |____ >  <| |_) | | (_) | | |  __/ |
#  |_|    |_|_|\___| |______/_/\_\ .__/|_|\___/|_|  \___|_|
#                                | |
#                                |_|
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#  This needs to be at the end since we have to force restart the explorer

$key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

if (((Get-ItemPropertyValue $key HideFileExt) -eq 1) -or ((Get-ItemPropertyValue $key Hidden) -eq 0)) {
    Write-Information "Setting file explorer defaults"
        
    # Show file extensions
    Set-ItemProperty $key HideFileExt 0
    
    # Show hidden files
    Set-ItemProperty $key Hidden 1
    
    # Force Windows Explorer restart so settings take effect
    Stop-Process -processName explorer
    
    Write-Information "Finished setting file explorer defaults"
} else {
    Write-Information "File explorer defaults already set"
}


Write-Information "Reload Powershell"