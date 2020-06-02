# Scoopでインストールしたソフトウェアの削除とScoopのアンインストールを行う
scoop uninstall scoop

Remove-Item -Force -Recurse -Path "$HOEM\scoop\**"
