# Scoopでインストールしたソフトウェアの削除とScoopのアンインストールを行う
if (Get-Command scoop -ea SilentlyContinue) {
  Write-Output "scoop をアンインストールします..."
  scoop uninstall scoop
  Remove-Item -Force -Recurse -Path "$HOME\scoop\**"
} else {
  Write-Output "scoopがインストールされていません．スクリプトを終了します．"
}
