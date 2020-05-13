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
if (gcm scoop -ea SilentlyContinue) {
  Write-Host "[1/7] scoop はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[1/7] scoop をインストールしています..."
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# chocolateyのインストール
if (gcm choco -ea SilentlyContinue) {
  Write-Host "[2/7] chocolatey はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[2/7] chocolatey をインストールしています..."
  Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Gitのインストール
if (gcm git -ea SilentlyContinue) {
  Write-Host "[3/7] git はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[3/7] git をインストールしています..."
  scoop install git
}

# MySQLのインストール
if (gcm mysql -ea SilentlyContinue) {
  Write-Host "[4/7] MySQL はインストール済みです. このステップはスキップします."
  Write-Host "[DEBUG] MySQLのバージョンを確認します."
  mysql --version
} else {
  Write-Host "[4/7] MySQL をインストールしています..."
  choco install -y mysql
  scoop install mysql-workbench
}

# Javaのインストール
if (gcm java -ea SilentlyContinue) {
  Write-Host "[5/7] Java はインストール済みです. このステップはスキップします."
  Write-Host "[DEBUG] Javaのバージョンと環境変数JAVA_HOMEを確認します."
  Write-Host "[DEBUG] Java version:"
  java -version
  Write-Host "[DEBUG] ENV JAVA_HOME:"
  Write-Host "$env:JAVA_HOME"
} else {
  Write-Host "[5/7] Java をインストールしています..."
  scoop install adopt8-hotspot
  scoop install adopt11-hotspot
}

# Gradleのインストール
if (gcm gradle -ea SilentlyContinue) {
  Write-Host "[6/7] Gradle はインストール済みです. このステップはスキップします."
  Write-Host "[DEBUG] Gradleのバージョンを確認します."
  Write-Host "[DEBUG] Gradle version:"
  gradle -version
} else {
  Write-Host "[6/7] Gradle をインストールしています..."
  scoop install gradle@6.2.2
}

# ログデータの送信
Invoke-WebRequest -Method Post -InFile "$DefaultPath/$ID.log" https://hazelab-logger.netlify.app/.netlify/functions/send-teams
Write-Host "[7/7] ログデータを送信しています..."

Stop-Transcript

Write-Host "完了しました✨"
