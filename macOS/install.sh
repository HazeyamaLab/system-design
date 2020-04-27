#!/bin/bash

# システム設計の環境構築用

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

# 実行するかの確認
function confirm_execution() {
  read -p ">> " input

  if [ -z $input ] ; then
    echo "y または n を入力して下さい."
    confirm_execution
  elif [ $input = 'y' ] || [ $input = 'Y' ]; then
    return 0
  elif [ $input = 'n' ] || [ $input = 'N' ]; then
    echo "スクリプトを終了します."
    exit 1
  else
    echo "y または n を入力して下さい."
    confirm_execution
  fi
}

# 学籍番号確認
function confirm_student_id() {
  
  echo "学籍番号を入力してください．"
  echo "例) a181401x"
  read -p ">> " ID

  if [[ ! $ID =~ [a-z][0-9]{6}[a-z] ]]; then
    echo "指定した形式で入力してください．"
    confirm_student_id
  else
    return 0
  fi
}


echo "$LOGO"


confirm_execution
confirm_student_id

# ログファイルの命名
LOG_OUT=./$ID-stdout.log
LOG_ERR=./$ID-stderr.log
DEFAULT_PATH=$PWD

exec 1> >(tee -a $LOG_OUT)
exec 2>>$LOG_ERR

# Command Line Developper Toolsのインストール
if which xcode-select >/dev/null 2>&1; then
  echo "[1/4] xcode-select is already installed! skipping this step."
else
  echo "[1/4] installing xcode-select..."
  xcode-select --install
fi

# Homebrewのインストール
if which brew >/dev/null 2>&1; then
  echo "[2/4] homebrew is already installed! skipping this step."
else
  echo "[2/4] installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# GitHubからBrewfileをダウンロード (とりあえずHOMEディレクトリに配置する．)
echo "[3/4] download Brewfile..."
cd "$HOME" && curl -fsSL https://raw.githubusercontent.com/HazeyamaLab/system-design/master/macOS/Brewfile > ./Brewfile

# 取得したBrewfileをもとにパッケージをインストール
echo "[4/4] installing package..."
cd "$HOME" && brew bundle && rm Brewfile

echo "Completed!"
