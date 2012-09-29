Import-Module Pscx
# Import-Module "PowerTab" -ArgumentList "C:\Users\Dario\Documents\WindowsPowerShell\PowerTabConfig.xml"

$env:Path += ";$home\Applications\bin;$home\Applications\emacs\bin"
$env:HGEditor = $env:Editor = "emacs -nw"