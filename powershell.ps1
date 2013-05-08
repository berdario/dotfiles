Import-Module Pscx
# Import-Module "PowerTab" -ArgumentList "C:\Users\Dario\Documents\WindowsPowerShell\PowerTabConfig.xml"

$env:Path += ";$home\Applications\bin;$home\Applications\emacs\bin"
$env:HGEditor = $env:Editor = "emacs -nw"

function bzr {
	if ($args[0] -eq "log"){
		bzr.exe $args | less
	} else {
		bzr.exe $args
	}
}

$Global:pshistory = "$home\Documents\WindowsPowerShell\log.csv"

$history = ("#TYPE Microsoft.PowerShell.Commands.HistoryInfo",
'"Id","CommandLine","ExecutionStatus","StartExecutionTime","EndExecutionTime"')

if (Test-Path $pshistory) {
	$history += (get-content $pshistory)
}

# should probably filter out the Failed commands
$history | Select -Unique | Convertfrom-csv -ErrorAction SilentlyContinue | Add-History 

function prompt{
	$hid = $myinvocation.historyID
	if ($hid -gt 1) {
		(get-history ($myinvocation.historyID -1 ) | convertto-csv)[-1] >> $pshistory
	}
	"PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
}
