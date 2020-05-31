[string]$LOGG='------------------------------------------------------------------------
                    __                        __          _           
   _______  _______/ /____  ____ ___     ____/ /__  _____(_)___ _____ 
  / ___/ / / / ___/ __/ _ \/ __ `__ \   / __  / _ \/ ___/ / __ `/ __ \
 (__  ) /_/ (__  ) /_/  __/ / / / / /  / /_/ /  __(__  ) / /_/ / / / /
/____/\__, /____/\__/\___/_/ /_/ /_/   \__,_/\___/____/_/\__, /_/ /_/ 
     /____/                                             /____/        
------------------------------------------------------------------------
  Copyright (c) 2020 "Tokyo Gakugei University - Hazeyama Laboratory"
------------------------------------------------------------------------
[注意] 本スクリプトは東京学芸大学「情報システム設計」で使用するソフトウェアをインストールするものです．
[注意] スクリプト実行後に実行結果をリモートに送信します．
------------------------------------------------------------------------
以上に同意して実行する場合は y をキャンセルする場合は n を入力してください．[y/n]'

##################################################
# 関数 (処理が複雑な部分は関数化)
##################################################
# 実行確認関数
function Confirm-Execution {
  $i = Read-Host ">> "

  if ($i -eq "y" -or $i -eq "Y"){
    return
  } elseif ($i -eq "n" -or $i -eq "N") {
    Write-Output "スクリプトを終了します."
    exit 1
  } else {
    Write-Output "y または n を入力して下さい."
    Confirm-Execution
  }
}

# 学籍番号確認関数
function Confirm-StudentID {
  Write-Host "学籍番号を入力してください．"
  Write-Host "例) a181401x"
  $i = Read-Host ">> "

  if ($i -match "[a-z][0-9]{6}[a-z]" ) {
    return $i
  } else {
    Write-Host "指定した形式で入力してください．"
    Confirm-StudentID
  }
}

##################################################
# main部分
##################################################
[string]$ENV=$env:ENV

# アスキーアートと説明の出力
Write-Output "$LOGG"

# 確認プロンプトの出力
if ($ENV -eq "CI") {
  Write-Output "Running at GitHub Actions"
  [string]$ID = "windows-ci"
} else {
  Confirm-Execution
  [string]$ID = Confirm-StudentID
}

# ファイルの作成に使用するので実行時のパスを取得
[string]$DefaultPath = Convert-Path .

Write-Output "[1/2] gradle TomcatRunを実行しています..."
gradle tomcatRun -i >> "$DefaultPath/$ID.log"

# ログデータの送信
if ($ENV -ne "ci") {
  Write-Output "[2/2] ログデータを送信しています..."
  Invoke-WebRequest -Method Post -InFile "$DefaultPath\$ID.log" https://hazelab-logger.netlify.app/.netlify/functions/tomcat-run?name="$ID.log"
}

Write-Output "完了しました✨"
