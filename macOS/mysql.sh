#!/bin/bash

# MySQLのインストール
if which mysql >/dev/null 2>&1; then
  # serverの起動
  mysql.server start

  # データベースのバックアップ
  mysqldump -u root -p -h 127.0.0.1 -A > backup.sql

  # serverの停止
  mysql.server stop
fi

brew reinstall mysql

mysql --version
