Start-Transcript -path "C:\MachinePrep\logs\log.txt"

try {
    # Install RSAT Tools
    Write-Host "Installing RSAT Tools..."
    Install-WindowsFeature -IncludeAllSubFeature RSAT
}
catch {
    "Unable to install RSAT Tools"
}

try {

    # Install nuget package manager
    Write-Host "Instaling nuget..."
    Install-PackageProvider -Name Nuget -Force 

    # Install Azure CLI
    Write-Host "Downloading Azure CLI..."
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

    # Install Azure PowerShell
    Write-Host "Installing Azure CLI..."
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

catch {
    "Unable to install Azure CLI"
}

try {
    # Download SMSS
    Write-Host "Downloading SMSS..."
    New-Item -ItemType directory -Path C:\MachinePrep\files
    $url = "https://aka.ms/ssmsfullsetup"
    $destination = "C:\MachinePrep\files\smss.exe"
    Invoke-WebRequest -Uri $url -OutFile $destination

    # Install SMSS
    Write-Host "Installing SMSS..."
    $params = " /Install /Quiet /Norestart /Logs C:\MachinePrep\logs\smss_install.log"
    $params_formatted = $params.Split(" ")
    & "$destination" $params_formatted | Out-Null
}
catch {
    "Unable to install SMSS"
}

Stop-Transcript 
