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

# ファイルの作成に使用するので実行時のパスを取得
[string]$DefaultPath = Convert-Path .

# scoopのインストール
if (Get-Command scoop -ea SilentlyContinue) {
  Write-Host "[1/8] scoop はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[1/8] scoop をインストールしています..."
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# chocolateyのインストール
if (Get-Command choco -ea SilentlyContinue) {
  Write-Host "[2/8] chocolatey はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[2/8] chocolatey をインストールしています..."
  Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Gitのインストール
if (Get-Command git -ea SilentlyContinue) {
  Write-Host "[3/8] git はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[3/8] git をインストールしています..."
  scoop install git
}

# scoopの設定(これにGitが必要)
$BucketList = scoop bucket list
if (!$BucketList.Contains("extras")) {
  scoop bucket add extras
}
if (!$BucketList.Contains("java")) {
  scoop bucket add java
}

# MySQLのインストール
if (Get-Command mysql -ea SilentlyContinue) {
  Write-Host "[4/8] MySQL はインストール済みです. このステップはスキップします."} else {
  Write-Host "[4/8] MySQL をインストールしています..."
  choco install -y mysql
  scoop install mysql-workbench
}

# Javaのインストール
if (Get-Command java -ea SilentlyContinue) {
  Write-Host "[5/8] Java はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[5/8] Java をインストールしています..."
  scoop install adopt8-hotspot
  scoop install adopt11-hotspot
  scoop reset adopt11-hotspot
}

# Gradleのインストール
if (Get-Command gradle -ea SilentlyContinue) {
  Write-Host "[6/8] Gradle はインストール済みです. このステップはスキップします."
} else {
  Write-Host "[6/8] Gradle をインストールしています..."
  scoop install gradle@6.2.2
}

##################################################
# 環境情報の取得
##################################################
Write-Host "[7/8] ソフトウェアのバージョンを確認しています..."

Start-Transcript "$DefaultPath/$ID.log"

Write-Host "[DEBUG] Scoopでのインストール状況を確認します."
scoop status

Write-Host "[DEBUG] MySQLのバージョンを確認します."
mysql --version

Write-Host "[DEBUG] Javaのバージョンと環境変数JAVA_HOMEを確認します."
Write-Host "[DEBUG] Java version:"
java -version
Write-Host "[DEBUG] ENV JAVA_HOME:"
Write-Host "$env:JAVA_HOME"

Write-Host "[DEBUG] Gradleのバージョンを確認します."
Write-Host "[DEBUG] Gradle version:"
gradle -version

Stop-Transcript

# ログデータの送信
Write-Host "[8/8] ログデータを送信しています..."
Invoke-WebRequest -Method Post -InFile "$DefaultPath/$ID.log" https://hazelab-logger.netlify.app/.netlify/functions/send-teams

Write-Host "完了しました✨"
