<#  
.SYNOPSIS  
    This script defines a function that tests to  
    see if a file is open.  
.DESCRIPTION  
    This script used the System.Io.FileStream class   
    and the FileInfo class to try to open a file  
    stream for write. If it fails, we return $false,  
    else we close the file and return $True  
.NOTES  
    File Name  : Test-FileOpen.ps1  
    Author     : Thomas Lee - tfl@psp.co.uk  
    Requires   : PowerShell Version 2.0  
.LINK  
    This script posted to:  
        http://www.pshscripts.blogspot.com  
.EXAMPLE  
    Psh[Cookham8:C:\foo]> $file = New-Object -TypeName System.IO.FileInfo C:\foo\doc1.docx  
    Psh[Cookham8:C:\foo]>Test-FileOpen $file  
    True  
#>   
function Test-mlFileOpen {
    param(
        $fileName = $(Throw '***** No File specified')   
    )

    $ErrorActionPreference = "SilentlyContinue"
    [System.IO.FileStream] $fs = $file.OpenWrite();

    if (!$?) {$true}
    else {$fs.Dispose();$false}
}
