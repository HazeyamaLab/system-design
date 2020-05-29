Write-Output "現在のJAVA_HOMEを確認します..."
Write-Output $ENV:JAVA_HOME

# scoopのインストール
if (!(Get-Command scoop -ea SilentlyContinue)) {
  Write-Output "scoop をインストールしています..."
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
  scoop install git
  scoop bucket add extras
  scoop bucket add java
}

# javaのインストール
scoop install adopt8-hotspot
scoop install adopt11-hotspot
scoop reset adopt11-hotspot

Write-Output "変更後のJAVA_HOMEを確認します..."
Write-Output $ENV:JAVA_HOME

# Gradleのインストール
Write-Output "Gradleをインストールしています..."
scoop install gradle@6.2.2

gradle -version

Write-Output "完了しました✨"
