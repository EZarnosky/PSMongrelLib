function Get-mlCurrentDomain {
    [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
}
