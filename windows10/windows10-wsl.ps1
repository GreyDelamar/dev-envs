# TODO FIND A BETTER WAY TO CHECK IF WSL IS INSTALL AND WORKING
function runWslInstall {
    try
    {
        wsl --status | Out-Null
        Write-Information "WSL is already installed"
    }
    catch [System.Management.Automation.CommandNotFoundException]
    {
       try
        {
            installWSL
            wsl --status | Out-Null
            Write-Information "WSL is installed"
        }
        catch [System.Management.Automation.CommandNotFoundException]
        {
            Write-Information "WSL did not install successfully"
            exit
        }
    }
}

function installWSL {
    Write-Information "Installing WSL"

    wsl --install -d "Ubuntu-18.04"
    
    Write-Information "Finished Installing WSL"
    
    Write-Information "PLEASE REBOOT NOW"

    exit
}
