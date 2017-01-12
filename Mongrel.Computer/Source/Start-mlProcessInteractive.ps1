function Start-mlProcessInteractive {
  param(
    $Path = "${env:ProgramFiles(x86)}\Internet Explorer\iexplore.exe",
    $Arguments = 'www.powertheshell.com',
    [Parameter(Mandatory=$true)]$Computername,
    [Parameter(Mandatory=$true)]$Username
  )
 
 
      
  $xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo />
  <Triggers />
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings />
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>"$Path"</Command>
      <Arguments>$Arguments</Arguments>
    </Exec>
  </Actions>
  <Principals>
    <Principal id="Author">
      <UserId>$Username</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
</Task>
"@ 
      
  $jobname = 'remotejob{0}' -f (Get-Random)
  $filename = [Guid]::NewGuid().ToString('d')  
  $filepath = "$env:temp\$filename"
  
  $xml | Set-Content -Path $filepath -Encoding Unicode
  
  try {
    $ErrorActionPreference = 'Stop'
    schtasks.exe /CREATE /TN $jobname /XML $filepath /S $ComputerName  2>&1
    schtasks.exe /RUN /TN $jobname /S $ComputerName  2>&1
    schtasks.exe /DELETE /TN $jobname /s $ComputerName /F  2>&1
  }

  catch { Write-Warning ("While accessing \\$ComputerName : " + $_.Exception.Message) }

  Remove-Item -Path $filepath
}
