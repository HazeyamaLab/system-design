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
  Copyright (c) 2020 "**** University - ****** Laboratory"
------------------------------------------------------------------------
[Note] This script installs software for use in "System Design".
[Note] After the script is executed, Sends the result to the remote.
------------------------------------------------------------------------
If you agree to above notes, enter "y". To cancel, enter "n". [y/n]'

##################################################
# 関数 (処理が複雑な部分は関数化)
##################################################
# 実行確認関数
function confirm_execution() {
  read -rp ">> " input
  if [ "$input" = 'y' ] || [ "$input" = 'Y' ]; then
    return 0
  elif [ "$input" = 'n' ] || [ "$input" = 'N' ]; then
    echo "exit"
    exit 1
  else
    echo 'Please enter "y" or "n".'
    confirm_execution
  fi
}

# 学籍番号確認関数
function confirm_student_id() {
  echo "Enter your student's ID number"
  read -rp ">> " ID

  if [[ "$ID" =~ [a-z][0-9]{6}[a-z] ]]; then
    return 0
  else
    echo "Input in the specified format."
    confirm_student_id
  fi
}

##################################################
# main部分
##################################################
# アスキーアートと説明の出力
echo "$LOGO"
# 確認プロンプトの出力
if [ "$ENV" = "CI" ]; then
  ID="macOS-ci"
  echo "Running at GitHub Actions"
else
  confirm_execution
  confirm_student_id
fi

echo "完了しました✨"
