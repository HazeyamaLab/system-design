Write-Output "現在のJAVA_HOMEを確認します..."
Write-Output $ENV:JAVA_HOME

# scoopのインストール
if (!(Get-Command scoop -ea SilentlyContinue)) {
  Write-Output "[1/8] scoop をインストールしています..."
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
  scoop bucket add java
}

scoop install adopt8-hotspot
scoop install adopt11-hotspot
scoop reset adopt11-hotspot

Write-Output "変更後のJAVA_HOMEを確認します..."
Write-Output $ENV:JAVA_HOME
