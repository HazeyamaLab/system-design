#!/bin/bash

readonly LOGO='------------------------------------------------------------------------
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
function confirm_execution() {
  read -rp ">> " input

  if [ "$input" = 'y' ] || [ "$input" = 'Y' ]; then
    return 0
  elif [ "$input" = 'n' ] || [ "$input" = 'N' ]; then
    echo "スクリプトを終了します."
    exit 1
  else
    echo "y または n を入力して下さい."
    confirm_execution
  fi
}

# 学籍番号確認関数
function confirm_student_id() {
  echo "学籍番号を入力してください．"
  echo "例) a181401x"
  read -rp ">> " ID

  if [[ ! "$ID" =~ [a-z][0-9]{6}[a-z] ]]; then
    echo "指定した形式で入力してください．"
    confirm_student_id
  else
    return 0
  fi
}

# Gradleのインストール関数(6.3をインストール後に6.2.2にする)
function install_gradle() {
  brew insatll gradle
  cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/
  git checkout 5fd374b706a7949f13fc20c654764c2ac5986e42 gradle.rb
  brew unlink gradle
  brew insatll gradle
}

##################################################
# main部分
##################################################
# アスキーアートと説明の出力
echo "$LOGO"

# 確認プロンプトの出力
confirm_execution
confirm_student_id

# ログ出力の設定(今回は標準出力，標準エラー出力の両方を同じファイルに出力する)
DEFAULT_PATH=$PWD
FILE_NAME=$ID.log
LOG_OUT="${DEFAULT_PATH}/${FILE_NAME}"
exec 2>&1 > >(tee -a "$LOG_OUT")

# ログファイルの先頭に実行日時などを記載
DATE=$(date +"%Y/%m/%d %T")
OS_INFO=$(sw_vers)
echo "------------------------------------------------------------
[INFO] ${DATE} User: ${ID}
------------------------------------------------------------
${OS_INFO}
------------------------------------------------------------" >> "$LOG_OUT"

# Command Line Developper Toolsのインストール
if which xcode-select >/dev/null 2>&1; then
  echo "[1/6] xcode-select はインストール済みです. このステップはスキップします."
else
  echo "[1/6] xcode-select をインストール中です."
  xcode-select --install
fi

# Homebrewのインストール
if which brew >/dev/null 2>&1; then
  echo "[2/6] homebrew はインストール済みです. このステップはスキップします."
else
  echo "[2/6] homebrew をインストール中です..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# MySQLのインストール
if which mysql >/dev/null 2>&1; then
  echo "[3/6] MySQL はインストール済みです. このステップはスキップします."
  CURRENT_MYSQL_VERSION=$(mysql --version)
  echo "[DEBUG] MySQL version: ${CURRENT_MYSQL_VERSION}" >> "$LOG_OUT"
else
  echo "[3/6] MySQL をインストール中です..."
  brew install mysql
fi

# Javaのインストール
if which java >/dev/null 2>&1; then
  echo "[4/6] Java はインストール済みです. このステップはスキップします."
  CURRENT_JAVA_VERSION=$(java -version 2>&1)
  echo "[DEBUG] Java version: ${CURRENT_JAVA_VERSION}" >> "$LOG_OUT"
  echo "[DEBUG] ENV JAVA_HOME:  ${JAVA_HOME}" >> "$LOG_OUT"
else
  echo "[4/6] Java をインストール中です..."
  brew tap homebrew/cask
  brew tap AdoptOpenJDK/openjdk
  brew cask adoptopenjdk/openjdk/adoptopenjdk8
  brew cask adoptopenjdk11
fi

# Gradleのインストール
if which gradle >/dev/null 2>&1; then
  echo "[5/6] Gradle はインストール済みです. このステップはスキップします."
  CURRENT_GRADLE_VERSION=$(gradle -version)
  echo "[DEBUG] Gradle version: ${CURRENT_GRADLE_VERSION}" >> "$LOG_OUT"
else
  echo "[5/6] Gradle をインストール中です..."
  install_gradle
fi

# ログデータの送信
curl -fsSL -X POST https://hazelab-logger.netlify.app/.netlify/functions/send-teams -F "file=@${LOG_OUT}" >> "$LOG_OUT"
echo "[6/6] ログデータを送信しています..."

echo "完了しました✨"
