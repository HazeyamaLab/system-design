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
  $input = Read-Host ">> "

  if ($input -eq "y" -or $input -eq "Y"){
    return
  } elseif ($input -eq "n" -or $input -eq "N") {
    Write-Host "スクリプトを終了します."
    exit 1
  } else {
    Write-Host "y または n を入力して下さい."
    Confirm-Execution
  }
}

# 学籍番号確認関数
function Confirm-StudentID {
  Write-Host "学籍番号を入力してください．"
  Write-Host "例) a181401x"
  $input = Read-Host ">> "

  if ($input -match "[a-z][0-9]{6}[a-z]" ) {
    return $input
  } else {
    Write-Host "指定した形式で入力してください．"
    Confirm-StudentID
  }
}

##################################################
# main部分
##################################################
# アスキーアートと説明の出力
Write-Host "$LOGG"

# 確認プロンプトの出力
Confirm-Execution
[string]$ID = Confirm-StudentID

# ログ出力の設定
# 実行のログファイルを作成しながら実行(Stop-Transcriptまでログファイルに記録)
[string]$DefaultPath = Convert-Path .
Start-Transcript "$DefaultPath/$ID.log"

# scoopのインストール
# chocolateyのインストール
# Gitのインストール
# MySQLのインストール
# Javaのインストール
# Gradleのインストール
# ログデータの送信
Invoke-WebRequest -Method Post -InFile "$DefaultPath/$ID.log" https://hazelab-logger.netlify.app/.netlify/functions/send-teams

Stop-Transcript

Write-Host "完了しました✨"
