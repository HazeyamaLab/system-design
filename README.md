# 情報システム設計

東京学芸大学「情報システム設計」の環境構築用のスクリプトです。

**注意事項:** 本スクリプトファイルは実行結果をリモートに集計します。

## for Windows

### 1. PowerShellを管理者権限で実行  
   PowerShellを管理者権限で起動します。  
   管理者権限での起動方法は「スタート」で右クリックし「Windows PowerShell（管理者）」を選択します。

   ![](https://raw.githubusercontent.com/HazeyamaLab/setup/master/windows/windows.gif)

### 2. PowerSehllスクリプトの実行ポリシーの変更
  Windowsのデフォルトの設定ではPowerShellでのスクリプトの実行が制限されています。  
  今回の環境構築のスクリプトを実行するために現在、ログイン済みのユーザーに対しスクリプトの実行ポリシーを変更します。  
  具体的には以下のコマンドをコピーしPowerShellにペーストして実行してください。

  ```ps
  Set-ExecutionPolicy RemoteSigned -scope CurrentUser
  ```

### 3. 環境構築用のPowerShellスクリプトの実行
   以下のコマンドをコピーしPowerShellにペーストしてスクリプトを実行します。

   ```ps
   iwr -useb https://raw.githubusercontent.com/HazeyamaLab/system-design/master/windows/install.ps1 | iex
   ```

## for macOS

## Licence

MIT
