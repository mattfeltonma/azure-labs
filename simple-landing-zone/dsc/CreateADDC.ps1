configuration CreateADDC {
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [String]$NetBiosName = $DomainName,
        
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    )

    Import-DscResource -ModuleName xActiveDirectory, xStorage, xNetworking, PSDesiredStateConfiguration, xPendingReboot
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        Script EnableDNSDiags
        {
            SetScript = {
                Set-DnsServerDiagnostics -All $true
                Write-Verbose -Verbose "Enabling DNS client diagnostics"
            }
            GetScript = { @{} }
            TestScript = { $false }
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature DnsTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        xWaitforDisk Disk2 
        {
            DiskId = 2
            DiskIdType = "Number"
            RetryIntervalSec = $RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk ADDataDisk 
        {
            DiskId = 2
            DiskIdType = "Number"
            DriveLetter= "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            DependsOn="[WindowsFeature]DNS"
        }

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSTools"
        }

        xADDomain FirstDS
        {
            DomainName = $DomainName
            DomainNetBiosName = $NetBiosName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
            DependsOn = @("[WindowsFeature]ADDSInstall", "[xDisk]ADDataDisk")
        }

        xADOrganizationalUnit 'TopLevel'
        {
            Ensure = 'Present'
            Name = $NetBiosName
            Path = ('DC={0},DC={1}' -f ($DomainName -split '\.')[0], ($DomainName -split '\.')[1])
            DependsOn = "[xADDomain]FirstDS"
        }

        @($ConfigurationData.NonNodeData.OrganizationalUnits).foreach( {
            xADOrganizationalUnit $_
            {
                Ensure = 'Present'
                Name = $_
                Path = ('OU={0},DC={1},DC={2}' -f $NetBiosName, ($DomainName -split '\.')[0], ($DomainName -split '\.')[1])
                DependsOn = "[xADDomain]FirstDS"
            }
        })

        @($ConfigurationData.NonNodeData.ADUsers).foreach( {
            xADUser "$($_.FirstName) $($_.LastName)"
            {
                Ensure = 'Present'
                DomainName = $DomainName
                GivenName = $_.FirstName
                SurName = $_.LastName
                UserName = $_.UserName
                UserPrincipalName = '{0}@{1}' -f $_.UserName, $DomainName
                Department = $_.Department
                JobTitle = $_.Title
                Office = $_.Office
                OfficePhone = $_.OfficePhone
                Path = ('OU=Employees,OU={0},DC={1},DC={2}' -f $NetBiosName, ($DomainName -split '\.')[0], ($DomainName -split '\.')[1])
                EmployeeID = $_.EmployeeID
                EmailAddress = $_.EmailAddress
                Password = $DomainCreds
                ChangePasswordAtLogon = $false
                PasswordNeverExpires = $true
                DependsOn = "[xADDomain]FirstDS"
            }
        })

        @($ConfigurationData.NonNodeData.ADGroups).foreach( {
            xADGroup "$($_.GroupName)"
            {
                Ensure = 'Present'
                GroupName = $_.GroupName
                GroupScope = $_.GroupScope
                Category = $_.GroupCategory
                Description = $_.Description
                Members = $_.Members
                Path = ('OU=Groups,OU={0},DC={1},DC={2}' -f $NetBiosName, ($DomainName -split '\.')[0], ($DomainName -split '\.')[1])
                DependsOn = "[xADDomain]FirstDS"
            }
        })

        xPendingReboot RebootAfterPromotion
        {
            Name = "RebootAfterPromotion"
            DependsOn = "[xADDomain]FirstDS"
        }
    }
} 
