configuration WindowsDevVM {
    param
    (
        [Parameter(Mandatory)]
        [String]$MachineName,

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
    }
}