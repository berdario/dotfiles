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