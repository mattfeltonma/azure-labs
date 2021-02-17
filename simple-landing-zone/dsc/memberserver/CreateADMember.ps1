configuration CreateADMember {
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [String]$NetBiosName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory=$false)]
        [string]$SystemTimeZone = "Eastern Standard Time",

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    )

    Import-DscResource -ModuleName xStorage, xNetworking, ComputerManagementDsc, PSDesiredStateConfiguration
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    $Interface = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1
    $InterfaceAlias = $($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        TimeZone TimeZoneSet
        {
            IsSingleinstance = 'Yes'
            TimeZone = $SystemTimeZone
        }

        IEEnhancedSecurityConfiguration 'DisableForAdministrators'
        {
            Role = 'Administrators'
            Enabled = $false
        }

        IEEnhancedSecurityConfiguration 'DisableForUsers'
        {
            Role    = 'Users'
            Enabled = $false
        }

        xWaitforDisk Disk2 
        {
            DiskId = 2
            DiskIdType = "Number"
            RetryIntervalSec = $RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk DataDisk 
        {
            DiskId = 2
            DiskIdType = "Number"
            DriveLetter= "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        Computer JoinToDomain
        {
            DomainName = $DomainName
            JoinOU = ('OU={0},OU={1},DC={2},DC={3}' -f 'Servers', $NetBiosName, ($DomainName -split '\.')[0], ($DomainName -split '\.')[1])
            Credential = $DomainCreds
        }

        PendingReboot RebootAfterPromotion
        {
            Name = "RebootAfterDomainJoin"
            DependsOn = "[Computer]JoinToDomain"
        }
    }
} 
