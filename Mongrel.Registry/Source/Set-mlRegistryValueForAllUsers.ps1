<# 
.SYNOPSIS 
    This function uses Active Setup to create a "seeder" key which creates or modifies a user-based registry value 
    for all users on a computer. If the key path doesn't exist to the value, it will automatically create the key and add the value. 
.EXAMPLE 
    PS> Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'Setting'; 'Type' = 'String'; 'Value' = 'someval'; 'Path' = 'SOFTWARE\Microsoft\Windows\Something'} 
    This example would modify the string registry value 'Type' in the path 'SOFTWARE\Microsoft\Windows\Something' to 'someval' 
    for every user registry hive. 
.PARAMETER RegistryInstance 
     A hash table containing key names of 'Name' designating the registry value name, 'Type' to designate the type 
    of registry value which can be 'String,Binary,Dword,ExpandString or MultiString', 'Value' which is the value itself of the 
    registry value and 'Path' designating the parent registry key the registry value is in. 
#>
#https://gallery.technet.microsoft.com/scriptcenter/Easily-set-a-registry-b3449784
function Set-mlRegistryValueForAllUsers { 
    [CmdletBinding()]param ( 
        [Parameter(Mandatory=$true)] 
        [hashtable[]]$REGISTRYINSTANCE 
    )

    try { 
        New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null 
         
        ## Change the registry values for the currently logged on user. Each logged on user SID is under HKEY_USERS 
        $objLoggedOnSids = (Get-ChildItem HKU: | where { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName 
        Write-Verbose "Found $($objLoggedOnSids.Count) logged on user SIDs" 

        foreach ($itmSid in $objLoggedOnSids) { 
            Write-Verbose -Message "Loading the user registry hive for the logged on SID $itmSid" 

            foreach ($itmIinstance in $REGISTRYINSTANCE) { 
                ## Create the key path if it doesn't exist 
                New-Item -Path "HKU:\$itmSid\$($itmIinstance.Path | Split-Path -Parent)" -Name ($itmIinstance.Path | Split-Path -Leaf) -Force | Out-Null 

                ## Create (or modify) the value specified in the param 
                Set-ItemProperty -Path "HKU:\$itmSid\$($itmIinstance.Path)" -Name $itmIinstance.Name -Value $itmIinstance.Value -Type $itmIinstance.Type -Force 
            } 
        } 
         
        ## Create the Active Setup registry key so that the reg add cmd will get ran for each user 
        ## logging into the machine. 
        ## http://www.itninja.com/blog/view/an-active-setup-primer 
        Write-Verbose "Setting Active Setup registry value to apply to all other users" 

        foreach ($itmIinstance in $REGISTRYINSTANCE) { 
            ## Generate a unique value (usually a GUID) to use for Active Setup 
            $objGuid = [guid]::NewGuid().Guid 
            $strActiveSetupRegParentPath = 'HKLM:\Software\Microsoft\Active Setup\Installed Components' 

            ## Create the GUID registry key under the Active Setup key 
            New-Item -Path $strActiveSetupRegParentPath -Name $objGuid -Force | Out-Null 
            $strActiveSetupRegPath = "HKLM:\Software\Microsoft\Active Setup\Installed Components\$objGuid" 
            Write-Verbose "Using registry path '$strActiveSetupRegPath'" 
             
            ## Convert the registry value type to one that reg.exe can understand.  This will be the 
            ## type of value that's created for the value we want to set for all users 
            switch ($itmIinstance.Type) { 
                'String' { $strRegValueType = 'REG_SZ' } 
                'Dword' { $strRegValueType = 'REG_DWORD' } 
                'Binary' { $strRegValueType = 'REG_BINARY' } 
                'ExpandString' { $strRegValueType = 'REG_EXPAND_SZ' } 
                'MultiString' { $strRegValueType = 'REG_MULTI_SZ' } 
                default { throw "Registry type '$($itmIinstance.Type)' not recognized" } 
            } 
             
            ## Build the registry value to use for Active Setup which is the command to create the registry value in all user hives 
            $strActiveSetupValue = "reg add `"{0}`" /v {1} /t {2} /d {3} /f" -f "HKCU\$($itmIinstance.Path)", $itmIinstance.Name, $strRegValueType, $itmIinstance.Value 
            Write-Verbose -Message "Active setup value is '$strActiveSetupValue'" 

            ## Create the necessary Active Setup registry values 
            Set-ItemProperty -Path $strActiveSetupRegPath -Name '(Default)' -Value 'Active Setup Test' -Force 
            Set-ItemProperty -Path $strActiveSetupRegPath -Name 'Version' -Value '1' -Force 
            Set-ItemProperty -Path $strActiveSetupRegPath -Name 'StubPath' -Value $strActiveSetupValue -Force 
        } 
    }
    
    catch { Write-Warning -Message $_.Exception.Message } 
}
