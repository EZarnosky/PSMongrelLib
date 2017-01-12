#https://gallery.technet.microsoft.com/scriptcenter/d9a309e6-e297-410d-aab1-b9b2105ae1bb
#Add-mlIISUser -Username "testuser" -Password "fabrikam"

function Add-mlIISUser  { 
    param(
        $Username,
        $Password
    ) 
 
    $Username = ($Username.Split("\")[1]) 
    $ADDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
    $ADDomainName = $ADDomain.Name 
    $ADServer = ($ADDomain.InfrastructureRoleOwner.Name.Split(".")[0]) 
    $FQDN = "DC=" + $ADDomain.Name -Replace("\.",",DC=") 
    $ADDomain = [ADSI] "LDAP://$ADServer/$FQDN" 
    $CustomerOU = "OU=Hosting,OU=Customers" 
    $CustomerOU = [ADSI] "LDAP://$CustomerOU,$FQDN" 
    $User = [ADSI] "LDAP://CN=$Username,$CustomerOU,$FQDN" 
    $PrincipalName = $Username + "@" + $ADDomainName 
    $AddADUser = $CustomerOU.Create("User","CN=$Username") 
    $AddADUser.Put("Description", "$Username") 
    $AddADUser.Put("sAMAccountName", "$Username") 
    $AddADUser.Put("userPrincipalName", "$PrincipalName") 
    $AddADUser.Put("DisplayName", "$Username") 
    $AddADUser.SetInfo() 
    $AddADUser.SetPassword($Password) 
    $AddADUser.SetInfo() 
    $AddADUser.Psbase.Invokeset("AccountDisabled", "False") 
    $AddADUser.SetInfo() 
    $AddADUser.Put("userAccountControl", "65536") 
    $AddADUser.SetInfo() 
    $DomainNC = ([ADSI]"LDAP://RootDSE").DefaultNamingContext 
    $DomainUsers = [ADSI]"LDAP://CN=Domain Users,CN=Users,$DomainNC" 
    $DomainUsers.GetInfoEx(@("primaryGroupToken"), 0) 
    $OldGroupToken = $DomainUsers.Get("primaryGroupToken") 
    $DomainGuests = [ADSI]"LDAP://CN=IIS_USERS,CN=Users,$DomainNC" 
    $DomainGuests.GetInfoEx(@("primaryGroupToken"), 0) 
    $NewGroupToken = $DomainGuests.Get("primaryGroupToken") 
    $DomainGuests.Add([String]($AddADUser.AdsPath)) 
    $AddADUser.Put("primaryGroupId", $NewGroupToken) 
    $AddADUser.SetInfo() 
    $DomainUsers.Remove([String]($AddADUser.AdsPath)) 
}
