function Get-mlCurrentDomainDetails {
    [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
}
