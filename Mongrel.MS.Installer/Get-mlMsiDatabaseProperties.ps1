<#
.SYNOPSIS
    This function retrieves properties from a Windows Installer MSI database.
.DESCRIPTION
    This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI
.EXAMPLE
    Get-mlMsiDatabaseProperties 'MSI_PATH'
.PARAMETER FilePath
    The path to the MSI you'd like to query
#>
#https://gallery.technet.microsoft.com/scriptcenter/Get-MsiDatabaseProperties-09d9c87c
function Get-mlMsiDatabaseProperties () { 
    [CmdletBinding()]param ( 
    [Parameter(Mandatory=$True, 
        ValueFromPipeline=$True, 
        ValueFromPipelineByPropertyName=$True, 
        HelpMessage='What is the path of the MSI you would like to query?')][IO.FileInfo[]]$FILEPATH 
    )

    BEGIN {
        $objWindowsInstaller = New-Object -com WindowsInstaller.Installer 
    } 
 
    PROCESS { 
            TRY { 
                $objDatabase = $objWindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $objWindowsInstaller, @($FILEPATH.FullName, 0))
 
                $txtQuery = "SELECT * FROM Property"
                $objView = $objDatabase.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $objDatabase, ($txtQuery))

                $objView.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $objView, $Null)
 
                $objRecord = $objView.GetType().InvokeMember("Fetch", "InvokeMethod", $Null, $objView, $Null)
 
                $hshMsiProperties = @{}

                while ($objRecord -ne $null) {
                    $prop_name = $objRecord.GetType().InvokeMember("StringData", "GetProperty", $Null, $objRecord, 1)
                    $prop_value = $objRecord.GetType().InvokeMember("StringData", "GetProperty", $Null, $objRecord, 2)
                    $hshMsiProperties[$prop_name] = $prop_value
                    $objRecord = $objView.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $objView, $Null)
                }

                $hshMsiProperties
            }

            CATCH { throw "Failed to get MSI file version the error was: {0}." -f $_ }
        }
}
