if (Get-Command choco -ea SilentlyContinue) {
  choco install -y mysql
} else {
  Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  choco install -y mysql
}

$PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
$PATH += ";" + 'C:\tools\mysql\current\bin'
[Environment]::SetEnvironmentVariable('PATH', $PATH, 'Machine')

mysql --version
