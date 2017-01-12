<#
.SYNOPSIS
Retrieves the FSMO role holders from one or more Active Directory domains and forests.
.DESCRIPTION
Get-FSMORole uses the .NET Framework to determine which domain controller currently holds each
of the Active Directory FSMO roles. The Active Directory PowerShell module is not required.
.PARAMETER DomainName
One or more Active Directory domain names.
.EXAMPLE
Get-Content domainnames.txt | Get-FSMORole
.EXAMPLE
Get-FSMORole -DomainName domain1, domain2
#>
#http://mikefrobbins.com/2013/04/18/powershell-function-to-determine-the-active-directory-fsmo-role-holders-via-the-net-framework/
function Get-mlFSMORoles {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        [string[]]$DomainName = $env:USERDOMAIN
    )
    PROCESS {
        foreach ($domain in $DomainName) {
            Write-Verbose "Querying $domain"
            Try {
            $problem = $false
            $addomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain(
                (New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain', $domain)))
            } Catch { $problem = $true
                Write-Warning $_.Exception.Message
              }
            if (-not $problem) {
                $adforest = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest(
                    (New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Forest', (($addomain).forest))))
                New-Object PSObject -Property @{
                    InfrastructureMaster = $addomain.InfrastructureRoleOwner
                    PDCEmulator = $addomain.PdcRoleOwner
                    RIDMaster = $addomain.RidRoleOwner
                    DomainNamingMaster = $adforest.NamingRoleOwner
                    SchemaMaster = $adforest.SchemaRoleOwner
                }
            }
        }
    }
}
