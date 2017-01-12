#Requires -Modules ActiveDirectory
#http://mikefrobbins.com/2016/01/07/building-logic-into-powershell-functions-to-nag-users-before-their-active-directory-password-expires/
function Search-mlADAccountPasswordExpiration {
    [CmdletBinding()]param(
        [ValidateNotNullOrEmpty()][int]$Days = 14,
        [ValidateNotNullOrEmpty()][int]$MaximumPasswordAge = 90,
        [ValidateNotNullOrEmpty()][string]$SearchBase = 'OU=Test Users,OU=Users,DC=mikefrobbins,DC=com'
    )
    [datetime]$CutoffDate = (Get-Date).AddDays(-($MaximumPasswordAge - $Days))
 
    Get-ADUser -Filter {
        Enabled -eq $true -and PasswordNeverExpires -eq $false -and PasswordLastSet -lt $CutoffDate
    } -Properties PasswordExpired, PasswordNeverExpires, PasswordLastSet, Mail -SearchBase $SearchBase |
    Where-Object PasswordExpired -eq $false |
 
    Select-Object -Property Name, SamAccountName, Mail, PasswordLastSet, @{label='PasswordExpiresOn';expression={$($_.PasswordLastSet).AddDays($MaximumPasswordAge)}}
}
