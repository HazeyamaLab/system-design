# Scoopでインストールしたソフトウェアの削除とScoopのアンインストールを行う
scoop uninstall scoop

Remove-Item "$HOEM\scoop\*" -Recurse
