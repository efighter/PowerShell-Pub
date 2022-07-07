$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate('Notepad')
$startdate=(GET-DATE)
Write-Host $startdate    -backgroundcolor yellow -foregroundcolor black

do
{
    $wshell.SendKeys('a')
    $curDate=(GET-DATE)
    Write-Host $curDate    -backgroundcolor yellow -foregroundcolor black
    Sleep 280
}while($true)