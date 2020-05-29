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
  Write-Output "学籍番号を入力してください．"
  Write-Output "例) a181401x"
  $i = Read-Host ">> "

  if ($i -match "[a-z][0-9]{6}[a-z]" ) {
    return $i
  } else {
    Write-Output "指定した形式で入力してください．"
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
  Write-Output "Running at GitHUb Actions"
  [string]$ID = "windows-ci"
} else {
  Confirm-Execution
  [string]$ID = Confirm-StudentID
}

# ファイルの作成に使用するので実行時のパスを取得
[string]$DefaultPath = Convert-Path .

# scoopのインストール
if (Get-Command scoop -ea SilentlyContinue) {
  Write-Output "[1/8] scoop はインストール済みです. このステップはスキップします."
} else {
  Write-Output "[1/8] scoop をインストールしています..."
  Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# chocolateyのインストール
if (Get-Command choco -ea SilentlyContinue) {
  Write-Output "[2/8] chocolatey はインストール済みです. このステップはスキップします."
} else {
  Write-Output "[2/8] chocolatey をインストールしています..."
  Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Output "[3/8] 依存するパッケージをインストールしています..."
# Gitのインストール
if (!(Get-Command git -ea SilentlyContinue)) {
  Write-Output "git をインストールしています..."
  scoop install git
}

# graphvizのインストール
if (!(Get-Command dot -ea SilentlyContinue)) {
  Write-Output "graphviz をインストールしています..."
  scoop install graphviz
}

# scoopの設定(これにGitが必要)
$BucketList = scoop bucket list
if (!$BucketList.Contains("extras")) {
  Write-Output "scoop の extras bucket を追加しています..."
  scoop bucket add extras
}
if (!$BucketList.Contains("java")) {
  Write-Output "scoop の java bucket を追加しています..."
  scoop bucket add java
}

# MySQLのインストール
if (Get-Command mysql -ea SilentlyContinue) {
  Write-Output "[4/8] MySQL はインストール済みです. このステップはスキップします."
  } else {
  Write-Output "[4/8] MySQL をインストールしています..."
  choco install -y mysql
  scoop install mysql-workbench
}

# Javaのインストール
if (Get-Command java -ea SilentlyContinue) {
  Write-Output "[5/8] Java はインストール済みです. このステップはスキップします."
} else {
  Write-Output "[5/8] Java をインストールしています..."
  scoop install adopt8-hotspot
  scoop install adopt11-hotspot
  scoop reset adopt11-hotspot
}

# Gradleのインストール
if (Get-Command gradle -ea SilentlyContinue) {
  Write-Output "[6/8] Gradle はインストール済みです. このステップはスキップします."
} else {
  Write-Output "[6/8] Gradle をインストールしています..."
  scoop install gradle@6.2.2
}

##################################################
# 環境情報の取得
##################################################
Write-Output "[7/8] ソフトウェアのバージョンを確認しています..."

Start-Transcript "$DefaultPath/$ID.log"

Write-Output "[DEBUG] Scoopでのインストール状況を確認します."
scoop status

Write-Output "[DEBUG] MySQLのバージョンを確認します."
mysql --version

Write-Output "[DEBUG] JavaとGradleのバージョンと環境変数JAVA_HOMEを確認します."
Write-Output "[DEBUG] ENV JAVA_HOME:"
Write-Output "$env:JAVA_HOME"
Write-Output "[DEBUG] Gradle version:"
gradle -version

Stop-Transcript

# ログデータの送信
if ($ENV -ne "ci") {
  Write-Output "[8/8] ログデータを送信しています..."
  Invoke-WebRequest -Method Post -InFile "$DefaultPath/$ID.log" https://hazelab-logger.netlify.app/.netlify/functions/send-teams
}

Write-Output "完了しました✨"
