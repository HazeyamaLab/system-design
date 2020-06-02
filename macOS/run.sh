#!/bin/bash

# shellcheck disable=SC208
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
[注意] 本スクリプトは東京学芸大学「情報システム設計」で"gradle tomcatRun"実行時の状態を，責任者に伝えるものです．
[注意] スクリプト実行後に実行結果をリモートに送信します．
------------------------------------------------------------------------
以上に同意して実行する場合は y をキャンセルする場合は n を入力してください．[y/n]'

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
  if [[ "$ID" =~ [a-z][0-9]{6}[a-z] ]]; then
    return 0
  else
    echo "指定した形式で入力してください．"
    confirm_student_id
  fi
}

##########
# main
#########
echo "$LOGO"

# 確認プロンプトの出力
if [ "$ENV" = "CI" ]; then
  ID="macOS-ci"
  echo "Running at GitHub Actions"
else
  confirm_execution
fi

# 環境変数の有無
ID=""
for file in `\find ~ -maxdepth 1 -type f -regex ".*key-.*"`; do
  ID=`echo $file | rev | cut -c 1-8 | rev`
done

if [ ${#ID} = 8 ]; then
    echo "$ID"
else
    echo "学籍番号が認識できないので入力してください．"
    confirm_student_id
fi

# ファイル出力の設定
# export LANG=ja_JP.UTF-8
DEFAULT_PATH=$PWD
FILE_NAME=$ID.log
LOG_OUT="${DEFAULT_PATH}/${FILE_NAME}"

if [ -e $LOG_OUT ]; then
  rm $LOG_OUT
fi

touch $LOG_OUT

DATE=$(date +"%Y/%m/%d %T")
OS_INFO=$(sw_vers)
echo "------------------------------------------------------------
[INFO] ${DATE} User: ${ID}
------------------------------------------------------------" >> "$LOG_OUT"

echo "[1/2] gradle tomcatRun を実行中です."
gradle tR -i >>  "$LOG_OUT"
echo "[2/2] 実行ログを送信しています．"
curl -fsSL -X POST -H "Content-Type: application/octet-stream" --data-binary "@${LOG_OUT}"  https://hazelab-logger.netlify.app/.netlify/functions/tomcat-run?name="${FILE_NAME}"

echo "完了しました✨"
