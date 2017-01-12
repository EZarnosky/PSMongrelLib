# Prints out the values of the DomainMode Enum   
# Thomas Lee - tfl@psp.co.uk   

function Get-mlDomainModeEnumValues {
# Enumerate System.DirectoryServices.ActiveDirectory.DomainMode

  $enums=[enum]::GetValues([System.DirectoryServices.ActiveDirectory.DomainMode])

  # Display values
  "System.Net.DirectoryServices.ActiveDirectory.DomainMode enum has {0} possible values:" -f $enums.count
  $i=1
  $enums | %{"Value {0}: {1}" -f $i,$_.tostring();$i++}
  ""

  # Checking against an enum value
  $ToCheck = "Windows2003Domain"
  if ($ToCheck -eq  [System.DirectoryServices.ActiveDirectory.DomainMode]::Windows2008Domain) {
    "`$ToCheck is Windows2003Domain"   
  }
  else {
    "`$ToCheck is NOT Windows2003Domain"
  }
}
[System.DirectoryServices.ActiveDirectory.DomainMode]::Windows2012R2Domain
