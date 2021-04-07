# Install RSAT Tools
Install-WindowsFeature -IncludeAllSubFeature RSAT

# Download SMSS
Start-Transcript -path "C:\MachinePrep\logs\log.txt"
$url = "https://aka.ms/ssmsfullsetup"
$destination = "C:\MachinePrep\files\smss.exe"
Invoke-WebRequest -Uri $url -OutFile $destination

# Install SMSS
$params = " /Install /Quiet /Norestart /Logs C:\MachinePrep\logs\smss_install.log"
$params_formatted = $params.Split(" ")
& "$destination" $params_formatted | Out-Null

# Install Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi

# Install Azure PowerShell
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Stop-Transcript