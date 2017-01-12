#Requires -Modules GroupPolicy
#http://mikefrobbins.com/2016/01/07/building-logic-into-powershell-functions-to-nag-users-before-their-active-directory-password-expires/
function Get-mlMaximumPasswordAge {
    [CmdletBinding()]param(
        [ValidateNotNullOrEmpty()][string]$GPOName = 'Default Domain Policy'
    )

    (([xml](Get-GPOReport -Name $GPOName -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
    Where-Object name -eq MaximumPasswordAge).SettingNumber
}
